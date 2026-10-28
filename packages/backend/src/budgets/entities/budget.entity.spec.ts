import { getMetadataArgsStorage, QueryRunner } from 'typeorm';
import { Budget } from './budget.entity';
import { DEFAULT_BUDGET_NAME } from '../budgets.constants';
import { AddBudgetGroupId1792854433516 } from '../../migrations/1792854433516-AddBudgetGroupId';

describe('Budget entity', () => {
  it('should map name to a column with the default budget name', () => {
    const column = getMetadataArgsStorage().columns.find(
      (c) => c.target === Budget && c.propertyName === 'name',
    );

    expect(column).toBeDefined();
    expect(column?.options.default).toBe(DEFAULT_BUDGET_NAME);
  });

  it('should map groupId to a nullable uuid column', () => {
    const column = getMetadataArgsStorage().columns.find((c) => c.target === Budget && c.propertyName === 'groupId');

    expect(column?.options.type).toBe('uuid');
    expect(column?.options.nullable).toBe(true);
  });

  it('should set groupId to NULL when the group is deleted', () => {
    const relation = getMetadataArgsStorage().relations.find((r) => r.target === Budget && r.propertyName === 'group');

    expect(relation?.options.onDelete).toBe('SET NULL');
  });

  it('should index groupId', () => {
    const index = getMetadataArgsStorage().indices.find(
      (i) => i.target === Budget && JSON.stringify(i.columns) === JSON.stringify(['groupId']),
    );

    expect(index).toBeDefined();
  });
});


describe('AddBudgetGroupId migration', () => {
  const run = async (step: 'up' | 'down') => {
    const query = jest.fn();
    await new AddBudgetGroupId1792854433516()[step]({ query } as unknown as QueryRunner);
    return query.mock.calls.map(([sql]: [string]) => sql);
  };

  it('should add the column, its index and a SET NULL foreign key to groups', async () => {
    const sql = await run('up');

    expect(sql[0]).toBe('ALTER TABLE "budgets" ADD "groupId" uuid');
    expect(sql[1]).toMatch(/^CREATE INDEX "[^"]+" ON "budgets" \("groupId"\)/);
    expect(sql[2]).toMatch(/FOREIGN KEY \("groupId"\) REFERENCES "groups"\("id"\) ON DELETE SET NULL/);
  });

  it('should drop the foreign key and index before the column', async () => {
    const sql = await run('down');

    expect(sql[0]).toMatch(/^ALTER TABLE "budgets" DROP CONSTRAINT/);
    expect(sql[1]).toMatch(/^DROP INDEX/);
    expect(sql[2]).toBe('ALTER TABLE "budgets" DROP COLUMN "groupId"');
  });
});
