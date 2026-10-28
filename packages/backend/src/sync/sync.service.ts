import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, Not } from 'typeorm';
import { PushSyncDto, SyncAction, SyncChangeItem, SyncTable } from './dto/push-sync.dto';
import { SyncStatus, SyncActionResult, SyncConflictResult, PullChange, PullChangesResponse, SyncSummary, SyncPushResponse } from './sync.types';
import { Record as RecordEntity } from '../records/entities/record.entity';
import { Category } from '../categories/entities/category.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { MessageSource } from '../message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../expense-templates/entities/expense-template.entity';
import { RecurringTransaction } from '../recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../recurring-transactions/entities/pending-recurring.entity';
import { Goal } from '../goals/entities/goal.entity';
import { SyncableEntity } from '../common/interfaces/syncable-entity.interface';
import { DEFAULT_BUDGET_NAME } from '../budgets/budgets.constants';
import { GroupMember } from '../groups/entities/group-member.entity';
import { GroupRole } from '../groups/groups.constants';


const REQUIRED_FIELD_DEFAULTS: Partial<Record<SyncTable, Record<string, unknown>>> = {
  [SyncTable.BUDGETS]: { name: DEFAULT_BUDGET_NAME },
};

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);
  private readonly repoMap: Map<SyncTable, Repository<SyncableEntity>> = new Map();

  constructor(
    @InjectRepository(RecordEntity) recordRepo: Repository<RecordEntity>,
    @InjectRepository(Category) categoryRepo: Repository<Category>,
    @InjectRepository(Budget) private readonly budgetRepo: Repository<Budget>,
    @InjectRepository(MessageSource) msgRepo: Repository<MessageSource>,
    @InjectRepository(ExpenseTemplate) tmplRepo: Repository<ExpenseTemplate>,
    @InjectRepository(RecurringTransaction) recRepo: Repository<RecurringTransaction>,
    @InjectRepository(PendingRecurring) pendRepo: Repository<PendingRecurring>,
    @InjectRepository(Goal) goalRepo: Repository<Goal>,
    
    @InjectRepository(GroupMember) private readonly memberRepo: Repository<GroupMember>,
  ) {
    this.repoMap.set(SyncTable.RECORDS, recordRepo);
    this.repoMap.set(SyncTable.CATEGORIES, categoryRepo);
    this.repoMap.set(SyncTable.BUDGETS, budgetRepo);
    this.repoMap.set(SyncTable.MESSAGE_SOURCES, msgRepo);
    this.repoMap.set(SyncTable.EXPENSE_TEMPLATES, tmplRepo);
    this.repoMap.set(SyncTable.RECURRING_TRANSACTIONS, recRepo);
    this.repoMap.set(SyncTable.PENDING_RECURRING, pendRepo);
    
    
    this.repoMap.set(SyncTable.GOALS, goalRepo);
  }

  async pushChanges(userId: string, dto: PushSyncDto): Promise<SyncPushResponse> {
    const results: SyncActionResult[] = [];
    for (const change of dto.changes) {
      try {
        const repo = this.repoMap.get(change.table);
        if (!repo) throw new BadRequestException(`Unknown table: ${change.table}`);

        let result: SyncActionResult;
        switch (change.action) {
          case SyncAction.INSERT:
            result = await this.handleInsert(repo, change, userId);
            break;
          case SyncAction.UPDATE:
            result = await this.handleUpdate(repo, change, userId);
            break;
          case SyncAction.DELETE:
            result = await this.handleDelete(repo, change, userId);
            break;
          default:
            throw new BadRequestException(`Unknown action: ${String(change.action)}`);
        }
        results.push(result);
      } catch (error: unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        this.logger.error(`Push error for ${change.table}/${change.id}: ${message}`);
        results.push({ id: change.id, status: SyncStatus.ERROR, message });
      }
    }
    return { results };
  }

  private async handleInsert(repo: Repository<SyncableEntity>, change: SyncChangeItem, userId: string): Promise<SyncActionResult> {
    const existing = await repo.findOne({ where: { id: change.id, userId } });
    if (existing) {
      return { id: change.id, status: SyncStatus.SUCCESS, serverId: existing.id, message: 'Already exists' };
    }
    const conflict = await this.notOwner(repo, change);
    if (conflict) return conflict;
    return this.createRow(repo, await this.withAllowedGroupId(change, null, userId), userId);
  }

  private async createRow(repo: Repository<SyncableEntity>, change: SyncChangeItem, userId: string): Promise<SyncActionResult> {
    const entity = repo.create({ ...this.withRequiredDefaults(change), id: change.id, userId, createdAt: new Date(), updatedAt: new Date() });
    await repo.save(entity);
    return { id: change.id, status: SyncStatus.SUCCESS, serverId: entity.id };
  }

  private async handleUpdate(repo: Repository<SyncableEntity>, change: SyncChangeItem, userId: string): Promise<SyncActionResult> {
    const existing = await repo.findOne({ where: { id: change.id, userId } });
    if (!existing) {
      const conflict = await this.notOwner(repo, change);
      if (conflict) return conflict;
      return this.createRow(repo, await this.withAllowedGroupId(change, null, userId), userId);
    }
    if (change.updatedAt && existing.updatedAt && new Date(change.updatedAt) < existing.updatedAt) {
      return { id: change.id, status: SyncStatus.CONFLICT, serverId: existing.id, message: 'Server version newer' };
    }
    const allowed = await this.withAllowedGroupId(change, existing, userId);
    const { id: _id, userId: _userId, createdAt: _createdAt, ...updateData } = this.withoutBlankRequiredFields(allowed);
    Object.assign(existing, updateData, { userId, updatedAt: new Date() });
    await repo.save(existing);
    return { id: change.id, status: SyncStatus.SUCCESS, serverId: existing.id };
  }

  
  private async withAllowedGroupId(
    change: SyncChangeItem,
    existing: SyncableEntity | null,
    userId: string,
  ): Promise<SyncChangeItem> {
    
    if (change.table !== SyncTable.BUDGETS || !change.data || !('groupId' in change.data)) return change;
    const next = change.data.groupId ?? null;
    const current = (existing as Budget | null)?.groupId ?? null;
    if (next === current || next === null) return change;

    const member = typeof next === 'string' ? await this.memberRepo.findOne({ where: { userId } }) : null;
    if (member?.role === GroupRole.ADMIN && member.groupId === next) return change;

    this.logger.warn(`Dropped a groupId the caller may not set on budget ${change.id}`);
    const { groupId: _groupId, ...data } = change.data;
    return { ...change, data: existing ? data : { ...data, groupId: null } };
  }

  private withRequiredDefaults(change: SyncChangeItem): Record<string, unknown> {
    const data = { ...(change.data ?? {}) };
    for (const [field, fallback] of Object.entries(REQUIRED_FIELD_DEFAULTS[change.table] ?? {})) {
      if (this.isBlank(data, field)) data[field] = fallback;
    }
    return data;
  }

  private withoutBlankRequiredFields(change: SyncChangeItem): Record<string, unknown> {
    const data = { ...(change.data ?? {}) };
    for (const [field, fallback] of Object.entries(REQUIRED_FIELD_DEFAULTS[change.table] ?? {})) {
      if (this.isBlank(data, field) || data[field] === fallback) delete data[field];
    }
    return data;
  }

  private isBlank(data: Record<string, unknown>, field: string): boolean {
    const value = data[field];
    return field in data && (value === null || (typeof value === 'string' && value.trim() === ''));
  }

  private async handleDelete(repo: Repository<SyncableEntity>, change: SyncChangeItem, userId: string): Promise<SyncActionResult> {
    const result = await repo.delete({ id: change.id, userId });
    if ((result?.affected ?? 0) === 0) {
      const conflict = await this.notOwner(repo, change);
      if (conflict) return conflict;
    }
    return { id: change.id, status: SyncStatus.SUCCESS };
  }

  
  private async notOwner(repo: Repository<SyncableEntity>, change: SyncChangeItem): Promise<SyncConflictResult | null> {
    if (!(await repo.exists({ where: { id: change.id } }))) return null;
    return { id: change.id, status: SyncStatus.CONFLICT, serverId: change.id, message: 'Not the owner' };
  }

  async pullChanges(userId: string, since?: string): Promise<PullChangesResponse> {
    const sinceDate = since ? new Date(since) : new Date(0);
    const changes: PullChangesResponse['changes'] = [];
    for (const [table, repo] of this.repoMap) {
      const entities = await repo.find({ where: { userId, updatedAt: MoreThan(sinceDate) } });
      for (const entity of entities) changes.push(this.toPullChange(table, entity));
    }
    for (const budget of await this.pullSharedBudgets(userId, sinceDate)) {
      changes.push(this.toPullChange(SyncTable.BUDGETS, budget));
    }
    return { changes, serverTime: new Date().toISOString() };
  }

  
  private async pullSharedBudgets(userId: string, since: Date): Promise<Budget[]> {
    const member = await this.memberRepo.findOne({ where: { userId } });
    if (!member) return [];
    const joinedSince = member.joinedAt > since;
    return this.budgetRepo.find({
      where: {
        groupId: member.groupId,
        userId: Not(userId),
        ...(joinedSince ? {} : { updatedAt: MoreThan(since) }),
      },
    });
  }

  private toPullChange(table: SyncTable, entity: SyncableEntity): PullChange {
    
    const { userId: _userId, user: _user, group: _group, ...data } = entity as SyncableEntity & {
      user?: unknown;
      group?: unknown;
    };
    return { table, action: SyncAction.INSERT, id: entity.id, data, updatedAt: entity.updatedAt?.toISOString() };
  }

  async getSummary(userId: string): Promise<SyncSummary> {
    let totalCount = 0;
    const tables: { [key: string]: number } = {};
    for (const [table, repo] of this.repoMap) {
      const count = await repo.count({ where: { userId } });
      tables[table] = count;
      totalCount += count;
    }
    return { totalCount, tables };
  }

  
  async clearUserData(userId: string): Promise<void> {
    const deletionOrder: SyncTable[] = [
      SyncTable.PENDING_RECURRING,
      SyncTable.RECURRING_TRANSACTIONS,
      SyncTable.EXPENSE_TEMPLATES,
      SyncTable.MESSAGE_SOURCES,
      SyncTable.GOALS,
      SyncTable.BUDGETS,
      SyncTable.RECORDS,
      SyncTable.CATEGORIES,
    ];
    for (const table of deletionOrder) {
      const repo = this.repoMap.get(table);
      if (repo) {
        await repo.delete({ userId });
      }
    }
  }
}
