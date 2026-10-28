import { ConflictException, ForbiddenException, GoneException, HttpException, NotFoundException } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { GroupsService } from './groups.service';
import { GroupRole } from './groups.constants';
import { Group } from './entities/group.entity';
import { GroupMember } from './entities/group-member.entity';
import { GroupInvite } from './entities/group-invite.entity';

type Mock = jest.Mock;
const repo = () => ({
  findOne: jest.fn(),
  find: jest.fn().mockResolvedValue([]),
  exists: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  delete: jest.fn(),
  count: jest.fn(),
  update: jest.fn(),
  query: jest.fn(),
});


const fakeManager = () => ({
  exists: jest.fn().mockResolvedValue(false),
  create: jest.fn((_entity: unknown, data: object) => ({ ...data })),
  save: jest.fn((entity: object) => Promise.resolve(entity)),
  findOne: jest.fn(),
  find: jest.fn().mockResolvedValue([]),
  count: jest.fn().mockResolvedValue(0),
  delete: jest.fn(),
  insert: jest.fn(),
  query: jest.fn(),
});

describe('GroupsService', () => {
  let service: GroupsService;
  let manager: ReturnType<typeof fakeManager>;
  let groupRepo: ReturnType<typeof repo>;
  let memberRepo: ReturnType<typeof repo>;
  let inviteRepo: ReturnType<typeof repo>;
  let budgetRepo: ReturnType<typeof repo>;
  let userRepo: ReturnType<typeof repo>;
  let dataSource: { transaction: Mock };

  beforeEach(() => {
    manager = fakeManager();
    dataSource = { transaction: jest.fn((work: (m: unknown) => unknown) => work(manager)) };
    [groupRepo, memberRepo, inviteRepo, budgetRepo, userRepo] = [repo(), repo(), repo(), repo(), repo()];
    service = new GroupsService(
      dataSource as unknown as DataSource,
      groupRepo as never,
      memberRepo as never,
      inviteRepo as never,
      budgetRepo as never,
      userRepo as never,
    );
  });

  describe('create', () => {
    const dto = { name: 'Rahman Family', currencyCode: 'BDT', monthlyBudget: 50000 };

    it('should insert the group and an admin membership in one transaction', async () => {
      memberRepo.findOne.mockResolvedValue(null);

      await service.create('user-1', dto);

      expect(dataSource.transaction).toHaveBeenCalledTimes(1);
      const [[groupType, group], [memberType, member]] = manager.create.mock.calls as [unknown, Record<string, unknown>][];
      expect(groupType).toBe(Group);
      expect(group).toEqual(expect.objectContaining({ name: 'Rahman Family', currencyCode: 'BDT', createdBy: 'user-1' }));
      expect(memberType).toBe(GroupMember);
      expect(member).toEqual({ groupId: group.id, userId: 'user-1', role: GroupRole.ADMIN });
    });

    it('should reject a caller who is already in a group with ALREADY_IN_GROUP', async () => {
      manager.exists.mockResolvedValue(true);

      const error = await service.create('user-1', dto).catch((e: unknown) => e);

      expect(error).toBeInstanceOf(ConflictException);
      expect((error as ConflictException).getResponse()).toEqual(expect.objectContaining({ code: 'ALREADY_IN_GROUP' }));
      expect(manager.save).not.toHaveBeenCalled();
    });

    it('should map a unique violation from a concurrent create to ALREADY_IN_GROUP', async () => {
      dataSource.transaction.mockRejectedValue({ driverError: { code: '23505' } });

      const error = await service.create('user-1', dto).catch((e: unknown) => e);

      expect((error as ConflictException).getResponse()).toEqual(expect.objectContaining({ code: 'ALREADY_IN_GROUP' }));
    });
  });

  describe('getMine', () => {
    const group = {
      id: 'group-1',
      name: 'Family',
      currencyCode: 'BDT',
      monthlyBudget: '1500.50',
      createdAt: new Date('2026-01-01T00:00:00Z'),
    };

    const inGroupAs = (role: GroupRole) => {
      memberRepo.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', role });
      groupRepo.findOne.mockResolvedValue(group);
    };

    it('should return the empty shape for a user without a group', async () => {
      memberRepo.findOne.mockResolvedValue(null);

      await expect(service.getMine('user-1')).resolves.toEqual({
        group: null,
        me: null,
        members: [],
        sharedBudgets: [],
        invite: null,
      });
    });

    it('should sort members by joinedAt, add user names and convert monthlyBudget to a number', async () => {
      inGroupAs(GroupRole.ADMIN);
      memberRepo.find.mockResolvedValue([
        { userId: 'user-1', role: GroupRole.ADMIN, joinedAt: new Date('2026-01-01T00:00:00Z') },
        { userId: 'user-2', role: GroupRole.MEMBER, joinedAt: new Date('2026-01-02T00:00:00Z') },
      ]);
      userRepo.find.mockResolvedValue([{ id: 'user-2', displayName: 'Rina', photoUrl: null }]);

      const result = await service.getMine('user-1');

      expect(memberRepo.find).toHaveBeenCalledWith({ where: { groupId: 'group-1' }, order: { joinedAt: 'ASC' } });
      expect(result.group?.monthlyBudget).toBe(1500.5);
      expect(result.me).toEqual({ userId: 'user-1', role: GroupRole.ADMIN });
      expect(result.members.map((m) => [m.userId, m.displayName])).toEqual([
        ['user-1', null],
        ['user-2', 'Rina'],
      ]);
    });

    it('should list every shared budget with its owner', async () => {
      inGroupAs(GroupRole.MEMBER);
      budgetRepo.find.mockResolvedValue([
        { id: 'b-1', name: 'Groceries', userId: 'user-1' },
        { id: 'b-2', name: 'Rent', userId: 'user-9' },
      ]);

      const result = await service.getMine('user-1');

      expect(result.sharedBudgets).toEqual([
        { id: 'b-1', name: 'Groceries', ownerId: 'user-1' },
        { id: 'b-2', name: 'Rent', ownerId: 'user-9' },
      ]);
    });

    it('should include the active invite for an admin only', async () => {
      inGroupAs(GroupRole.ADMIN);
      inviteRepo.findOne.mockResolvedValue({ code: 'RF4XK2', expiresAt: new Date('2026-02-01T00:00:00Z') });

      expect((await service.getMine('user-1')).invite).toEqual({ code: 'RF4XK2', expiresAt: '2026-02-01T00:00:00.000Z' });

      for (const role of [GroupRole.MEMBER, GroupRole.VIEWER]) {
        inGroupAs(role);
        expect((await service.getMine('user-1')).invite).toBeNull();
      }
    });

    it('should ignore an expired invite by asking only for unexpired ones', async () => {
      inGroupAs(GroupRole.ADMIN);
      inviteRepo.findOne.mockResolvedValue(null);

      expect((await service.getMine('user-1')).invite).toBeNull();
      const where = (inviteRepo.findOne.mock.calls[0][0] as { where: { expiresAt: { type: string } } }).where;
      expect(where.expiresAt.type).toBe('moreThan');
    });
  });

  describe('createInvite', () => {
    afterEach(() => jest.useRealTimers());

    it('should delete the old codes before inserting the new one', async () => {
      await service.createInvite('group-1', 'user-1');

      expect(manager.delete).toHaveBeenCalledWith(GroupInvite, { groupId: 'group-1' });
      expect(manager.delete.mock.invocationCallOrder[0]).toBeLessThan(manager.insert.mock.invocationCallOrder[0]);
    });

    it('should make the code work for 48 hours', async () => {
      jest.useFakeTimers({ now: new Date('2026-03-01T10:00:00Z') });

      const invite = await service.createInvite('group-1', 'user-1');

      expect(invite.expiresAt).toBe('2026-03-03T10:00:00.000Z');
      expect(manager.insert).toHaveBeenCalledWith(
        GroupInvite,
        expect.objectContaining({ groupId: 'group-1', createdBy: 'user-1', code: invite.code }),
      );
    });

    it('should retry with a new code when the code is taken', async () => {
      manager.insert.mockRejectedValueOnce({ code: '23505' }).mockResolvedValueOnce(undefined);

      await service.createInvite('group-1', 'user-1');

      expect(dataSource.transaction).toHaveBeenCalledTimes(2);
    });

    it('should give up after 5 clashes', async () => {
      manager.insert.mockRejectedValue({ code: '23505' });

      await expect(service.createInvite('group-1', 'user-1')).rejects.toEqual({ code: '23505' });
      expect(dataSource.transaction).toHaveBeenCalledTimes(5);
    });
  });

  describe('join', () => {
    const dto = { code: 'RF4XK2', currencyCode: 'BDT' };
    const future = new Date(Date.now() + 60_000);

    const setUp = (opts: { inGroup?: boolean; invite?: object | null; currency?: string; members?: number } = {}) => {
      manager.exists.mockResolvedValue(opts.inGroup ?? false);
      manager.findOne.mockImplementation((entity: unknown) => {
        if (entity === GroupInvite) {
          return Promise.resolve(opts.invite === undefined ? { code: 'RF4XK2', groupId: 'group-1', expiresAt: future } : opts.invite);
        }
        return Promise.resolve({ id: 'group-1', currencyCode: opts.currency ?? 'BDT' });
      });
      manager.count.mockResolvedValue(opts.members ?? 1);
      memberRepo.findOne.mockResolvedValue(null);
    };

    const codeOf = async (promise: Promise<unknown>) => {
      const error = (await promise.catch((e: unknown) => e)) as HttpException;
      return (error.getResponse() as { code: string }).code;
    };

    it('should add the caller as a member and leave the invite in place', async () => {
      setUp();

      await service.join('user-2', dto);

      expect(manager.insert).toHaveBeenCalledWith(GroupMember, { groupId: 'group-1', userId: 'user-2', role: GroupRole.MEMBER });
      expect(manager.delete).not.toHaveBeenCalled();
    });

    it('should lock the group row before counting members', async () => {
      setUp();

      await service.join('user-2', dto);

      expect(manager.findOne).toHaveBeenCalledWith(Group, { where: { id: 'group-1' }, lock: { mode: 'pessimistic_write' } });
    });

    it('should reject a caller already in a group first', async () => {
      setUp({ inGroup: true, invite: null });

      expect(await codeOf(service.join('user-2', dto))).toBe('ALREADY_IN_GROUP');
    });

    it('should reject an unknown code with 404', async () => {
      setUp({ invite: null });
      const promise = service.join('user-2', dto);

      await expect(promise).rejects.toBeInstanceOf(NotFoundException);
      expect(await codeOf(promise)).toBe('INVITE_NOT_FOUND');
    });

    it('should treat a code expiring exactly now as expired (410)', async () => {
      jest.useFakeTimers({ now: new Date('2026-03-01T10:00:00Z') });
      setUp({ invite: { code: 'RF4XK2', groupId: 'group-1', expiresAt: new Date('2026-03-01T10:00:00Z') } });
      const promise = service.join('user-2', dto);

      await expect(promise).rejects.toBeInstanceOf(GoneException);
      expect(await codeOf(promise)).toBe('INVITE_EXPIRED');
      jest.useRealTimers();
    });

    it('should reject another currency and name the group currency', async () => {
      setUp({ currency: 'USD' });

      const error = (await service.join('user-2', dto).catch((e: unknown) => e)) as HttpException;

      expect(error.getResponse()).toEqual(expect.objectContaining({ code: 'CURRENCY_MISMATCH', groupCurrency: 'USD' }));
    });

    it('should reject a full group of 10 and still let a ninth member join', async () => {
      setUp({ members: 10 });
      expect(await codeOf(service.join('user-2', dto))).toBe('GROUP_FULL');

      setUp({ members: 9 });
      await expect(service.join('user-2', dto)).resolves.toBeDefined();
    });

    it('should check currency before the member cap', async () => {
      setUp({ currency: 'USD', members: 10 });

      expect(await codeOf(service.join('user-2', dto))).toBe('CURRENCY_MISMATCH');
    });

    it('should map a unique violation from a concurrent join to ALREADY_IN_GROUP', async () => {
      setUp();
      manager.insert.mockRejectedValue({ driverError: { code: '23505' } });

      expect(await codeOf(service.join('user-2', dto))).toBe('ALREADY_IN_GROUP');
    });
  });

  describe('updateRole', () => {
    const codeOf = async (promise: Promise<unknown>) =>
      (((await promise.catch((e: unknown) => e)) as HttpException).getResponse() as { code: string }).code;

    it('should change the role', async () => {
      const target = { groupId: 'group-1', userId: 'user-2', role: GroupRole.MEMBER };
      manager.findOne.mockResolvedValue(target);

      await service.updateRole('group-1', 'user-2', { role: GroupRole.VIEWER }, 'user-1');

      expect(manager.save).toHaveBeenCalledWith({ ...target, role: GroupRole.VIEWER });
    });

    it('should answer NOT_IN_GROUP when the target is not a member', async () => {
      manager.findOne.mockResolvedValue(null);

      expect(await codeOf(service.updateRole('group-1', 'user-9', { role: GroupRole.VIEWER }, 'user-1'))).toBe('NOT_IN_GROUP');
    });

    it('should refuse to demote the only admin with LAST_ADMIN', async () => {
      manager.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', role: GroupRole.ADMIN });
      manager.count.mockResolvedValue(1);

      expect(await codeOf(service.updateRole('group-1', 'user-1', { role: GroupRole.MEMBER }, 'user-1'))).toBe('LAST_ADMIN');
      expect(manager.save).not.toHaveBeenCalled();
    });

    it('should let an admin step down when another admin exists', async () => {
      manager.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', role: GroupRole.ADMIN });
      manager.count.mockResolvedValue(2);

      await service.updateRole('group-1', 'user-1', { role: GroupRole.MEMBER }, 'user-1');

      expect(manager.save).toHaveBeenCalledWith(expect.objectContaining({ role: GroupRole.MEMBER }));
    });
  });

  describe('removeMember', () => {
    const caller = (userId: string, role: GroupRole) => ({ groupId: 'group-1', userId, role }) as GroupMember;

    beforeEach(() => {
      manager.exists.mockResolvedValue(true);
      manager.delete.mockResolvedValue({ affected: 1 });
      manager.count.mockResolvedValue(1);
    });

    it.each([GroupRole.MEMBER, GroupRole.VIEWER])('should let a %s leave', async (role) => {
      await service.removeMember('group-1', 'user-2', caller('user-2', role));

      expect(manager.delete).toHaveBeenCalledWith(GroupMember, { groupId: 'group-1', userId: 'user-2' });
    });

    it('should let an admin remove a member', async () => {
      await service.removeMember('group-1', 'user-2', caller('user-1', GroupRole.ADMIN));

      expect(manager.delete).toHaveBeenCalledWith(GroupMember, { groupId: 'group-1', userId: 'user-2' });
    });

    it('should forbid a member removing someone else', async () => {
      await expect(service.removeMember('group-1', 'user-3', caller('user-2', GroupRole.MEMBER))).rejects.toBeInstanceOf(
        ForbiddenException,
      );
      expect(manager.delete).not.toHaveBeenCalled();
    });

    it('should answer NOT_IN_GROUP when the target is not in the group', async () => {
      manager.exists.mockResolvedValue(false);

      await expect(service.removeMember('group-1', 'user-9', caller('user-1', GroupRole.ADMIN))).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });

  describe('applyLeaveRules', () => {
    const run = () => service.applyLeaveRules(manager as never, 'group-1', 'user-1');
    const queries = () => manager.query.mock.calls as [string, string[]][];

    beforeEach(() => manager.delete.mockResolvedValue({ affected: 1 }));

    it('should detach only the leaver budgets in that group and bump updatedAt', async () => {
      manager.count.mockResolvedValue(2);

      await run();

      const [sql, params] = queries()[0];
      expect(sql).toContain('SET "groupId" = NULL, "updatedAt" = now()');
      expect(sql).toContain('"userId" = $2');
      expect(params).toEqual(['group-1', 'user-1']);
    });

    it('should promote the member who joined first when the last admin leaves', async () => {
      manager.count.mockImplementation((_e: unknown, opts: { where: { role?: GroupRole } }) =>
        Promise.resolve(opts.where.role ? 0 : 2),
      );
      const oldest = { groupId: 'group-1', userId: 'user-2', role: GroupRole.MEMBER };
      manager.findOne.mockResolvedValue(oldest);

      await run();

      expect(manager.findOne).toHaveBeenCalledWith(GroupMember, { where: { groupId: 'group-1' }, order: { joinedAt: 'ASC' } });
      expect(manager.save).toHaveBeenCalledWith({ ...oldest, role: GroupRole.ADMIN });
    });

    it('should not promote anyone while an admin remains', async () => {
      manager.count.mockResolvedValue(1);

      await run();

      expect(manager.save).not.toHaveBeenCalled();
    });

    it('should delete the group and detach all its budgets when the last member leaves', async () => {
      manager.count.mockResolvedValue(0);

      await run();

      const [sql, params] = queries()[1];
      expect(sql).not.toContain('"userId"');
      expect(params).toEqual(['group-1']);
      expect(manager.delete).toHaveBeenLastCalledWith(Group, { id: 'group-1' });
    });

    it('should do nothing for a non-member', async () => {
      manager.delete.mockResolvedValue({ affected: 0 });

      await run();

      expect(manager.query).not.toHaveBeenCalled();
      expect(manager.count).not.toHaveBeenCalled();
    });
  });

  describe('deleteGroup', () => {
    it('should detach every shared budget before deleting the group', async () => {
      await service.deleteGroup('group-1');

      expect(manager.query.mock.calls[0][1]).toEqual(['group-1']);
      expect(manager.query.mock.invocationCallOrder[0]).toBeLessThan(manager.delete.mock.invocationCallOrder[0]);
      expect(manager.delete).toHaveBeenCalledWith(Group, { id: 'group-1' });
    });
  });
});
