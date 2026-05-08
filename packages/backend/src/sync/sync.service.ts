import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, In } from 'typeorm';
import { PushSyncDto, SyncAction, SyncTable } from './dto/push-sync.dto';
import { Record } from '../records/entities/record.entity';
import { Category } from '../categories/entities/category.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { MessageSource } from '../message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../expense-templates/entities/expense-template.entity';
import { ParsingRule } from '../parsing-rules/entities/parsing-rule.entity';
import { RecurringTransaction } from '../recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../recurring-transactions/entities/pending-recurring.entity';

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);
  private readonly repoMap: Map<SyncTable, Repository<any>> = new Map();

  constructor(
    @InjectRepository(Record) recordRepo: Repository<Record>,
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

  async pushChanges(userId: string, dto: PushSyncDto) {
    const results: any[] = [];
    for (const change of dto.changes) {
      try {
        const repo = this.repoMap.get(change.table);
        if (!repo) throw new BadRequestException(`Unknown table: ${change.table}`);

        if (change.action === SyncAction.INSERT) {
          const existing = await repo.findOne({ where: { id: change.id } });
          if (existing) { results.push({ id: change.id, status: 'success', serverId: existing.id, message: 'Already exists' }); continue; }
          const entity = repo.create({ ...change.data, id: change.id, userId, createdAt: new Date(), updatedAt: new Date() });
          await repo.save(entity);
          results.push({ id: change.id, status: 'success', serverId: entity.id });
        } else if (change.action === SyncAction.UPDATE) {
          const existing = await repo.findOne({ where: { id: change.id } });
          if (!existing) {
            const entity = repo.create({ ...change.data, id: change.id, userId, createdAt: new Date(), updatedAt: new Date() });
            await repo.save(entity);
            results.push({ id: change.id, status: 'success', serverId: entity.id }); continue;
          }
          if (change.updatedAt && existing.updatedAt && new Date(change.updatedAt) < existing.updatedAt) {
            results.push({ id: change.id, status: 'conflict', serverId: existing.id, message: 'Server version newer' }); continue;
          }
          Object.assign(existing, change.data || {}, { userId, updatedAt: new Date() });
          await repo.save(existing);
          results.push({ id: change.id, status: 'success', serverId: existing.id });
        } else if (change.action === SyncAction.DELETE) {
          await repo.delete({ id: change.id, userId });
          results.push({ id: change.id, status: 'success' });
        }
      } catch (error: any) {
        this.logger.error(`Push error for ${change.table}/${change.id}: ${error.message}`);
        results.push({ id: change.id, status: 'error', message: error.message });
      }
    }
    return { results };
  }

  async pullChanges(userId: string, since?: string) {
    const sinceDate = since ? new Date(since) : new Date(0);
    const changes: any[] = [];
    for (const [table, repo] of this.repoMap) {
      const entities = await repo.find({ where: { userId, updatedAt: MoreThan(sinceDate) } });
      for (const entity of entities) {
        const { userId: _, user, ...data } = entity;
        changes.push({ table, action: 'insert', id: entity.id, data, updatedAt: entity.updatedAt?.toISOString() });
      }
    }
    return { changes, serverTime: new Date().toISOString() };
  }

  async getSummary(userId: string) {
    let totalCount = 0;
    const tables: { [key: string]: number } = {};
    for (const [table, repo] of this.repoMap) {
      const count = await repo.count({ where: { userId } });
      tables[table] = count;
      totalCount += count;
    }
    return { totalCount, tables };
  }

  async clearUserData(userId: string) {
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
