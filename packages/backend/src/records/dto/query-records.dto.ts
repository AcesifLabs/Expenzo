import { IsOptional, IsUUID, IsInt, Min, Max, IsDateString, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';
import { RecordType } from './create-record.dto';

export class QueryRecordsDto {
  @IsUUID('4') @IsOptional() cursor?: string;
  @IsInt() @Min(1) @Max(100) @IsOptional() @Type(() => Number) limit?: number = 50;
  @IsDateString() @IsOptional() startDate?: string;
  @IsDateString() @IsOptional() endDate?: string;
  @IsUUID('4') @IsOptional() categoryId?: string;
  @IsEnum(RecordType) @IsOptional() recordType?: RecordType;
}
