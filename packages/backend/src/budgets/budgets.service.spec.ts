import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BudgetsService } from './budgets.service';
import { Budget } from './entities/budget.entity';
import { DEFAULT_BUDGET_NAME } from './budgets.constants';

describe('BudgetsService', () => {
  let service: BudgetsService;
  const budgetRepo = { query: jest.fn() };

  beforeEach(async () => {
    budgetRepo.query.mockReset();
    const module: TestingModule = await Test.createTestingModule({
      providers: [BudgetsService, { provide: getRepositoryToken(Budget), useValue: budgetRepo }],
    }).compile();

    service = module.get(BudgetsService);
  });

  describe('fillMissingNames', () => {
    it('should update only rows of the user that still hold the default name', async () => {
      budgetRepo.query.mockResolvedValue([[], 1]);

      const result = await service.fillMissingNames('user-1', [
        { id: 'bud-1', name: 'Groceries' },
        { id: 'bud-2', name: 'Rent' },
      ]);

      expect(result).toEqual({ updated: 1 });
      const [sql, params] = budgetRepo.query.mock.calls[0];
      expect(sql).toContain('b."userId" = $3 AND b."name" = $4');
      expect(sql).not.toMatch(/INSERT/i);
      expect(sql).not.toContain('updatedAt');
      expect(params).toEqual([['bud-1', 'bud-2'], ['Groceries', 'Rent'], 'user-1', DEFAULT_BUDGET_NAME]);
    });

    it('should skip the query when there are no names', async () => {
      const result = await service.fillMissingNames('user-1', []);

      expect(result).toEqual({ updated: 0 });
      expect(budgetRepo.query).not.toHaveBeenCalled();
    });
  });
});
