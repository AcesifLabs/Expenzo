import { Type } from 'class-transformer';
import { IsInt, IsOptional, Max, Min } from 'class-validator';

export class GroupSummaryQueryDto {
  /** The caller's offset from UTC; mobile sends DateTime.now().timeZoneOffset.inMinutes. */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(-840)
  @Max(840)
  utcOffsetMinutes: number = 0;
}
