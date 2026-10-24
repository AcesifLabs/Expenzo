import { BudgetPeriod } from '../common/enums/budget-period.enum';
import { CategoryType } from '../common/enums/category-type.enum';
import { GroupSummaryService } from './group-summary.service';

describe('GroupSummaryService', () => {
  // Wednesday 15 April 2026, 12:00 UTC.
  const now = new Date('2026-04-15T12:00:00Z');
  const repo = () => ({ findOne: jest.fn(), find: jest.fn().mockResolvedValue([]), query: jest.fn().mockResolvedValue([]) });
  let groups: ReturnType<typeof repo>;
  let members: ReturnType<typeof repo>;
  let budgets: ReturnType<typeof repo>;
  let records: ReturnType<typeof repo>;
  let users: ReturnType<typeof repo>;
  let service: GroupSummaryService;

  const budget = (id: string, extra: object = {}) => ({
    id,
    name: id,
    amount: '1000.00',
    period: BudgetPeriod.MONTHLY,
    startDate: new Date('2026-01-01T00:00:00Z'),
    rolloverEnabled: false,
    rolloverAmount: '0.00',
    isEnabled: true,
    ...extra,
  });
  const row = (userId: string, budgetId: string, date: string, amount: string) => ({ userId, budgetId, date: new Date(date), amount });

  beforeEach(() => {
    [groups, members, budgets, records, users] = [repo(), repo(), repo(), repo(), repo()];
    service = new GroupSummaryService(groups as never, members as never, budgets as never, records as never, users as never);
    groups.findOne.mockResolvedValue({ id: 'group-1', currencyCode: 'BDT', monthlyBudget: '5000.00' });
    members.find.mockResolvedValue([{ userId: 'admin' }, { userId: 'member' }, { userId: 'quiet' }]);
    users.find.mockResolvedValue([{ id: 'admin', displayName: 'Karim' }, { id: 'member', displayName: null }]);
    budgets.find.mockResolvedValue([budget('groceries')]);
  });

  const summary = () => service.getSummary('group-1', 0, now);

  it('should ask only for expense Records of current members linked to enabled shared budgets', async () => {
    await summary();

    expect(budgets.find).toHaveBeenCalledWith({ where: { groupId: 'group-1', isEnabled: true } });
    const [sql, params] = records.query.mock.calls[0] as [string, unknown[]];
    expect(sql).toContain('"budgetId" = ANY($2)');
    expect(params[0]).toEqual(['admin', 'member', 'quiet']);
    expect(params[1]).toEqual(['groceries']);
    expect(params[2]).toBe(CategoryType.EXPENSE);
  });

  it('should total spent and planned and convert decimal strings', async () => {
    budgets.find.mockResolvedValue([budget('groceries'), budget('rent', { amount: '2500.50' })]);
    records.query.mockResolvedValue([
      row('admin', 'groceries', '2026-04-02T10:00:00Z', '120.25'),
      row('member', 'rent', '2026-04-03T10:00:00Z', '2000.00'),
    ]);

    const result = await summary();

    expect(result.totals).toEqual({ spent: 2120.25, planned: 3500.5, monthSpent: 2120.25 });
    expect(result.monthlyBudget).toBe(5000);
  });

  it('should list every member by spent, highest first, with 0 for members without spending', async () => {
    records.query.mockResolvedValue([
      row('admin', 'groceries', '2026-04-02T10:00:00Z', '50'),
      row('member', 'groceries', '2026-04-03T10:00:00Z', '80'),
    ]);

    const result = await summary();

    expect(result.members).toEqual([
      { userId: 'member', displayName: null, spent: 80 },
      { userId: 'admin', displayName: 'Karim', spent: 50 },
      { userId: 'quiet', displayName: null, spent: 0 },
    ]);
    expect(result.members.reduce((sum, m) => sum + m.spent, 0)).toBe(result.totals.spent);
  });

  it('should add rollover to the effective amount', async () => {
    budgets.find.mockResolvedValue([budget('groceries', { rolloverEnabled: true, rolloverAmount: '150.00' })]);

    expect((await summary()).sharedBudgets[0].effectiveAmount).toBe(1150);
  });

  it('should only count Records inside the budget current period', async () => {
    records.query.mockResolvedValue([
      row('admin', 'groceries', '2026-03-31T23:59:59Z', '999'),
      row('admin', 'groceries', '2026-04-01T00:00:00Z', '10'),
    ]);

    const [progress] = (await summary()).sharedBudgets;

    expect(progress.spent).toBe(10);
    expect(progress.periodStart).toBe('2026-04-01T00:00:00.000Z');
    expect(progress.periodEnd).toBe('2026-05-01T00:00:00.000Z');
  });

  it('should count monthSpent in the caller calendar month', async () => {
    // A weekly budget started on Monday 13 April, so its window crosses months.
    budgets.find.mockResolvedValue([budget('weekly', { period: BudgetPeriod.WEEKLY, startDate: new Date('2026-03-30T00:00:00Z') })]);
    records.query.mockResolvedValue([row('admin', 'weekly', '2026-04-14T10:00:00Z', '40')]);

    const result = await service.getSummary('group-1', 360, now);

    expect(result.month.start).toBe('2026-03-31T18:00:00.000Z');
    expect(result.totals.monthSpent).toBe(40);
  });

  it('should skip the Records query when the group has no shared budgets', async () => {
    budgets.find.mockResolvedValue([]);

    const result = await summary();

    expect(records.query).not.toHaveBeenCalled();
    expect(result.totals).toEqual({ spent: 0, planned: 0, monthSpent: 0 });
    expect(result.members.every((m) => m.spent === 0)).toBe(true);
  });

  it('should never send Record details', async () => {
    records.query.mockResolvedValue([row('admin', 'groceries', '2026-04-02T10:00:00Z', '50')]);

    const json = JSON.stringify(await summary());

    for (const field of ['description', 'categoryId', '2026-04-02']) expect(json).not.toContain(field);
  });
});
