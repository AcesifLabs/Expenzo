import { Type } from 'class-transformer';
import { ArrayMaxSize, IsArray, IsNotEmpty, IsString, MaxLength, ValidateNested } from 'class-validator';
import { BUDGET_NAME_MAX_LENGTH, FILL_BUDGET_NAMES_MAX_ITEMS } from '../budgets.constants';

export class BudgetNameItem {
  @IsString() @IsNotEmpty() id: string;
  @IsString() @IsNotEmpty() @MaxLength(BUDGET_NAME_MAX_LENGTH) name: string;
}

export class FillBudgetNamesDto {
  @IsArray() @ArrayMaxSize(FILL_BUDGET_NAMES_MAX_ITEMS) @ValidateNested({ each: true }) @Type(() => BudgetNameItem)
  names: BudgetNameItem[];
}
