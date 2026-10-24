import { getMetadataArgsStorage } from 'typeorm';
import { Goal } from './goal.entity';

describe('Goal entity', () => {
  const column = (name: string) =>
    getMetadataArgsStorage().columns.find((c) => c.target === Goal && c.propertyName === name);

  it('should default savedAmount to 0', () => {
    expect(column('savedAmount')?.options.default).toBe(0);
  });

  it('should make targetDate and monthlyContribution nullable', () => {
    expect(column('targetDate')?.options.nullable).toBe(true);
    expect(column('monthlyContribution')?.options.nullable).toBe(true);
  });

  it('should store amounts as decimal(12,2)', () => {
    for (const name of ['targetAmount', 'savedAmount', 'monthlyContribution']) {
      expect(column(name)?.options).toEqual(expect.objectContaining({ type: 'decimal', precision: 12, scale: 2 }));
    }
  });

  it('should index userId and updatedAt for pulls', () => {
    const index = getMetadataArgsStorage().indices.find(
      (i) => i.target === Goal && JSON.stringify(i.columns) === JSON.stringify(['userId', 'updatedAt']),
    );

    expect(index).toBeDefined();
  });

  it('should register both check constraints', () => {
    const names = getMetadataArgsStorage()
      .checks.filter((c) => c.target === Goal)
      .map((c) => c.name);

    expect(names).toEqual(expect.arrayContaining(['CHK_goals_target_positive', 'CHK_goals_saved_non_negative']));
  });
});
