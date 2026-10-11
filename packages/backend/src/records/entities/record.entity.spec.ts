import { DefaultNamingStrategy, getMetadataArgsStorage, QueryRunner } from 'typeorm';
import { Record } from './record.entity';
import { AddRecordBudgetId1791746124921 } from '../../migrations/1791746124921-AddRecordBudgetId';

describe('Record entity', () => {
  it('should map budgetId to a nullable text column', () => {
    const column = getMetadataArgsStorage().columns.find((c) => c.target === Record && c.propertyName === 'budgetId');

    expect(column).toBeDefined();
    expect(column?.options.type).toBe('text');
    expect(column?.options.nullable).toBe(true);
  });

  it('should index userId and budgetId', () => {
    const index = getMetadataArgsStorage().indices.find(
      (i) => i.target === Record && JSON.stringify(i.columns) === JSON.stringify(['userId', 'budgetId']),
    );

    expect(index).toBeDefined();
  });

});

// Kept out of src/migrations: the TypeORM CLI loads every file there as a migration.
describe('AddRecordBudgetId migration', () => {
  const run = async (step: 'up' | 'down') => {
    const query = jest.fn();
    await new AddRecordBudgetId1791746124921()[step]({ query } as unknown as QueryRunner);
    return query.mock.calls.map(([sql]: [string]) => sql);
  };
  const indexName = new DefaultNamingStrategy().indexName('records', ['userId', 'budgetId']);

  it('should add the column, then the index under the name TypeORM derives for it', async () => {
    expect(await run('up')).toEqual([
      'ALTER TABLE "records" ADD "budgetId" text',
      `CREATE INDEX "${indexName}" ON "records" ("userId", "budgetId") `,
    ]);
  });

  it('should drop the index before the column', async () => {
    expect(await run('down')).toEqual([
      `DROP INDEX "public"."${indexName}"`,
      'ALTER TABLE "records" DROP COLUMN "budgetId"',
    ]);
  });
});
