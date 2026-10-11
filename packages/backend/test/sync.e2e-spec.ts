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

/** Stores rows in memory and applies the column default for `name` like Postgres would. */
function memoryRepo(defaults: Partial<Row> = {}) {
  const rows = new Map<string, Row>();
  return {
    rows,
    findOne: ({ where }: { where: { id: string } }) => Promise.resolve(rows.get(where.id) ?? null),
    create: (data: Row) => ({ ...data }),
    save: (row: Row) => {
      rows.set(row.id, { ...defaults, ...row });
      return Promise.resolve(row);
    },
    find: ({ where }: { where: { userId: string } }) =>
      Promise.resolve([...rows.values()].filter((r) => r.userId === where.userId)),
    delete: () => Promise.resolve(),
    count: () => Promise.resolve(rows.size),
  };
}

describe('SyncController budgets (e2e)', () => {
  let app: INestApplication;
  let budgets: ReturnType<typeof memoryRepo>;

  beforeEach(async () => {
    budgets = memoryRepo({ name: DEFAULT_BUDGET_NAME });
    const otherTables = [RecordEntity, Category, MessageSource, ExpenseTemplate, ParsingRule, RecurringTransaction, PendingRecurring];
    const moduleFixture = await Test.createTestingModule({
      controllers: [SyncController],
      providers: [
        SyncService,
        { provide: getRepositoryToken(Budget), useValue: budgets },
        ...otherTables.map((entity) => ({ provide: getRepositoryToken(entity), useValue: memoryRepo() })),
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (context: ExecutionContext) => {
          context.switchToHttp().getRequest().user = { sub: 'user-1' };
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
