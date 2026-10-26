import { BudgetPeriod } from '../common/enums/budget-period.enum';
import { GroupRole } from './groups.constants';


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


export interface MyGroupResponse {
  group: GroupView | null;
  
  me: { userId: string; role: GroupRole } | null;
  
  members: GroupMemberView[];
  
  sharedBudgets: SharedBudgetRef[];
  
  invite: InviteView | null;
}

export interface SharedBudgetProgressView {
  id: string;
  name: string;
  period: BudgetPeriod;
  amount: number;
  
  effectiveAmount: number;
  spent: number;
  periodStart: string;
  periodEnd: string;
}


export interface GroupSummaryResponse {
  groupId: string;
  currencyCode: string;
  monthlyBudget: number | null;
  totals: { spent: number; planned: number; monthSpent: number };
  
  members: { userId: string; displayName: string | null; spent: number }[];
  sharedBudgets: SharedBudgetProgressView[];
  month: { start: string; end: string };
  generatedAt: string;
}
