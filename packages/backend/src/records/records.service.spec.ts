import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { RecordsService } from './records.service';
import { Record } from './entities/record.entity';

describe('RecordsService', () => {
  let service: RecordsService;
  const recordRepo = { query: jest.fn() };

  beforeEach(async () => {
    recordRepo.query.mockReset();
    const module: TestingModule = await Test.createTestingModule({
      providers: [RecordsService, { provide: getRepositoryToken(Record), useValue: recordRepo }],
    }).compile();

    service = module.get(RecordsService);
  });

  describe('fillMissingBudgetLinks', () => {
    it('should update only rows of the user that have no budget link', async () => {
      recordRepo.query.mockResolvedValue([[], 1]);

      const result = await service.fillMissingBudgetLinks('user-1', [
        { id: 'rec-1', budgetId: 'bud-1' },
        { id: 'rec-2', budgetId: 'bud-2' },
      ]);

      expect(result).toEqual({ updated: 1 });
      const [sql, params] = recordRepo.query.mock.calls[0];
      expect(sql).toContain('r."userId" = $3 AND r."budgetId" IS NULL');
      expect(sql).not.toMatch(/INSERT/i);
      expect(sql).not.toContain('updatedAt');
      expect(params).toEqual([['rec-1', 'rec-2'], ['bud-1', 'bud-2'], 'user-1']);
    });

    it('should skip the query when there are no links', async () => {
      const result = await service.fillMissingBudgetLinks('user-1', []);

      expect(result).toEqual({ updated: 0 });
      expect(recordRepo.query).not.toHaveBeenCalled();
    });

    it('should report no updates when the driver returns an unexpected shape', async () => {
      recordRepo.query.mockResolvedValue({ rowCount: 3 });

      const result = await service.fillMissingBudgetLinks('user-1', [{ id: 'rec-1', budgetId: 'bud-1' }]);

      expect(result).toEqual({ updated: 0 });
    });
  });
});
