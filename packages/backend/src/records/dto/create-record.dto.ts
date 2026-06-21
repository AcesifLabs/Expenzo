import { IsString, IsNumber, IsOptional, IsEnum, IsDateString, IsNotEmpty, IsUUID } from 'class-validator';
import { RecordSource } from '../../common/enums/record-source.enum';
import { CategoryType } from '../../common/enums/category-type.enum';

export class CreateRecordDto {
  @IsNumber() @IsNotEmpty() amount: number;
  @IsString() @IsNotEmpty() description: string;
  @IsDateString() @IsNotEmpty() date: string;
  @IsUUID('4') @IsOptional() categoryId?: string;
  @IsEnum(RecordSource) @IsOptional() source?: RecordSource = RecordSource.MANUAL;
  @IsString() @IsOptional() sourceId?: string;
  @IsEnum(CategoryType) @IsNotEmpty() recordType: CategoryType;
}
