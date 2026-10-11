import { ExecutionContext, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request = require('supertest');
import { RecordsController } from '../src/records/records.controller';
import { RecordsService } from '../src/records/records.service';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';
import { FILL_RECORD_BUDGET_LINKS_MAX_ITEMS } from '../src/records/records.constants';

jest.setTimeout(30000);

describe('RecordsController (e2e)', () => {
  let app: INestApplication;
  const recordsService = { fillMissingBudgetLinks: jest.fn() };
  let signedIn: boolean;

  beforeEach(async () => {
    signedIn = true;
    recordsService.fillMissingBudgetLinks.mockReset().mockResolvedValue({ updated: 1 });
    const moduleFixture = await Test.createTestingModule({
      controllers: [RecordsController],
      providers: [{ provide: RecordsService, useValue: recordsService }],
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

  it('POST /records/budget-links should fill links for the signed-in user', async () => {
    const response = await request(app.getHttpServer())
      .post('/records/budget-links')
      .send({ links: [{ id: 'rec-1', budgetId: 'bud-1' }] })
      .expect(200);

    expect(response.body).toEqual({ updated: 1 });
    expect(recordsService.fillMissingBudgetLinks).toHaveBeenCalledWith('user-1', [{ id: 'rec-1', budgetId: 'bud-1' }]);
  });

  it.each([
    ['an empty budgetId', { links: [{ id: 'rec-1', budgetId: '' }] }],
    ['a missing id', { links: [{ budgetId: 'bud-1' }] }],
    ['a non-string id', { links: [{ id: 7, budgetId: 'bud-1' }] }],
    ['a non-string budgetId', { links: [{ id: 'rec-1', budgetId: 7 }] }],
    ['extra fields', { links: [{ id: 'rec-1', budgetId: 'bud-1', amount: 5 }] }],
    ['links that is not an array', { links: 'rec-1' }],
    ['no links array', {}],
    [
      'duplicate ids',
      { links: [{ id: 'rec-1', budgetId: 'bud-1' }, { id: 'rec-1', budgetId: 'bud-2' }] },
    ],
    [
      'more links than one request allows',
      { links: Array.from({ length: FILL_RECORD_BUDGET_LINKS_MAX_ITEMS + 1 }, (_, i) => ({ id: `rec-${i}`, budgetId: 'bud-1' })) },
    ],
  ])('POST /records/budget-links should reject %s', async (_label, body) => {
    await request(app.getHttpServer()).post('/records/budget-links').send(body).expect(400);

    expect(recordsService.fillMissingBudgetLinks).not.toHaveBeenCalled();
  });

  it('POST /records/budget-links should refuse a request without a signed-in user', async () => {
    signedIn = false;

    await request(app.getHttpServer())
      .post('/records/budget-links')
      .send({ links: [{ id: 'rec-1', budgetId: 'bud-1' }] })
      .expect(403);

    expect(recordsService.fillMissingBudgetLinks).not.toHaveBeenCalled();
  });
});
