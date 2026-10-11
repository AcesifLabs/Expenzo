import { getMetadataArgsStorage } from 'typeorm';
import { Budget } from './budget.entity';
import { DEFAULT_BUDGET_NAME } from '../budgets.constants';

describe('Budget entity', () => {
  it('should map name to a column with the default budget name', () => {
    const column = getMetadataArgsStorage().columns.find(
      (c) => c.target === Budget && c.propertyName === 'name',
    );

    expect(column).toBeDefined();
    expect(column?.options.default).toBe(DEFAULT_BUDGET_NAME);
  });
});
