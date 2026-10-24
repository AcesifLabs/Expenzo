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
import { Goal } from '../goals/entities/goal.entity';
import { GroupMember } from '../groups/entities/group-member.entity';
import { GroupRole } from '../groups/groups.constants';
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
  let memberRepo: AnyRepo;
  let module: TestingModule;

  const mockRepo = () => ({
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    delete: jest.fn(),
    exists: jest.fn().mockResolvedValue(false),
    find: jest.fn().mockResolvedValue([]),
    count: jest.fn().mockResolvedValue(0),
  });

  beforeEach(async () => {
    module = await Test.createTestingModule({
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
        { provide: getRepositoryToken(Goal), useFactory: mockRepo },
        { provide: getRepositoryToken(GroupMember), useFactory: mockRepo },
      ],
    }).compile();

    service = module.get<SyncService>(SyncService);
    recordRepo = module.get(getRepositoryToken(RecordEntity));
    budgetRepo = module.get(getRepositoryToken(Budget));
    memberRepo = module.get(getRepositoryToken(GroupMember));
  });

  describe('clearUserData', () => {
    it('should delete only the caller rows and leave group tables alone', async () => {
      await service.clearUserData('user-1');

      for (const repo of [recordRepo, budgetRepo]) {
        for (const [where] of repo.delete.mock.calls as [unknown][]) expect(where).toEqual({ userId: 'user-1' });
      }
      expect(memberRepo.delete).not.toHaveBeenCalled();
    });
  });

  describe('budget groupId rule', () => {
    const own = (groupId: string | null) => ({ id: 'bud-1', userId: 'user-1', amount: 100, groupId, updatedAt: new Date(0) });
    const push = (action: SyncAction, data: Record<string, unknown>) =>
      service.pushChanges('user-1', { changes: [{ table: SyncTable.BUDGETS, action, id: 'bud-1', data }] });
    const as = (role: GroupRole | null, groupId = 'group-1') =>
      memberRepo.findOne.mockResolvedValue(role ? { groupId, userId: 'user-1', role } : null);
    const saved = () => budgetRepo.save.mock.calls.at(-1)?.[0];

    beforeEach(() => budgetRepo.save.mockImplementation((e: unknown) => Promise.resolve(e)));

    it('should let an admin share into their own group', async () => {
      as(GroupRole.ADMIN);
      budgetRepo.findOne.mockResolvedValue(own(null));

      const { results } = await push(SyncAction.UPDATE, { groupId: 'group-1' });

      expect(results[0].status).toBe(SyncStatus.SUCCESS);
      expect(saved().groupId).toBe('group-1');
    });

    it.each([
      ['an admin sharing into another group', GroupRole.ADMIN, 'group-2'],
      ['a member', GroupRole.MEMBER, 'group-1'],
      ['a viewer', GroupRole.VIEWER, 'group-1'],
      ['a caller without a group', null, 'group-1'],
    ])('should keep the stored groupId for %s and still save the rest', async (_label, role, target) => {
      as(role);
      budgetRepo.findOne.mockResolvedValue(own(null));

      const { results } = await push(SyncAction.UPDATE, { groupId: target, amount: 250 });

      expect(results[0].status).toBe(SyncStatus.SUCCESS);
      expect(saved().groupId).toBeNull();
      expect(saved().amount).toBe(250);
    });

    it('should let a demoted owner unshare', async () => {
      as(GroupRole.MEMBER);
      budgetRepo.findOne.mockResolvedValue(own('group-1'));

      await push(SyncAction.UPDATE, { groupId: null });

      expect(saved().groupId).toBeNull();
      expect(memberRepo.findOne).not.toHaveBeenCalled();
    });

    it('should accept an unchanged groupId from a non-admin owner', async () => {
      as(GroupRole.MEMBER);
      budgetRepo.findOne.mockResolvedValue(own('group-1'));

      await push(SyncAction.UPDATE, { groupId: 'group-1', amount: 300 });

      expect(saved()).toEqual(expect.objectContaining({ groupId: 'group-1', amount: 300 }));
    });

    it('should keep the stored groupId when the key is absent', async () => {
      budgetRepo.findOne.mockResolvedValue(own('group-1'));

      await push(SyncAction.UPDATE, { amount: 300 });

      expect(saved().groupId).toBe('group-1');
    });

    it('should store NULL when an insert carries a groupId the caller may not set', async () => {
      as(GroupRole.MEMBER);
      budgetRepo.findOne.mockResolvedValue(null);
      budgetRepo.create.mockImplementation((d: unknown) => d);

      const { results } = await push(SyncAction.INSERT, { groupId: 'group-1', amount: 100 });

      expect(results[0].status).toBe(SyncStatus.SUCCESS);
      expect(saved().groupId).toBeNull();
    });

    it('should keep the groupId on an insert by the group admin', async () => {
      as(GroupRole.ADMIN);
      budgetRepo.findOne.mockResolvedValue(null);
      budgetRepo.create.mockImplementation((d: unknown) => d);

      await push(SyncAction.INSERT, { groupId: 'group-1', amount: 100 });

      expect(saved().groupId).toBe('group-1');
    });

    it('should never return an error status for this rule', async () => {
      as(null);
      budgetRepo.findOne.mockResolvedValue(own(null));

      const { results } = await push(SyncAction.UPDATE, { groupId: 'group-9' });

      expect(results[0].status).not.toBe(SyncStatus.ERROR);
    });
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

    it('should strip the group relation from budgets and keep groupId', async () => {
      budgetRepo.find.mockResolvedValue([
        {
          id: 'bud-1',
          userId: 'user-1',
          groupId: 'group-1',
          group: { id: 'group-1', name: 'Family' },
          updatedAt: new Date('2025-06-01'),
        },
      ]);

      const result = await service.pullChanges('user-1');

      const change = result.changes.find((c) => c.table === SyncTable.BUDGETS);
      expect(change?.data).not.toHaveProperty('group');
      expect(change?.data).toHaveProperty('groupId', 'group-1');
    });

    describe('shared budgets', () => {
      const shared = { id: 'bud-9', userId: 'admin-1', groupId: 'group-1', name: 'Rent', updatedAt: new Date('2026-05-01') };
      const pullWhere = () => (budgetRepo.find.mock.calls as [{ where: Record<string, unknown> }][]).map(([o]) => o.where);

      it('should not look for shared budgets when the caller is in no group', async () => {
        memberRepo.findOne.mockResolvedValue(null);

        await service.pullChanges('user-1');

        expect(budgetRepo.find).toHaveBeenCalledTimes(1);
      });

      it('should add other members shared budgets changed since the last pull, without duplicating own rows', async () => {
        memberRepo.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', joinedAt: new Date('2026-01-01') });
        budgetRepo.find.mockResolvedValueOnce([]).mockResolvedValueOnce([shared]);

        const result = await service.pullChanges('user-1', '2026-04-01T00:00:00.000Z');

        const where = pullWhere()[1];
        expect(where.groupId).toBe('group-1');
        expect(where.userId).toEqual(expect.objectContaining({ type: 'not', value: 'user-1' }));
        expect(where.updatedAt).toEqual(expect.objectContaining({ type: 'moreThan' }));
        expect(result.changes.filter((c) => c.id === 'bud-9')).toHaveLength(1);
      });

      it('should send every shared budget once after joining, however old', async () => {
        memberRepo.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', joinedAt: new Date('2026-06-01') });

        await service.pullChanges('user-1', '2026-05-15T00:00:00.000Z');

        expect(pullWhere()[1]).not.toHaveProperty('updatedAt');
      });

      it('should strip owner fields and keep groupId on shared budgets', async () => {
        memberRepo.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', joinedAt: new Date('2026-01-01') });
        budgetRepo.find.mockResolvedValueOnce([]).mockResolvedValueOnce([{ ...shared, user: {}, group: {} }]);

        const change = (await service.pullChanges('user-1')).changes.find((c) => c.id === 'bud-9');

        expect(change?.data).not.toHaveProperty('userId');
        expect(change?.data).not.toHaveProperty('user');
        expect(change?.data).not.toHaveProperty('group');
        expect(change?.data).toHaveProperty('groupId', 'group-1');
      });
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

  describe('goals', () => {
    let goalRepo: AnyRepo;
    const goal = { name: 'Laptop', targetAmount: 1999, savedAmount: 250, targetDate: '2027-01-24T00:00:00.000Z', monthlyContribution: 583.17 };

    beforeEach(() => {
      goalRepo = module.get(getRepositoryToken(Goal));
    });

    it('should store a pushed goal for the caller', async () => {
      goalRepo.findOne.mockResolvedValue(null);
      goalRepo.create.mockImplementation((data: any) => ({ ...data }));
      goalRepo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      const result = await service.pushChanges('user-1', {
        changes: [{ table: SyncTable.GOALS, action: SyncAction.INSERT, id: 'goal-1', data: goal }],
      });

      expect(result.results[0].status).toBe(SyncStatus.SUCCESS);
      expect(goalRepo.save).toHaveBeenCalledWith(expect.objectContaining({ id: 'goal-1', userId: 'user-1', name: 'Laptop', savedAmount: 250 }));
    });

    it('should report a conflict for an update older than the stored goal', async () => {
      goalRepo.findOne.mockResolvedValue({ id: 'goal-1', userId: 'user-1', ...goal, updatedAt: new Date('2026-06-01') });

      const result = await service.pushChanges('user-1', {
        changes: [{ table: SyncTable.GOALS, action: SyncAction.UPDATE, id: 'goal-1', data: { ...goal, savedAmount: 300 }, updatedAt: '2026-01-01T00:00:00.000Z' }],
      });

      expect(result.results[0].status).toBe(SyncStatus.CONFLICT);
      expect(goalRepo.save).not.toHaveBeenCalled();
    });

    it('should delete the user\'s goals on clear', async () => {
      await service.clearUserData('user-1');

      expect(goalRepo.delete).toHaveBeenCalledWith({ userId: 'user-1' });
    });

    it('should pull goals without userId or user', async () => {
      goalRepo.find.mockResolvedValue([{ id: 'goal-1', userId: 'user-1', user: {}, ...goal, updatedAt: new Date() }]);

      const result = await service.pullChanges('user-1');
      const change = result.changes.find((c) => c.table === SyncTable.GOALS);

      expect(change?.data).toEqual(expect.objectContaining({ name: 'Laptop' }));
      expect(change?.data).not.toHaveProperty('userId');
      expect(change?.data).not.toHaveProperty('user');
    });

    it('should count goals in the summary', async () => {
      goalRepo.count.mockResolvedValue(2);

      const summary = await service.getSummary('user-1');

      expect(summary.tables.goals).toBe(2);
    });
  });

  describe('owner checks', () => {
    const tables = Object.values(SyncTable);
    const entityFor: Record<SyncTable, unknown> = {
      [SyncTable.RECORDS]: RecordEntity,
      [SyncTable.CATEGORIES]: Category,
      [SyncTable.BUDGETS]: Budget,
      [SyncTable.MESSAGE_SOURCES]: MessageSource,
      [SyncTable.EXPENSE_TEMPLATES]: ExpenseTemplate,
      [SyncTable.PARSING_RULES]: ParsingRule,
      [SyncTable.RECURRING_TRANSACTIONS]: RecurringTransaction,
      [SyncTable.PENDING_RECURRING]: PendingRecurring,
      [SyncTable.GOALS]: Goal,
    };
    const repoFor = (table: SyncTable): AnyRepo => module.get(getRepositoryToken(entityFor[table] as any));

    const push = (table: SyncTable, action: SyncAction, data: Record<string, unknown> | null = { amount: 1 }) =>
      service.pushChanges('user-2', { changes: [{ table, action, id: 'row-1', data }] });

    const ownedByOther = (repo: AnyRepo) => {
      repo.findOne.mockResolvedValue(null);
      repo.exists.mockResolvedValue(true);
      repo.delete.mockResolvedValue({ affected: 0 });
    };

    it.each(tables)('should not insert over another user\'s %s row', async (table) => {
      const repo = repoFor(table);
      ownedByOther(repo);

      const result = await push(table, SyncAction.INSERT);

      expect(result.results[0]).toEqual({ id: 'row-1', status: SyncStatus.CONFLICT, serverId: 'row-1', message: 'Not the owner' });
      expect(repo.save).not.toHaveBeenCalled();
    });

    it.each(tables)('should not update another user\'s %s row', async (table) => {
      const repo = repoFor(table);
      ownedByOther(repo);

      const result = await push(table, SyncAction.UPDATE);

      expect(result.results[0]).toEqual({ id: 'row-1', status: SyncStatus.CONFLICT, serverId: 'row-1', message: 'Not the owner' });
      expect(repo.findOne).toHaveBeenCalledWith({ where: { id: 'row-1', userId: 'user-2' } });
      expect(repo.save).not.toHaveBeenCalled();
    });

    it.each(tables)('should not delete another user\'s %s row', async (table) => {
      const repo = repoFor(table);
      ownedByOther(repo);

      const result = await push(table, SyncAction.DELETE, null);

      expect(result.results[0]).toEqual({ id: 'row-1', status: SyncStatus.CONFLICT, serverId: 'row-1', message: 'Not the owner' });
      expect(repo.delete).toHaveBeenCalledWith({ id: 'row-1', userId: 'user-2' });
    });

    it.each(tables)('should update an own %s row', async (table) => {
      const repo = repoFor(table);
      repo.findOne.mockResolvedValue({ id: 'row-1', userId: 'user-2', updatedAt: new Date('2025-01-01') });
      repo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      const result = await push(table, SyncAction.UPDATE);

      expect(result.results[0].status).toBe(SyncStatus.SUCCESS);
      expect(repo.findOne).toHaveBeenCalledWith({ where: { id: 'row-1', userId: 'user-2' } });
      expect(repo.exists).not.toHaveBeenCalled();
    });

    it.each(tables)('should create a %s row for the caller when an update has an unknown id', async (table) => {
      const repo = repoFor(table);
      repo.findOne.mockResolvedValue(null);
      repo.create.mockImplementation((data: any) => ({ ...data }));
      repo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      const result = await push(table, SyncAction.UPDATE);

      expect(result.results[0].status).toBe(SyncStatus.SUCCESS);
      expect(repo.save).toHaveBeenCalledWith(expect.objectContaining({ id: 'row-1', userId: 'user-2' }));
    });

    it.each(tables)('should succeed when deleting an unknown %s id', async (table) => {
      const repo = repoFor(table);
      repo.delete.mockResolvedValue({ affected: 0 });

      const result = await push(table, SyncAction.DELETE, null);

      expect(result.results[0].status).toBe(SyncStatus.SUCCESS);
    });

    it('should ignore a userId sent in the update data', async () => {
      recordRepo.findOne.mockResolvedValue({ id: 'row-1', userId: 'user-2', updatedAt: new Date('2025-01-01') });
      recordRepo.save.mockImplementation((entity: any) => Promise.resolve(entity));

      await push(SyncTable.RECORDS, SyncAction.UPDATE, { userId: 'user-1', amount: 5 });

      expect(recordRepo.save).toHaveBeenCalledWith(expect.objectContaining({ userId: 'user-2', amount: 5 }));
    });
  });
});
