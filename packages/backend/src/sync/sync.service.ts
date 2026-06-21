import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { PushSyncDto, SyncAction, SyncChangeItem, SyncTable } from './dto/push-sync.dto';
import { SyncStatus, SyncActionResult, PullChangesResponse, SyncSummary, SyncPushResponse } from './sync.types';
import { Record as RecordEntity } from '../records/entities/record.entity';
import { Category } from '../categories/entities/category.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { MessageSource } from '../message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../expense-templates/entities/expense-template.entity';
import { ParsingRule } from '../parsing-rules/entities/parsing-rule.entity';
import { RecurringTransaction } from '../recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../recurring-transactions/entities/pending-recurring.entity';
import { SyncableEntity } from '../common/interfaces/syncable-entity.interface';

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);
  private readonly repoMap: Map<SyncTable, Repository<SyncableEntity>> = new Map();

  constructor(
    @InjectRepository(RecordEntity) recordRepo: Repository<RecordEntity>,
    @InjectRepository(Category) categoryRepo: Repository<Category>,
    @InjectRepository(Budget) budgetRepo: Repository<Budget>,
    @InjectRepository(MessageSource) msgRepo: Repository<MessageSource>,
    @InjectRepository(ExpenseTemplate) tmplRepo: Repository<ExpenseTemplate>,
    @InjectRepository(ParsingRule) ruleRepo: Repository<ParsingRule>,
    @InjectRepository(RecurringTransaction) recRepo: Repository<RecurringTransaction>,
    @InjectRepository(PendingRecurring) pendRepo: Repository<PendingRecurring>,
  ) {
    this.repoMap.set(SyncTable.RECORDS, recordRepo);
    this.repoMap.set(SyncTable.CATEGORIES, categoryRepo);
    this.repoMap.set(SyncTable.BUDGETS, budgetRepo);
    this.repoMap.set(SyncTable.MESSAGE_SOURCES, msgRepo);
    this.repoMap.set(SyncTable.EXPENSE_TEMPLATES, tmplRepo);
    this.repoMap.set(SyncTable.PARSING_RULES, ruleRepo);
    this.repoMap.set(SyncTable.RECURRING_TRANSACTIONS, recRepo);
    this.repoMap.set(SyncTable.PENDING_RECURRING, pendRepo);
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
    const existing = await repo.findOne({ where: { id: change.id } });
    if (existing) {
      return { id: change.id, status: SyncStatus.SUCCESS, serverId: existing.id, message: 'Already exists' };
    }
    const entity = repo.create({ ...change.data, id: change.id, userId, createdAt: new Date(), updatedAt: new Date() });
    await repo.save(entity);
    return { id: change.id, status: SyncStatus.SUCCESS, serverId: entity.id };
  }

  private async handleUpdate(repo: Repository<SyncableEntity>, change: SyncChangeItem, userId: string): Promise<SyncActionResult> {
    const existing = await repo.findOne({ where: { id: change.id } });
    if (!existing) {
      const entity = repo.create({ ...change.data, id: change.id, userId, createdAt: new Date(), updatedAt: new Date() });
      await repo.save(entity);
      return { id: change.id, status: SyncStatus.SUCCESS, serverId: entity.id };
    }
    if (change.updatedAt && existing.updatedAt && new Date(change.updatedAt) < existing.updatedAt) {
      return { id: change.id, status: SyncStatus.CONFLICT, serverId: existing.id, message: 'Server version newer' };
    }
    const { id: _id, createdAt: _createdAt, ...updateData } = (change.data ?? {}) as Record<string, unknown>;
    Object.assign(existing, updateData, { userId, updatedAt: new Date() });
    await repo.save(existing);
    return { id: change.id, status: SyncStatus.SUCCESS, serverId: existing.id };
  }

  private async handleDelete(repo: Repository<SyncableEntity>, change: SyncChangeItem, userId: string): Promise<SyncActionResult> {
    await repo.delete({ id: change.id, userId });
    return { id: change.id, status: SyncStatus.SUCCESS };
  }

  async pullChanges(userId: string, since?: string): Promise<PullChangesResponse> {
    const sinceDate = since ? new Date(since) : new Date(0);
    const changes: PullChangesResponse['changes'] = [];
    for (const [table, repo] of this.repoMap) {
      const entities = await repo.find({ where: { userId, updatedAt: MoreThan(sinceDate) } });
      for (const entity of entities) {
        const { userId: _userId, user: _user, ...data } = entity as SyncableEntity & { user?: unknown };
        changes.push({ table, action: SyncAction.INSERT, id: entity.id, data, updatedAt: entity.updatedAt?.toISOString() });
      }
    }
    return { changes, serverTime: new Date().toISOString() };
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
      SyncTable.PARSING_RULES,
      SyncTable.MESSAGE_SOURCES,
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
