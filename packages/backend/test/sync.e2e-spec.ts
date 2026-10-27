import { ExecutionContext, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { FindOperator } from 'typeorm';
import request = require('supertest');
import { SyncController } from '../src/sync/sync.controller';
import { SyncService } from '../src/sync/sync.service';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';
import { Record as RecordEntity } from '../src/records/entities/record.entity';
import { Category } from '../src/categories/entities/category.entity';
import { Budget } from '../src/budgets/entities/budget.entity';
import { MessageSource } from '../src/message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../src/expense-templates/entities/expense-template.entity';
import { RecurringTransaction } from '../src/recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../src/recurring-transactions/entities/pending-recurring.entity';
import { Goal } from '../src/goals/entities/goal.entity';
import { GroupMember } from '../src/groups/entities/group-member.entity';
import { GroupRole } from '../src/groups/groups.constants';
import { DEFAULT_BUDGET_NAME } from '../src/budgets/budgets.constants';

jest.setTimeout(30000);

type Row = { id: string; userId: string; [field: string]: unknown };
type Where = { id: string; userId?: string };


function fieldMatches(value: unknown, condition: unknown): boolean {
  if (condition instanceof FindOperator) {
    if (condition.type === 'not') return value !== condition.value;
    if (condition.type === 'moreThan') return (value as Date) > (condition.value as Date);
    throw new Error(`memoryRepo does not support ${condition.type}`);
  }
  return value === condition;
}


function memoryRepo(defaults: Partial<Row> = {}) {
  const rows = new Map<string, Row>();
  const matches = (where: Where) => {
    const row = rows.get(where.id);
    return row && (where.userId === undefined || row.userId === where.userId) ? row : null;
  };
  return {
    rows,
    findOne: ({ where }: { where: Where }) => Promise.resolve(matches(where)),
    exists: ({ where }: { where: Where }) => Promise.resolve(rows.has(where.id)),
    create: (data: Row) => ({ ...data }),
    save: (row: Row) => {
      rows.set(row.id, { ...defaults, ...row });
      return Promise.resolve(row);
    },
    find: ({ where }: { where: Record<string, unknown> }) =>
      Promise.resolve([...rows.values()].filter((r) => Object.entries(where).every(([k, v]) => fieldMatches(r[k], v)))),
    delete: (where: Where) => {
      const affected = matches(where) ? 1 : 0;
      if (affected) rows.delete(where.id);
      return Promise.resolve({ affected });
    },
    count: () => Promise.resolve(rows.size),
  };
}

const entities = {
  records: RecordEntity,
  categories: Category,
  budgets: Budget,
  message_sources: MessageSource,
  expense_templates: ExpenseTemplate,
  recurring_transactions: RecurringTransaction,
  pending_recurring: PendingRecurring,
  goals: Goal,
};
type Table = keyof typeof entities;

let app: INestApplication;
let repos: Record<Table, ReturnType<typeof memoryRepo>>;
let currentUser: string;

let memberships: Map<string, { groupId: string; userId: string; role: GroupRole; joinedAt: Date }>;

beforeEach(async () => {
  currentUser = 'user-1';
  memberships = new Map();
  repos = Object.fromEntries(
    Object.keys(entities).map((table) => [table, memoryRepo(table === 'budgets' ? { name: DEFAULT_BUDGET_NAME } : {})]),
  ) as typeof repos;
  const moduleFixture = await Test.createTestingModule({
    controllers: [SyncController],
    providers: [
      SyncService,
      ...(Object.keys(entities) as Table[]).map((table) => ({ provide: getRepositoryToken(entities[table]), useValue: repos[table] })),
      {
        provide: getRepositoryToken(GroupMember),
        useValue: { findOne: ({ where }: { where: { userId: string } }) => Promise.resolve(memberships.get(where.userId) ?? null) },
      },
    ],
  })
    .overrideGuard(JwtAuthGuard)
    .useValue({
      canActivate: (context: ExecutionContext) => {
        context.switchToHttp().getRequest().user = { sub: currentUser };
        return true;
      },
    })
    .compile();

  app = moduleFixture.createNestApplication();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  await app.init();
});

afterEach(async () => {
  await app.close();
});

describe('SyncController budgets (e2e)', () => {
  let budgets: ReturnType<typeof memoryRepo>;

  beforeEach(() => {
    budgets = repos.budgets;
  });

  const push = (action: 'insert' | 'update', data: Record<string, unknown>) =>
    request(app.getHttpServer())
      .post('/sync/push')
      .send({ changes: [{ table: 'budgets', action, id: 'bud-1', data, updatedAt: new Date().toISOString() }] })
      .expect(200);

  const pulledName = async () => {
    const response = await request(app.getHttpServer()).get('/sync/pull').expect(200);
    const change = (response.body.changes as { table: string; data: { name: string } }[]).find((c) => c.table === 'budgets');
    return change?.data.name;
  };

  const budget = { amount: 400, period: 'monthly', startDate: '2026-10-01T00:00:00.000Z' };

  it('should return a pushed budget name on pull', async () => {
    await push('insert', { ...budget, name: 'Groceries' });

    expect(await pulledName()).toBe('Groceries');
  });

  it('should store the default name when a new budget has a blank name', async () => {
    await push('insert', { ...budget, name: '  ' });

    expect(await pulledName()).toBe(DEFAULT_BUDGET_NAME);
  });

  it.each([null, '', DEFAULT_BUDGET_NAME])('should keep the stored name when an update sends %p', async (name) => {
    await push('insert', { ...budget, name: 'Groceries' });

    await push('update', { ...budget, amount: 500, name });

    expect(await pulledName()).toBe('Groceries');
    expect(budgets.rows.get('bud-1')?.amount).toBe(500);
  });
});

describe('SyncController goals (e2e)', () => {
  const goal = { name: 'Laptop', targetAmount: 1999, savedAmount: 0, targetDate: '2027-01-24T00:00:00.000Z', monthlyContribution: 666.33 };

  const push = (action: 'insert' | 'update', data: Record<string, unknown>) =>
    request(app.getHttpServer())
      .post('/sync/push')
      .send({ changes: [{ table: 'goals', action, id: 'goal-1', data, updatedAt: new Date().toISOString() }] })
      .expect(200);

  const pulledGoal = async () => {
    const response = await request(app.getHttpServer()).get('/sync/pull').expect(200);
    const change = (response.body.changes as { table: string; data: Record<string, unknown> }[]).find((c) => c.table === 'goals');
    return change?.data;
  };

  it('should return a pushed goal on pull', async () => {
    await push('insert', goal);

    expect(await pulledGoal()).toEqual(expect.objectContaining(goal));
  });

  it('should return the raised savedAmount after an update', async () => {
    await push('insert', goal);

    await push('update', { ...goal, savedAmount: 400 });

    expect((await pulledGoal())?.savedAmount).toBe(400);
  });

  it('should keep a null targetDate', async () => {
    await push('insert', { ...goal, targetDate: null, monthlyContribution: null });

    const pulled = await pulledGoal();
    expect(pulled?.targetDate).toBeNull();
    expect(pulled?.monthlyContribution).toBeNull();
  });
});

describe('SyncController owner checks (e2e)', () => {
  const tables = Object.keys(entities) as Table[];
  const original = { id: 'row-1', userId: 'user-1', description: 'original', updatedAt: new Date('2025-01-01') };

  const pushAs = (user: string, table: Table, action: 'insert' | 'update' | 'delete') => {
    currentUser = user;
    const data = action === 'delete' ? undefined : { description: 'taken over' };
    return request(app.getHttpServer())
      .post('/sync/push')
      .send({ changes: [{ table, action, id: 'row-1', data, updatedAt: new Date().toISOString() }] })
      .expect(200);
  };

  const pulledAs = async (user: string, table: Table) => {
    currentUser = user;
    const response = await request(app.getHttpServer()).get('/sync/pull').expect(200);
    return (response.body.changes as { table: string; id: string; data: Record<string, unknown> }[]).find(
      (c) => c.table === table && c.id === 'row-1',
    );
  };

  beforeEach(() => {
    for (const table of tables) repos[table].rows.set('row-1', { ...original });
  });

  it.each(tables)('should not let another user update a %s row', async (table) => {
    const response = await pushAs('user-2', table, 'update');

    expect(response.body.results[0]).toMatchObject({ status: 'conflict', message: 'Not the owner' });
    expect((await pulledAs('user-1', table))?.data.description).toBe('original');
    expect(repos[table].rows.get('row-1')?.userId).toBe('user-1');
  });

  it.each(['insert', 'delete'] as const)('should not let another user %s a row', async (action) => {
    const response = await pushAs('user-2', 'records', action);

    expect(response.body.results[0]).toMatchObject({ status: 'conflict', message: 'Not the owner' });
    expect(repos.records.rows.get('row-1')).toMatchObject({ userId: 'user-1', description: 'original' });
  });

  it.each(['update', 'delete'] as const)('should let the owner %s a row', async (action) => {
    const response = await pushAs('user-1', 'records', action);

    expect(response.body.results[0].status).toBe('success');
  });
});

describe('SyncController record budget links (e2e)', () => {
  const record = { amount: 12.5, description: 'Lunch', date: '2026-10-01T00:00:00.000Z', recordType: 'expense' };

  const pushRecord = (data: Record<string, unknown>) =>
    request(app.getHttpServer())
      .post('/sync/push')
      .send({ changes: [{ table: 'records', action: 'insert', id: 'rec-1', data, updatedAt: new Date().toISOString() }] })
      .expect(200);

  const pulledRecord = async () => {
    const response = await request(app.getHttpServer()).get('/sync/pull').expect(200);
    return (response.body.changes as { table: string; data: Record<string, unknown> }[]).find((c) => c.table === 'records');
  };

  it('should return a pushed budgetId on pull', async () => {
    await pushRecord({ ...record, budgetId: 'bud-1' });

    expect((await pulledRecord())?.data.budgetId).toBe('bud-1');
  });

  it('should store no budgetId when a record has none', async () => {
    await pushRecord({ ...record, budgetId: null });

    expect((await pulledRecord())?.data.budgetId ?? null).toBeNull();
  });
});

describe('SyncController shared budgets (e2e)', () => {
  const budget = { amount: 400, period: 'monthly', startDate: '2026-10-01T00:00:00.000Z', name: 'Groceries' };
  const push = (action: 'insert' | 'update', data: Record<string, unknown>) =>
    request(app.getHttpServer())
      .post('/sync/push')
      .send({ changes: [{ table: 'budgets', action, id: 'bud-1', data, updatedAt: new Date().toISOString() }] })
      .expect(200);
  const pulledGroupId = async () => {
    const response = await request(app.getHttpServer()).get('/sync/pull').expect(200);
    const change = (response.body.changes as { table: string; data: { groupId: string | null } }[]).find(
      (c) => c.table === 'budgets',
    );
    return change?.data.groupId;
  };
  const joinAs = (role: GroupRole) =>
    memberships.set('user-1', { groupId: 'group-1', userId: 'user-1', role, joinedAt: new Date() });

  it('should let an admin share a budget into their group', async () => {
    joinAs(GroupRole.ADMIN);

    const response = await push('insert', { ...budget, groupId: 'group-1' });

    expect(response.body.results[0].status).toBe('success');
    expect(await pulledGroupId()).toBe('group-1');
  });

  it('should answer success to a member share and pull the budget back unshared', async () => {
    joinAs(GroupRole.MEMBER);

    const response = await push('insert', { ...budget, groupId: 'group-1' });

    expect(response.body.results[0].status).toBe('success');
    expect(await pulledGroupId()).toBeNull();
  });

  it('should let the owner unshare after being demoted', async () => {
    joinAs(GroupRole.ADMIN);
    await push('insert', { ...budget, groupId: 'group-1' });
    joinAs(GroupRole.MEMBER);

    const response = await push('update', { ...budget, groupId: null });

    expect(response.body.results[0].status).toBe('success');
    expect(await pulledGroupId()).toBeNull();
  });
});

describe('SyncController shared budget pull (e2e)', () => {
  const pull = async (since?: string) => {
    const response = await request(app.getHttpServer())
      .get('/sync/pull')
      .query(since ? { since } : {})
      .expect(200);
    return response.body as { changes: { table: string; id: string; data: Record<string, unknown> }[]; serverTime: string };
  };

  it('should give a member the admin shared budget once, then nothing until it changes', async () => {
    memberships.set('admin-1', { groupId: 'group-1', userId: 'admin-1', role: GroupRole.ADMIN, joinedAt: new Date(0) });
    currentUser = 'admin-1';
    await request(app.getHttpServer())
      .post('/sync/push')
      .send({
        changes: [
          {
            table: 'budgets',
            action: 'insert',
            id: 'bud-shared',
            data: { name: 'Rent', amount: 900, period: 'monthly', startDate: '2026-10-01T00:00:00.000Z', groupId: 'group-1' },
          },
        ],
      })
      .expect(200);

    memberships.set('user-2', { groupId: 'group-1', userId: 'user-2', role: GroupRole.MEMBER, joinedAt: new Date() });
    currentUser = 'user-2';
    const first = await pull();
    const shared = first.changes.find((c) => c.id === 'bud-shared');
    expect(shared?.data).toEqual(expect.objectContaining({ name: 'Rent', groupId: 'group-1' }));
    expect(shared?.data).not.toHaveProperty('userId');

    const second = await pull(first.serverTime);
    expect(second.changes.find((c) => c.id === 'bud-shared')).toBeUndefined();
  });
});

