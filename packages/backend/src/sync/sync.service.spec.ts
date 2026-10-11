import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { SyncService } from './sync.service';
import { Record as RecordEntity } from '../records/entities/record.entity';
import { Category } from '../categories/entities/category.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { MessageSource } from '../message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../expense-templates/entities/expense-template.entity';
import { ParsingRule } from '../parsing-rules/entities/parsing-rule.entity';
import { RecurringTransaction } from '../recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../recurring-transactions/entities/pending-recurring.entity';
import { SyncAction, SyncTable } from './dto/push-sync.dto';
import { SyncStatus } from './sync.types';
import { BudgetPeriod } from '../common/enums/budget-period.enum';
import { DEFAULT_BUDGET_NAME } from '../budgets/budgets.constants';

// TypeORM entities are strict — mock data bypasses field requirements
type AnyRepo = jest.Mocked<any>;

describe('SyncService', () => {
  let service: SyncService;
  let recordRepo: AnyRepo;
  let budgetRepo: AnyRepo;

  const mockRepo = () => ({
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    delete: jest.fn(),
    find: jest.fn().mockResolvedValue([]),
    count: jest.fn().mockResolvedValue(0),
  });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SyncService,
        { provide: getRepositoryToken(RecordEntity), useFactory: mockRepo },
        { provide: getRepositoryToken(Category), useFactory: mockRepo },
        { provide: getRepositoryToken(Budget), useFactory: mockRepo },
        { provide: getRepositoryToken(MessageSource), useFactory: mockRepo },
        { provide: getRepositoryToken(ExpenseTemplate), useFactory: mockRepo },
        { provide: getRepositoryToken(ParsingRule), useFactory: mockRepo },
        { provide: getRepositoryToken(RecurringTransaction), useFactory: mockRepo },
        { provide: getRepositoryToken(PendingRecurring), useFactory: mockRepo },
      ],
    }).compile();

    service = module.get<SyncService>(SyncService);
    recordRepo = module.get(getRepositoryToken(RecordEntity));
    budgetRepo = module.get(getRepositoryToken(Budget));
  });

  describe('handleUpdate', () => {
    it('should strip id and createdAt from change.data before Object.assign', async () => {
      const existingEntity = {
        id: 'rec-1',
        userId: 'user-1',
        amount: 50.0,
        description: 'old desc',
        createdAt: new Date('2025-01-01'),
        updatedAt: new Date('2025-01-01'),
      };

      recordRepo.findOne.mockResolvedValue(existingEntity);
      recordRepo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      const change = {
        table: SyncTable.RECORDS,
        action: SyncAction.UPDATE,
        id: 'rec-1',
        data: {
          id: 'malicious-id',
          userId: 'malicious-user',
          createdAt: 'evil-date',
          amount: 99.99,
          description: 'updated desc',
        },
        updatedAt: '2025-06-01T00:00:00.000Z',
      };

      const result = await (service as any).handleUpdate(
        recordRepo,
        change,
        'user-1',
      );

      expect(result.status).toBe(SyncStatus.SUCCESS);

      const savedEntity = recordRepo.save.mock.calls[0][0];
      expect(savedEntity.id).toBe('rec-1');
      expect(savedEntity.userId).toBe('user-1');
      expect(savedEntity.createdAt).toEqual(new Date('2025-01-01'));
      expect(savedEntity.amount).toBe(99.99);
      expect(savedEntity.description).toBe('updated desc');
    });

    it('should handle null/undefined change.data gracefully', async () => {
      const existingEntity = {
        id: 'rec-1',
        userId: 'user-1',
        createdAt: new Date('2025-01-01'),
        updatedAt: new Date('2025-01-01'),
      };

      recordRepo.findOne.mockResolvedValue(existingEntity);
      recordRepo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      const change = {
        table: SyncTable.RECORDS,
        action: SyncAction.UPDATE,
        id: 'rec-1',
        data: null,
        updatedAt: '2025-06-01T00:00:00.000Z',
      };

      const result = await (service as any).handleUpdate(
        recordRepo,
        change,
        'user-1',
      );

      expect(result.status).toBe(SyncStatus.SUCCESS);
    });
  });

  describe('pullChanges', () => {
    it('should not include userId or user in returned data', async () => {
      const entity = {
        id: 'rec-1',
        userId: 'user-1',
        user: { id: 'user-1', firebaseUid: 'fb-uid' },
        amount: 42.0,
        description: 'test',
        date: new Date('2025-06-01'),
        recordType: 'OUT',
        source: 'manual',
        sourceId: null,
        categoryId: null,
        createdAt: new Date('2025-06-01'),
        updatedAt: new Date('2025-06-01'),
      };

      recordRepo.find.mockResolvedValue([entity]);

      const result = await service.pullChanges('user-1');

      expect(result.changes).toHaveLength(1);
      const change = result.changes[0];
      expect(change.data).not.toHaveProperty('userId');
      expect(change.data).not.toHaveProperty('user');
      expect(change.data).toHaveProperty('amount', 42.0);
      expect(change.data).toHaveProperty('description', 'test');
    });

    it('should return serverTime in ISO format', async () => {
      recordRepo.find.mockResolvedValue([]);

      const result = await service.pullChanges('user-1');

      expect(result.serverTime).toBeDefined();
      expect(() => new Date(result.serverTime)).not.toThrow();
    });
  });

  describe('pushChanges', () => {
    const pushBudget = (data: Record<string, unknown>, action = SyncAction.INSERT) =>
      service.pushChanges('user-1', {
        changes: [{ table: SyncTable.BUDGETS, action, id: 'bud-1', data }],
      });

    const budgetData = {
      name: 'Groceries',
      amount: 400,
      period: BudgetPeriod.MONTHLY,
      startDate: '2026-10-01T00:00:00.000Z',
    };

    beforeEach(() => {
      budgetRepo.findOne.mockResolvedValue(null);
      budgetRepo.create.mockImplementation((data: any) => ({ ...data }));
      budgetRepo.save.mockImplementation((entity: any) => Promise.resolve(entity));
    });

    it('should return the pushed budget name on pull', async () => {
      const stored: any[] = [];
      budgetRepo.save.mockImplementation((entity: any) => {
        stored.push(entity);
        return Promise.resolve(entity);
      });
      budgetRepo.find.mockImplementation(() => Promise.resolve(stored));

      await pushBudget(budgetData);
      const result = await service.pullChanges('user-1');

      const budget = result.changes.find((c) => c.table === SyncTable.BUDGETS);
      expect(budget?.data).toHaveProperty('name', 'Groceries');
    });

    it.each([null, ''])('should store the default name when a new budget has name %p', async (name) => {
      const result = await pushBudget({ ...budgetData, name });

      expect(result.results[0].status).toBe(SyncStatus.SUCCESS);
      expect(budgetRepo.create).toHaveBeenCalledWith(expect.objectContaining({ name: DEFAULT_BUDGET_NAME }));
    });

    it.each([null, '', '   ', DEFAULT_BUDGET_NAME])('should keep the stored budget name when an update sends name %p', async (name) => {
      const existing = { id: 'bud-1', userId: 'user-1', name: 'Groceries', updatedAt: new Date('2025-01-01') };
      budgetRepo.findOne.mockResolvedValue(existing);

      await pushBudget({ name, amount: 500 }, SyncAction.UPDATE);

      expect(budgetRepo.save).toHaveBeenCalledWith(expect.objectContaining({ name: 'Groceries', amount: 500 }));
    });

    it.each([null, ''])('should store the default name when an update creates a budget with name %p', async (name) => {
      await pushBudget({ ...budgetData, name }, SyncAction.UPDATE);

      expect(budgetRepo.create).toHaveBeenCalledWith(expect.objectContaining({ name: DEFAULT_BUDGET_NAME }));
    });

    it('should not apply budget defaults to other tables', async () => {
      recordRepo.findOne.mockResolvedValue(null);
      recordRepo.create.mockImplementation((data: any) => ({ ...data }));
      recordRepo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      await service.pushChanges('user-1', {
        changes: [{ table: SyncTable.RECORDS, action: SyncAction.INSERT, id: 'rec-1', data: { name: null, description: '' } }],
      });

      expect(recordRepo.create).toHaveBeenCalledWith(expect.objectContaining({ name: null, description: '' }));
    });

    it('should leave a missing name to the column default', async () => {
      const { name: _name, ...withoutName } = budgetData;

      await pushBudget(withoutName);

      expect(budgetRepo.create).toHaveBeenCalledWith(expect.not.objectContaining({ name: expect.anything() }));
    });
  });
});
