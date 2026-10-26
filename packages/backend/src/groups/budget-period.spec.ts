import { BudgetPeriod } from '../common/enums/budget-period.enum';
import { currentMonth, currentPeriod } from './budget-period';



const DHAKA = 360;

const dhaka = (iso: string) => new Date(new Date(`${iso}Z`).getTime() - DHAKA * 60_000);
const period = (start: string, kind: BudgetPeriod, now: string, offset = DHAKA) =>
  currentPeriod(dhaka(start), kind, dhaka(now), offset);

describe('currentPeriod', () => {
  it('should align weekly windows to the start date', () => {
    expect(period('2026-01-07T09:00', BudgetPeriod.WEEKLY, '2026-03-02T12:00')).toEqual({
      start: dhaka('2026-02-25T00:00'),
      end: dhaka('2026-03-04T00:00'),
    });
  });

  it('should start a monthly budget from the 31st on the last day of February', () => {
    expect(period('2026-01-31T10:00', BudgetPeriod.MONTHLY, '2026-02-28T12:00')).toEqual({
      start: dhaka('2026-02-28T00:00'),
      end: dhaka('2026-03-28T00:00'),
    });
  });

  it('should use the previous month before this month start day', () => {
    expect(period('2026-01-15T10:00', BudgetPeriod.MONTHLY, '2026-03-10T12:00')).toEqual({
      start: dhaka('2026-02-15T00:00'),
      end: dhaka('2026-03-15T00:00'),
    });
  });

  it('should roll a December period into January', () => {
    expect(period('2026-01-20T10:00', BudgetPeriod.MONTHLY, '2026-12-25T12:00')).toEqual({
      start: dhaka('2026-12-20T00:00'),
      end: dhaka('2027-01-20T00:00'),
    });
  });

  it('should run yearly periods from the start date anniversary', () => {
    expect(period('2025-04-10T10:00', BudgetPeriod.YEARLY, '2026-03-01T12:00')).toEqual({
      start: dhaka('2025-04-10T00:00'),
      end: dhaka('2026-04-10T00:00'),
    });
  });

  it('should clamp a 29 February start in a non-leap year', () => {
    expect(period('2024-02-29T10:00', BudgetPeriod.YEARLY, '2026-06-01T12:00')).toEqual({
      start: dhaka('2026-02-28T00:00'),
      end: dhaka('2027-02-28T00:00'),
    });
  });

  it('should depend on the caller time zone at a month boundary', () => {
    const startDate = new Date('2026-01-01T06:00:00Z');
    const now = new Date('2026-01-31T23:30:00Z');

    
    expect(currentPeriod(startDate, BudgetPeriod.MONTHLY, now, 0).start.toISOString()).toBe('2026-01-01T00:00:00.000Z');
    expect(currentPeriod(startDate, BudgetPeriod.MONTHLY, now, DHAKA).start.toISOString()).toBe('2026-01-31T18:00:00.000Z');
  });
});

describe('currentMonth', () => {
  it('should return the calendar month in the caller time zone', () => {
    
    expect(currentMonth(new Date('2026-03-01T02:00:00Z'), -300)).toEqual({
      start: new Date('2026-02-01T05:00:00Z'),
      end: new Date('2026-03-01T05:00:00Z'),
    });
  });
});
