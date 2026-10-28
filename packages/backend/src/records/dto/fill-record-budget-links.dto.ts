import { Type } from 'class-transformer';
import { ArrayMaxSize, ArrayUnique, IsArray, IsNotEmpty, IsString, ValidateNested } from 'class-validator';
import { FILL_RECORD_BUDGET_LINKS_MAX_ITEMS } from '../records.constants';

export class RecordBudgetLinkItem {
  @IsString() @IsNotEmpty() id: string;
  @IsString() @IsNotEmpty() budgetId: string;
}

export class FillRecordBudgetLinksDto {
  
  @IsArray()
  @ArrayMaxSize(FILL_RECORD_BUDGET_LINKS_MAX_ITEMS)
  @ArrayUnique((link: RecordBudgetLinkItem) => link.id)
  @ValidateNested({ each: true })
  @Type(() => RecordBudgetLinkItem)
  links: RecordBudgetLinkItem[];
}
