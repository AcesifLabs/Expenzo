import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Budget } from './entities/budget.entity';
import { DEFAULT_BUDGET_NAME } from './budgets.constants';
import { BudgetNameItem } from './dto/fill-budget-names.dto';
import { FillBudgetNamesResult } from './budgets.types';

@Injectable()
export class BudgetsService {
  constructor(@InjectRepository(Budget) private readonly budgetRepo: Repository<Budget>) {}

  /**
   * Restores names the server dropped before budgets had a name column.
   * Only rows of this user still holding the default are touched; nothing is
   * created and no other field changes.
   *
   * `updatedAt` is left alone on purpose: bumping it would make sync reject
   * edits other devices queued earlier as conflicts (ADR 0012).
   *
   * One raw statement fills every row at once; the repository API would need
   * a query per name. The table and column names below mirror the Budget
   * entity mapping and must change with it.
   */
  async fillMissingNames(userId: string, items: BudgetNameItem[]): Promise<FillBudgetNamesResult> {
    if (items.length === 0) return { updated: 0 };

    const result: unknown = await this.budgetRepo.query(
      `UPDATE "budgets" AS b
          SET "name" = v."name"
         FROM unnest($1::text[], $2::text[]) AS v("id", "name")
        WHERE b."id" = v."id" AND b."userId" = $3 AND b."name" = $4`,
      [items.map((i) => i.id), items.map((i) => i.name), userId, DEFAULT_BUDGET_NAME],
    );
    // pg returns [rows, rowCount] for UPDATE through TypeORM's query().
    const updated = Array.isArray(result) && typeof result[1] === 'number' ? result[1] : 0;
    return { updated };
  }
}
