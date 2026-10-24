import { ForbiddenException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, In, MoreThan, Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { User } from '../auth/entities/user.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { Group } from './entities/group.entity';
import { GroupInvite } from './entities/group-invite.entity';
import { GroupMember } from './entities/group-member.entity';
import { CreateGroupDto } from './dto/create-group.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { groupErrors } from './group-errors';
import { GROUP_MAX_MEMBERS, GroupRole, INVITE_TTL_HOURS } from './groups.constants';
import { generateInviteCode } from './invite-code';
import { GroupMemberView, InviteView, MyGroupResponse, SharedBudgetRef } from './groups.types';

const NO_GROUP: MyGroupResponse = { group: null, me: null, members: [], sharedBudgets: [], invite: null };

/** Postgres unique_violation. */
const UNIQUE_VIOLATION = '23505';

/** New codes tried when a generated one is already taken. */
const INVITE_CODE_ATTEMPTS = 5;

const HOUR_MS = 60 * 60 * 1000;

@Injectable()
export class GroupsService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(Group) private readonly groupRepo: Repository<Group>,
    @InjectRepository(GroupMember) private readonly memberRepo: Repository<GroupMember>,
    @InjectRepository(GroupInvite) private readonly inviteRepo: Repository<GroupInvite>,
    @InjectRepository(Budget) private readonly budgetRepo: Repository<Budget>,
    @InjectRepository(User) private readonly userRepo: Repository<User>,
  ) {}

  /** Makes a Family Group with the caller as its only member and Admin. */
  async create(userId: string, dto: CreateGroupDto): Promise<MyGroupResponse> {
    try {
      await this.dataSource.transaction(async (manager) => {
        if (await manager.exists(GroupMember, { where: { userId } })) throw groupErrors.alreadyInGroup();
        const group = manager.create(Group, {
          id: uuidv4(),
          name: dto.name,
          currencyCode: dto.currencyCode,
          monthlyBudget: dto.monthlyBudget ?? null,
          createdBy: userId,
        });
        await manager.save(group);
        await manager.save(manager.create(GroupMember, { groupId: group.id, userId, role: GroupRole.ADMIN }));
      });
    } catch (error) {
      // Two creates at once: the unique index on group_members.userId wins.
      if (isUniqueViolation(error)) throw groupErrors.alreadyInGroup();
      throw error;
    }
    return this.getMine(userId);
  }

  /**
   * Makes a new Invite Code for the group and deletes its old ones, so the
   * previous code stops working (CONTEXT.md Invite Code).
   */
  async createInvite(groupId: string, userId: string): Promise<InviteView> {
    for (let attempt = 1; ; attempt++) {
      const invite = { code: generateInviteCode(), groupId, createdBy: userId };
      const expiresAt = new Date(Date.now() + INVITE_TTL_HOURS * HOUR_MS);
      try {
        await this.dataSource.transaction(async (manager) => {
          await manager.delete(GroupInvite, { groupId });
          await manager.insert(GroupInvite, { ...invite, expiresAt });
        });
        return { code: invite.code, expiresAt: expiresAt.toISOString() };
      } catch (error) {
        // Another group holds this code; try a new one.
        if (!isUniqueViolation(error) || attempt >= INVITE_CODE_ATTEMPTS) throw error;
      }
    }
  }

  /** Adds the caller to the group behind [dto.code] as a Member. */
  async join(userId: string, dto: JoinGroupDto): Promise<MyGroupResponse> {
    try {
      await this.dataSource.transaction((manager) => this.joinIn(manager, userId, dto));
    } catch (error) {
      // Two joins by the same user at once: the unique index on userId wins.
      if (isUniqueViolation(error)) throw groupErrors.alreadyInGroup();
      throw error;
    }
    return this.getMine(userId);
  }

  /** The checks run in this order, so the caller hears the first that fails. */
  private async joinIn(manager: EntityManager, userId: string, dto: JoinGroupDto): Promise<void> {
    if (await manager.exists(GroupMember, { where: { userId } })) throw groupErrors.alreadyInGroup();
    const invite = await manager.findOne(GroupInvite, { where: { code: dto.code } });
    if (!invite) throw groupErrors.inviteNotFound();
    if (invite.expiresAt.getTime() <= Date.now()) throw groupErrors.inviteExpired();
    // Locks the group row so two joins at once cannot both pass the cap.
    const group = await manager.findOne(Group, { where: { id: invite.groupId }, lock: { mode: 'pessimistic_write' } });
    if (!group) throw groupErrors.inviteNotFound();
    if (group.currencyCode !== dto.currencyCode) throw groupErrors.currencyMismatch(group.currencyCode);
    if ((await manager.count(GroupMember, { where: { groupId: group.id } })) >= GROUP_MAX_MEMBERS) {
      throw groupErrors.groupFull();
    }
    // The invite stays: codes are reusable until they expire.
    await manager.insert(GroupMember, { groupId: group.id, userId, role: GroupRole.MEMBER });
  }

  /** Changes a member's role. The group must keep at least one Admin. */
  async updateRole(groupId: string, targetId: string, dto: UpdateMemberRoleDto, callerId: string): Promise<MyGroupResponse> {
    await this.dataSource.transaction(async (manager) => {
      const target = await manager.findOne(GroupMember, { where: { groupId, userId: targetId } });
      if (!target) throw groupErrors.notInGroup();
      if (target.role === GroupRole.ADMIN && dto.role !== GroupRole.ADMIN) {
        const admins = await manager.count(GroupMember, { where: { groupId, role: GroupRole.ADMIN } });
        if (admins <= 1) throw groupErrors.lastAdmin();
      }
      target.role = dto.role;
      await manager.save(target);
    });
    return this.getMine(callerId);
  }

  /**
   * Removes [targetId] from the group: a member leaving (caller == target) or
   * an Admin removing someone. Runs the leave rules (see [applyLeaveRules]).
   */
  async removeMember(groupId: string, targetId: string, caller: GroupMember): Promise<void> {
    if (caller.userId !== targetId && caller.role !== GroupRole.ADMIN) {
      throw new ForbiddenException('Only an admin can remove other members');
    }
    await this.dataSource.transaction(async (manager) => {
      if (!(await manager.exists(GroupMember, { where: { groupId, userId: targetId } }))) throw groupErrors.notInGroup();
      await this.applyLeaveRules(manager, groupId, targetId);
    });
  }

  /**
   * Deletes the group. Its Shared Budgets become personal budgets of their
   * owner (ADR 0008); members and invites go with the group.
   */
  async deleteGroup(groupId: string): Promise<void> {
    await this.dataSource.transaction((manager) => this.deleteGroupRows(manager, groupId));
  }

  /**
   * What happens when [userId] leaves [groupId], by choice, by removal or by
   * deleting their account (AuthService). Does nothing for a non-member.
   * - the leaver's Shared Budgets in the group become personal again;
   * - no members left: the group is deleted;
   * - no Admin left: the longest-standing member becomes Admin.
   */
  async applyLeaveRules(manager: EntityManager, groupId: string, userId: string): Promise<void> {
    const deleted = await manager.delete(GroupMember, { groupId, userId });
    if (!deleted.affected) return;
    await this.detachBudgets(manager, groupId, userId);
    if ((await manager.count(GroupMember, { where: { groupId } })) === 0) {
      await this.deleteGroupRows(manager, groupId);
      return;
    }
    if ((await manager.count(GroupMember, { where: { groupId, role: GroupRole.ADMIN } })) === 0) {
      await this.promoteOldestMember(manager, groupId);
    }
  }

  /**
   * Clears groupId on Shared Budgets, of one owner or all. Bumping updatedAt
   * makes the owner's devices pull the budget again as personal; other
   * members' phones drop it after their next `/groups/me`.
   */
  private async detachBudgets(manager: EntityManager, groupId: string, ownerId?: string): Promise<void> {
    const params: string[] = ownerId ? [groupId, ownerId] : [groupId];
    await manager.query(
      `UPDATE "budgets" SET "groupId" = NULL, "updatedAt" = now() WHERE "groupId" = $1${ownerId ? ' AND "userId" = $2' : ''}`,
      params,
    );
  }

  private async deleteGroupRows(manager: EntityManager, groupId: string): Promise<void> {
    // Not left to ON DELETE SET NULL: that would not bump updatedAt, so
    // devices would never pull the change.
    await this.detachBudgets(manager, groupId);
    await manager.delete(Group, { id: groupId });
  }

  private async promoteOldestMember(manager: EntityManager, groupId: string): Promise<void> {
    const oldest = await manager.findOne(GroupMember, { where: { groupId }, order: { joinedAt: 'ASC' } });
    if (!oldest) return;
    oldest.role = GroupRole.ADMIN;
    await manager.save(oldest);
  }

  /** The caller's group, members, Shared Budgets and (for Admins) invite. */
  async getMine(userId: string): Promise<MyGroupResponse> {
    const me = await this.memberRepo.findOne({ where: { userId } });
    if (!me) return NO_GROUP;
    const group = await this.groupRepo.findOne({ where: { id: me.groupId } });
    if (!group) return NO_GROUP;

    return {
      group: {
        id: group.id,
        name: group.name,
        currencyCode: group.currencyCode,
        monthlyBudget: group.monthlyBudget === null ? null : Number(group.monthlyBudget),
        createdAt: group.createdAt.toISOString(),
      },
      me: { userId, role: me.role },
      members: await this.loadMembers(group.id),
      sharedBudgets: await this.loadSharedBudgets(group.id),
      invite: me.role === GroupRole.ADMIN ? await this.loadActiveInvite(group.id) : null,
    };
  }

  private async loadMembers(groupId: string): Promise<GroupMemberView[]> {
    const members = await this.memberRepo.find({ where: { groupId }, order: { joinedAt: 'ASC' } });
    const users = await this.userRepo.find({ where: { id: In(members.map((m) => m.userId)) } });
    const byId = new Map(users.map((u) => [u.id, u]));
    return members.map((m) => ({
      userId: m.userId,
      displayName: byId.get(m.userId)?.displayName ?? null,
      photoUrl: byId.get(m.userId)?.photoUrl ?? null,
      role: m.role,
      joinedAt: m.joinedAt.toISOString(),
    }));
  }

  private async loadSharedBudgets(groupId: string): Promise<SharedBudgetRef[]> {
    const budgets = await this.budgetRepo.find({ where: { groupId }, select: { id: true, name: true, userId: true } });
    return budgets.map((b) => ({ id: b.id, name: b.name, ownerId: b.userId }));
  }

  private async loadActiveInvite(groupId: string): Promise<InviteView | null> {
    const invite = await this.inviteRepo.findOne({
      where: { groupId, expiresAt: MoreThan(new Date()) },
      order: { createdAt: 'DESC' },
    });
    return invite ? { code: invite.code, expiresAt: invite.expiresAt.toISOString() } : null;
  }
}

/** A Postgres unique_violation, as thrown by TypeORM (QueryFailedError). */
export function isUniqueViolation(error: unknown): boolean {
  const e = error as { code?: string; driverError?: { code?: string } } | null;
  return e?.code === UNIQUE_VIOLATION || e?.driverError?.code === UNIQUE_VIOLATION;
}
