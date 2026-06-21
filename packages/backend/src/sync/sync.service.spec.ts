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

// TypeORM entities are strict — mock data bypasses field requirements
type AnyRepo = jest.Mocked<any>;

describe('SyncService', () => {
  let service: SyncService;
  let recordRepo: AnyRepo;

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
});
