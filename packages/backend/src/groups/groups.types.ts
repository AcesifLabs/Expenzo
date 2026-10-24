import { BudgetPeriod } from '../common/enums/budget-period.enum';
import { GroupRole } from './groups.constants';

/**
 * Stable codes in group error bodies: `{ code, message }`. Mobile maps on
 * `code`, never on `message`, which is English diagnostic text only.
 */
export type GroupErrorCode =
  | 'ALREADY_IN_GROUP'
  | 'NOT_IN_GROUP'
  | 'INVITE_NOT_FOUND'
  | 'INVITE_EXPIRED'
  | 'CURRENCY_MISMATCH'
  | 'GROUP_FULL'
  | 'LAST_ADMIN';

export interface GroupErrorBody {
  code: GroupErrorCode;
  message: string;
}

export interface GroupMemberView {
  userId: string;
  displayName: string | null;
  photoUrl: string | null;
  role: GroupRole;
  joinedAt: string;
}

export interface SharedBudgetRef {
  id: string;
  name: string;
  ownerId: string;
}

export interface InviteView {
  code: string;
  expiresAt: string;
}

export interface GroupView {
  id: string;
  name: string;
  currencyCode: string;
  monthlyBudget: number | null;
  createdAt: string;
}

/** `GET /groups/me`. Every field is empty when the caller is in no group. */
export interface MyGroupResponse {
  group: GroupView | null;
  /** The caller's server user id; the phone only knows its Firebase uid. */
  me: { userId: string; role: GroupRole } | null;
  /** Sorted by joinedAt, oldest first (mobile avatar colours follow this order). */
  members: GroupMemberView[];
  /** Every budget shared into the group, whoever owns it. */
  sharedBudgets: SharedBudgetRef[];
  /** The newest unexpired code, for Admins only. */
  invite: InviteView | null;
}

export interface SharedBudgetProgressView {
  id: string;
  name: string;
  period: BudgetPeriod;
  amount: number;
  /** amount plus rollover, as on the phone (GetBudgetProgress). */
  effectiveAmount: number;
  spent: number;
  periodStart: string;
  periodEnd: string;
}

/**
 * `GET /groups/:id/summary` (ADR 0008). Counts only expense Records of
 * current members linked to the group's Shared Budgets; a member's other
 * Records stay private and no single Record is sent.
 */
export interface GroupSummaryResponse {
  groupId: string;
  currencyCode: string;
  monthlyBudget: number | null;
  totals: { spent: number; planned: number; monthSpent: number };
  /** Every current member, sorted by spent, highest first. */
  members: { userId: string; displayName: string | null; spent: number }[];
  sharedBudgets: SharedBudgetProgressView[];
  month: { start: string; end: string };
  generatedAt: string;
}
