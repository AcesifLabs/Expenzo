import { Transform } from 'class-transformer';
import { IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, Matches, Max, MaxLength } from 'class-validator';
import { GROUP_NAME_MAX_LENGTH } from '../groups.constants';

export class CreateGroupDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @IsNotEmpty()
  @MaxLength(GROUP_NAME_MAX_LENGTH)
  name: string;

  @Matches(/^[A-Z]{3}$/)
  currencyCode: string;

  // The column is decimal(12,2).
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Max(9999999999.99)
  monthlyBudget?: number;
}
