import { ExecutionContext, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import request = require('supertest');
import { SyncController } from '../src/sync/sync.controller';
import { SyncService } from '../src/sync/sync.service';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';
import { Record as RecordEntity } from '../src/records/entities/record.entity';
import { Category } from '../src/categories/entities/category.entity';
import { Budget } from '../src/budgets/entities/budget.entity';
import { MessageSource } from '../src/message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../src/expense-templates/entities/expense-template.entity';
import { ParsingRule } from '../src/parsing-rules/entities/parsing-rule.entity';
import { RecurringTransaction } from '../src/recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../src/recurring-transactions/entities/pending-recurring.entity';
import { DEFAULT_BUDGET_NAME } from '../src/budgets/budgets.constants';

jest.setTimeout(30000);

type Row = { id: string; userId: string; [field: string]: unknown };
type Where = { id: string; userId?: string };

/** Stores rows in memory and applies the column default for `name` like Postgres would. */
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
    find: ({ where }: { where: { userId: string } }) =>
      Promise.resolve([...rows.values()].filter((r) => r.userId === where.userId)),
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
  parsing_rules: ParsingRule,
  recurring_transactions: RecurringTransaction,
  pending_recurring: PendingRecurring,
};
type Table = keyof typeof entities;

let app: INestApplication;
let repos: Record<Table, ReturnType<typeof memoryRepo>>;
let currentUser: string;

beforeEach(async () => {
  currentUser = 'user-1';
  repos = Object.fromEntries(
    Object.keys(entities).map((table) => [table, memoryRepo(table === 'budgets' ? { name: DEFAULT_BUDGET_NAME } : {})]),
  ) as typeof repos;
  const moduleFixture = await Test.createTestingModule({
    controllers: [SyncController],
    providers: [
      SyncService,
      ...(Object.keys(entities) as Table[]).map((table) => ({ provide: getRepositoryToken(entities[table]), useValue: repos[table] })),
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
