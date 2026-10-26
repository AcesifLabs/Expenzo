import { Transform } from 'class-transformer';
import { Matches } from 'class-validator';

export class JoinGroupDto {
  
  @Transform(({ value }) => (typeof value === 'string' ? value.replace(/\s+/g, '').toUpperCase() : value))
  @Matches(/^[A-HJKMNP-Z2-9]{6}$/)
  code: string;

  @Matches(/^[A-Z]{3}$/)
  currencyCode: string;
}
