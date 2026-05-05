import { IsString, IsNumber, IsOptional, IsEnum, IsDateString, IsNotEmpty, IsUUID } from 'class-validator';

export enum RecordType { INCOME = 'IN', EXPENSE = 'OUT' }

export class CreateRecordDto {
  @IsNumber() @IsNotEmpty() amount: number;
  @IsString() @IsNotEmpty() description: string;
  @IsDateString() @IsNotEmpty() date: string;
  @IsUUID('4') @IsOptional() categoryId?: string;
  @IsString() @IsOptional() source?: string = 'manual';
  @IsString() @IsOptional() sourceId?: string;
  @IsEnum(RecordType) @IsNotEmpty() recordType: RecordType;
}
