import { ExecutionContext, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request = require('supertest');
import { BudgetsController } from '../src/budgets/budgets.controller';
import { BudgetsService } from '../src/budgets/budgets.service';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';
import { BUDGET_NAME_MAX_LENGTH, FILL_BUDGET_NAMES_MAX_ITEMS } from '../src/budgets/budgets.constants';

jest.setTimeout(30000);

describe('BudgetsController (e2e)', () => {
  let app: INestApplication;
  const budgetsService = { fillMissingNames: jest.fn() };
  let signedIn: boolean;

  beforeEach(async () => {
    signedIn = true;
    budgetsService.fillMissingNames.mockReset().mockResolvedValue({ updated: 1 });
    const moduleFixture = await Test.createTestingModule({
      controllers: [BudgetsController],
      providers: [{ provide: BudgetsService, useValue: budgetsService }],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (context: ExecutionContext) => {
          if (!signedIn) return false;
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

  it('POST /budgets/names should fill names for the signed-in user', async () => {
    const response = await request(app.getHttpServer())
      .post('/budgets/names')
      .send({ names: [{ id: 'bud-1', name: 'Groceries' }] })
      .expect(200);

    expect(response.body).toEqual({ updated: 1 });
    expect(budgetsService.fillMissingNames).toHaveBeenCalledWith('user-1', [{ id: 'bud-1', name: 'Groceries' }]);
  });

  it.each([
    ['an empty name', { names: [{ id: 'bud-1', name: '' }] }],
    ['a missing id', { names: [{ name: 'Groceries' }] }],
    ['extra fields', { names: [{ id: 'bud-1', name: 'Groceries', amount: 5 }] }],
    ['no names array', {}],
    ['names that is not an array', { names: 'Groceries' }],
    ['a non-string id', { names: [{ id: 7, name: 'Groceries' }] }],
    ['a non-string name', { names: [{ id: 'bud-1', name: 7 }] }],
    ['a name over the length limit', { names: [{ id: 'bud-1', name: 'x'.repeat(BUDGET_NAME_MAX_LENGTH + 1) }] }],
    [
      'more names than one request allows',
      { names: Array.from({ length: FILL_BUDGET_NAMES_MAX_ITEMS + 1 }, (_, i) => ({ id: `bud-${i}`, name: 'Groceries' })) },
    ],
  ])('POST /budgets/names should reject %s', async (_label, body) => {
    await request(app.getHttpServer()).post('/budgets/names').send(body).expect(400);

    expect(budgetsService.fillMissingNames).not.toHaveBeenCalled();
  });

  it('POST /budgets/names should refuse a request without a signed-in user', async () => {
    signedIn = false;

    await request(app.getHttpServer())
      .post('/budgets/names')
      .send({ names: [{ id: 'bud-1', name: 'Groceries' }] })
      .expect(403);

    expect(budgetsService.fillMissingNames).not.toHaveBeenCalled();
  });
});
