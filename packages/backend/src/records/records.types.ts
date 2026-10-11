import { Record } from './entities/record.entity';

export interface PaginatedResult<T> {
  data: T[];
  nextCursor: string | null;
  total: number;
}

export interface FillRecordBudgetLinksResult {
  updated: number;
}
