import { SyncTable } from './dto/push-sync.dto';

export enum SyncStatus {
  SUCCESS = 'success',
  CONFLICT = 'conflict',
  ERROR = 'error',
}

export interface SyncResult {
  id: string;
  status: SyncStatus;
}

export interface SyncSuccessResult extends SyncResult {
  status: SyncStatus.SUCCESS;
  serverId?: string;
  message?: string;
}

export interface SyncConflictResult extends SyncResult {
  status: SyncStatus.CONFLICT;
  serverId: string;
  message: string;
}

export interface SyncErrorResult extends SyncResult {
  status: SyncStatus.ERROR;
  message: string;
}

export type SyncActionResult = SyncSuccessResult | SyncConflictResult | SyncErrorResult;

export interface PullChange {
  table: SyncTable;
  action: string;
  id: string;
  data: Record<string, unknown>;
  updatedAt?: string;
}

export interface PullChangesResponse {
  changes: PullChange[];
  serverTime: string;
}

export interface SyncSummary {
  totalCount: number;
  tables: Record<string, number>;
}

export interface SyncPushResponse {
  results: SyncActionResult[];
}
