import { IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { CreateRecordDto } from './create-record.dto';

export class BulkCreateRecordDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => CreateRecordDto)
  records: CreateRecordDto[];
}
