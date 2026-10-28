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

  
  async fillMissingNames(userId: string, items: BudgetNameItem[]): Promise<FillBudgetNamesResult> {
    if (items.length === 0) return { updated: 0 };

    const result: unknown = await this.budgetRepo.query(
      `UPDATE "budgets" AS b
          SET "name" = v."name"
         FROM unnest($1::text[], $2::text[]) AS v("id", "name")
        WHERE b."id" = v."id" AND b."userId" = $3 AND b."name" = $4`,
      [items.map((i) => i.id), items.map((i) => i.name), userId, DEFAULT_BUDGET_NAME],
    );
    
    const updated = Array.isArray(result) && typeof result[1] === 'number' ? result[1] : 0;
    return { updated };
  }
}
