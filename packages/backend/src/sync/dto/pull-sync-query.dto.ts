import { IsDateString, IsOptional } from 'class-validator';
export class PullSyncQueryDto {
  @IsDateString() @IsOptional() since?: string;
}
