import { Controller, Get, Post, Body, Put, Param, Delete, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { RecordsService } from './records.service';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';
import { QueryRecordsDto } from './dto/query-records.dto';
import { BulkCreateRecordDto } from './dto/bulk-create-record.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('records')
@UseGuards(JwtAuthGuard)
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  @Get()
  findAll(@CurrentUser('sub') userId: string, @Query() query: QueryRecordsDto) {
    return this.recordsService.findAll(userId, query);
  }

  @Get(':id')
  findById(@CurrentUser('sub') userId: string, @Param('id') id: string) {
    return this.recordsService.findById(userId, id);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@CurrentUser('sub') userId: string, @Body() dto: CreateRecordDto) {
    return this.recordsService.create(userId, dto);
  }

  @Post('bulk')
  @HttpCode(HttpStatus.CREATED)
  createBulk(@CurrentUser('sub') userId: string, @Body() dto: BulkCreateRecordDto) {
    return this.recordsService.createBulk(userId, dto.records);
  }

  @Put(':id')
  update(@CurrentUser('sub') userId: string, @Param('id') id: string, @Body() dto: UpdateRecordDto) {
    return this.recordsService.update(userId, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@CurrentUser('sub') userId: string, @Param('id') id: string) {
    return this.recordsService.remove(userId, id);
  }
}
