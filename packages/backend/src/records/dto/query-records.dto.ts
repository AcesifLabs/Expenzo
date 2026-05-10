import { IsOptional, IsUUID, IsInt, Min, Max, IsDateString, IsEnum } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { RecordType } from './create-record.dto';

export class QueryRecordsDto {
  @IsUUID('4') @IsOptional() cursor?: string;
  @IsInt() @Min(1) @Max(100) @IsOptional() @Type(() => Number) limit?: number = 50;
  @IsDateString() @IsOptional() startDate?: string;
  @IsDateString() @IsOptional() endDate?: string;
  @IsOptional()
  @IsUUID('4', { each: true })
  @Transform(({ value }) => {
    if (Array.isArray(value)) return value;
    if (typeof value === 'string') return value.split(',').filter(Boolean);
    return undefined;
  })
  categoryIds?: string[];
  @IsEnum(RecordType) @IsOptional() recordType?: RecordType;
}
