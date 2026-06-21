import { IsArray, IsString, IsEnum, IsObject, IsOptional, IsDateString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export enum SyncAction { INSERT = 'insert', UPDATE = 'update', DELETE = 'delete' }
export enum SyncTable {
  RECORDS = 'records', CATEGORIES = 'categories', BUDGETS = 'budgets',
  MESSAGE_SOURCES = 'message_sources', EXPENSE_TEMPLATES = 'expense_templates',
  PARSING_RULES = 'parsing_rules', RECURRING_TRANSACTIONS = 'recurring_transactions',
  PENDING_RECURRING = 'pending_recurring',
}

export class SyncChangeItem {
  @IsEnum(SyncTable) table: SyncTable;
  @IsEnum(SyncAction) action: SyncAction;
  @IsString() id: string;
  @IsObject() @IsOptional() data?: Record<string, unknown>;
  @IsDateString() @IsOptional() updatedAt?: string;
}

export class PushSyncDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => SyncChangeItem)
  changes: SyncChangeItem[];
}
