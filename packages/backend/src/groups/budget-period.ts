import { BudgetPeriod } from '../common/enums/budget-period.enum';


export interface Period {
  start: Date;
  end: Date;
}

const MINUTE_MS = 60 * 1000;
const DAY_MS = 24 * 60 * MINUTE_MS;


const toWall = (instant: Date, offset: number) => new Date(instant.getTime() + offset * MINUTE_MS);
const fromWall = (wall: Date, offset: number) => new Date(wall.getTime() - offset * MINUTE_MS);

const wallDate = (year: number, month: number, day: number) => new Date(Date.UTC(year, month - 1, day));
const daysInMonth = (year: number, month: number) => wallDate(year, month + 1, 0).getUTCDate();


export function currentPeriod(startDate: Date, period: BudgetPeriod, now: Date, utcOffsetMinutes: number): Period {
  const start = toWall(startDate, utcOffsetMinutes);
  const wallNow = toWall(now, utcOffsetMinutes);
  const wall = periodFor(period, start, wallNow);
  return { start: fromWall(wall.start, utcOffsetMinutes), end: fromWall(wall.end, utcOffsetMinutes) };
}


export function currentMonth(now: Date, utcOffsetMinutes: number): Period {
  const wallNow = toWall(now, utcOffsetMinutes);
  const year = wallNow.getUTCFullYear();
  const month = wallNow.getUTCMonth() + 1;
  return {
    start: fromWall(wallDate(year, month, 1), utcOffsetMinutes),
    end: fromWall(wallDate(year, month + 1, 1), utcOffsetMinutes),
  };
}

function periodFor(period: BudgetPeriod, start: Date, now: Date): Period {
  switch (period) {
    case BudgetPeriod.WEEKLY:
      return weekly(start, now);
    case BudgetPeriod.YEARLY:
      return yearly(start, now);
    default:
      return monthly(start, now);
  }
}

function weekly(start: Date, now: Date): Period {
  
  const diff = Math.trunc((now.getTime() - start.getTime()) / DAY_MS);
  const offset = ((diff % 7) + 7) % 7;
  const [y, m, d] = [now.getUTCFullYear(), now.getUTCMonth() + 1, now.getUTCDate()];
  return { start: wallDate(y, m, d - offset), end: wallDate(y, m, d - offset + 7) };
}

function monthly(start: Date, now: Date): Period {
  const startDay = start.getUTCDate();
  const clampedStartDay = Math.min(Math.max(startDay, 1), 28);
  const [year, month] = [now.getUTCFullYear(), now.getUTCMonth() + 1];
  const thisMonthStart = wallDate(year, month, Math.min(startDay, daysInMonth(year, month)));

  let periodStart = thisMonthStart;
  if (now < thisMonthStart) {
    const [prevYear, prevMonth] = month === 1 ? [year - 1, 12] : [year, month - 1];
    periodStart = wallDate(prevYear, prevMonth, Math.min(startDay, daysInMonth(prevYear, prevMonth)));
  }

  const [endYear, endMonth] =
    periodStart.getUTCMonth() === 11
      ? [periodStart.getUTCFullYear() + 1, 1]
      : [periodStart.getUTCFullYear(), periodStart.getUTCMonth() + 2];
  const endDay = Math.min(clampedStartDay, daysInMonth(endYear, endMonth));
  return { start: periodStart, end: wallDate(endYear, endMonth, endDay) };
}

function yearly(start: Date, now: Date): Period {
  const [startMonth, startDay] = [start.getUTCMonth() + 1, start.getUTCDate()];
  const year = now.getUTCFullYear();
  const effectiveStartDay = Math.min(startDay, daysInMonth(year, startMonth));
  const thisYearStart = wallDate(year, startMonth, effectiveStartDay);
  const periodStartYear = now >= thisYearStart ? year : year - 1;

  const endYear = periodStartYear + 1;
  const endDay = Math.min(startDay, daysInMonth(endYear, startMonth));
  
  return { start: wallDate(periodStartYear, startMonth, effectiveStartDay), end: wallDate(endYear, startMonth, endDay) };
}
