import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Record } from './entities/record.entity';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';
import { QueryRecordsDto } from './dto/query-records.dto';
import { PaginatedResult } from './records.types';

@Injectable()
export class RecordsService {
  constructor(@InjectRepository(Record) private readonly recordRepository: Repository<Record>) {}

  async findAll(userId: string, query: QueryRecordsDto): Promise<PaginatedResult<Record>> {
    const { cursor, limit = 50, startDate, endDate, categoryIds, recordType } = query;
    const qb = this.recordRepository.createQueryBuilder('record')
      .where('record.userId = :userId', { userId })
      .orderBy('record.id', 'ASC').take(limit);
    if (cursor) qb.andWhere('record.id > :cursor', { cursor });
    if (startDate) qb.andWhere('record.date >= :startDate', { startDate: new Date(startDate) });
    if (endDate) qb.andWhere('record.date <= :endDate', { endDate: new Date(endDate) });
    if (categoryIds && categoryIds.length > 0) {
      qb.andWhere('record.categoryId IN (:...categoryIds)', { categoryIds });
    }
    if (recordType) qb.andWhere('record.recordType = :recordType', { recordType });
    const [data, total] = await qb.getManyAndCount();
    const nextCursor = data.length === limit ? data[data.length - 1]?.id : null;
    return { data, nextCursor, total };
  }

  async findById(userId: string, id: string): Promise<Record> {
    const record = await this.recordRepository.findOne({ where: { id, userId } });
    if (!record) throw new NotFoundException(`Record ${id} not found`);
    return record;
  }

  async create(userId: string, dto: CreateRecordDto): Promise<Record> {
    const record = this.recordRepository.create({ ...dto, userId, date: new Date(dto.date) });
    return this.recordRepository.save(record);
  }

  async createBulk(userId: string, dtos: CreateRecordDto[]): Promise<Record[]> {
    const records = dtos.map(dto => this.recordRepository.create({ ...dto, userId, date: new Date(dto.date) }));
    return this.recordRepository.save(records);
  }

  async update(userId: string, id: string, dto: UpdateRecordDto): Promise<Record> {
    const record = await this.findById(userId, id);
    if (dto.amount !== undefined) record.amount = dto.amount;
    if (dto.description !== undefined) record.description = dto.description;
    if (dto.date !== undefined) record.date = new Date(dto.date);
    if (dto.categoryId !== undefined) record.categoryId = dto.categoryId;
    if (dto.recordType !== undefined) record.recordType = dto.recordType;
    return this.recordRepository.save(record);
  }

  async remove(userId: string, id: string): Promise<void> {
    const result = await this.recordRepository.delete({ id, userId });
    if (result.affected === 0) throw new NotFoundException(`Record ${id} not found`);
  }
}
