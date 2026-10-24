import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { User } from '../auth/entities/user.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { CategoryType } from '../common/enums/category-type.enum';
import { Record as RecordEntity } from '../records/entities/record.entity';
import { currentMonth, currentPeriod, Period } from './budget-period';
import { Group } from './entities/group.entity';
import { GroupMember } from './entities/group-member.entity';
import { groupErrors } from './group-errors';
import { GroupSummaryResponse, SharedBudgetProgressView } from './groups.types';

interface SpendRow {
  userId: string;
  budgetId: string;
  date: Date;
  amount: string | number;
}

const round2 = (value: number) => Math.round(value * 100) / 100;
const inside = (date: Date, window: Period) => date >= window.start && date < window.end;

@Injectable()
export class GroupSummaryService {
  constructor(
    @InjectRepository(Group) private readonly groupRepo: Repository<Group>,
    @InjectRepository(GroupMember) private readonly memberRepo: Repository<GroupMember>,
    @InjectRepository(Budget) private readonly budgetRepo: Repository<Budget>,
    @InjectRepository(RecordEntity) private readonly recordRepo: Repository<RecordEntity>,
    @InjectRepository(User) private readonly userRepo: Repository<User>,
  ) {}

  async getSummary(groupId: string, utcOffsetMinutes: number, now = new Date()): Promise<GroupSummaryResponse> {
    const group = await this.groupRepo.findOne({ where: { id: groupId } });
    if (!group) throw groupErrors.notInGroup();
    // Current members only: a leaver's Records stop counting.
    const memberIds = (await this.memberRepo.find({ where: { groupId } })).map((m) => m.userId);
    const budgets = await this.budgetRepo.find({ where: { groupId, isEnabled: true } });
    const periods = new Map(budgets.map((b) => [b.id, currentPeriod(b.startDate, b.period, now, utcOffsetMinutes)]));
    const month = currentMonth(now, utcOffsetMinutes);
    const rows = await this.loadSpending(memberIds, budgets, [month, ...periods.values()]);

    const spentByBudget = new Map<string, number>();
    const spentByMember = new Map<string, number>(memberIds.map((id) => [id, 0]));
    let monthSpent = 0;
    for (const row of rows) {
      const amount = Number(row.amount);
      const date = new Date(row.date);
      if (inside(date, month)) monthSpent += amount;
      const window = periods.get(row.budgetId);
      if (!window || !inside(date, window)) continue;
      spentByBudget.set(row.budgetId, (spentByBudget.get(row.budgetId) ?? 0) + amount);
      spentByMember.set(row.userId, (spentByMember.get(row.userId) ?? 0) + amount);
    }

    const sharedBudgets = budgets.map((b) => this.toProgress(b, periods.get(b.id)!, spentByBudget.get(b.id) ?? 0));
    return {
      groupId,
      currencyCode: group.currencyCode,
      monthlyBudget: group.monthlyBudget === null ? null : Number(group.monthlyBudget),
      totals: {
        spent: round2(sharedBudgets.reduce((sum, b) => sum + b.spent, 0)),
        planned: round2(sharedBudgets.reduce((sum, b) => sum + b.effectiveAmount, 0)),
        monthSpent: round2(monthSpent),
      },
      members: await this.memberSpending(spentByMember),
      sharedBudgets,
      month: { start: month.start.toISOString(), end: month.end.toISOString() },
      generatedAt: now.toISOString(),
    };
  }

  /** One query for every budget window: expense Records linked to a Shared Budget. */
  private async loadSpending(memberIds: string[], budgets: Budget[], windows: Period[]): Promise<SpendRow[]> {
    if (memberIds.length === 0 || budgets.length === 0) return [];
    const earliest = new Date(Math.min(...windows.map((w) => w.start.getTime())));
    const rows: unknown = await this.recordRepo.query(
      `SELECT "userId", "budgetId", "date", "amount" FROM "records"
       WHERE "userId" = ANY($1) AND "budgetId" = ANY($2) AND "recordType" = $3 AND "date" >= $4`,
      [memberIds, budgets.map((b) => b.id), CategoryType.EXPENSE, earliest],
    );
    return rows as SpendRow[];
  }

  private toProgress(budget: Budget, window: Period, spent: number): SharedBudgetProgressView {
    const amount = Number(budget.amount);
    const rollover = budget.rolloverEnabled ? Number(budget.rolloverAmount) : 0;
    return {
      id: budget.id,
      name: budget.name,
      period: budget.period,
      amount: round2(amount),
      effectiveAmount: round2(amount + rollover),
      spent: round2(spent),
      periodStart: window.start.toISOString(),
      periodEnd: window.end.toISOString(),
    };
  }

  private async memberSpending(spentByMember: Map<string, number>): Promise<GroupSummaryResponse['members']> {
    const users = await this.userRepo.find({ where: { id: In([...spentByMember.keys()]) } });
    const names = new Map(users.map((u) => [u.id, u.displayName ?? null]));
    return [...spentByMember.entries()]
      .map(([userId, spent]) => ({ userId, displayName: names.get(userId) ?? null, spent: round2(spent) }))
      .sort((a, b) => b.spent - a.spent);
  }
}
