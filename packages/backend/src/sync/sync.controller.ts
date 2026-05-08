import { Controller, Post, Get, Delete, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { SyncService } from './sync.service';
import { PushSyncDto } from './dto/push-sync.dto';
import { PullSyncQueryDto } from './dto/pull-sync-query.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('sync')
@UseGuards(JwtAuthGuard)
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post('push')
  @HttpCode(HttpStatus.OK)
  push(@CurrentUser('sub') userId: string, @Body() dto: PushSyncDto) {
    return this.syncService.pushChanges(userId, dto);
  }

  @Get('pull')
  pull(@CurrentUser('sub') userId: string, @Query() query: PullSyncQueryDto) {
    return this.syncService.pullChanges(userId, query.since);
  }

  @Get('summary')
  async summary(@CurrentUser('sub') userId: string) {
    return this.syncService.getSummary(userId);
  }

  @Delete('clear')
  @HttpCode(HttpStatus.OK)
  async clear(@CurrentUser('sub') userId: string) {
    await this.syncService.clearUserData(userId);
    return { status: 'cleared' };
  }
}
