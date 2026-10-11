import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Record } from './entities/record.entity';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';
import { QueryRecordsDto } from './dto/query-records.dto';
import { FillRecordBudgetLinksResult, PaginatedResult } from './records.types';
import { RecordBudgetLinkItem } from './dto/fill-record-budget-links.dto';

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

  /**
   * Restores budget links the server dropped before records had a budgetId
   * column. Only rows of this user without a link are touched; nothing is
   * created and no other field changes. The budget is not checked against the
   * user's budgets: Family members link Records to an Admin's Shared Budget.
   *
   * `updatedAt` is left alone on purpose: bumping it would make sync reject
   * edits other devices queued earlier as conflicts (ADR 0012).
   *
   * One raw statement fills every row at once; the repository API would need
   * a query per link. The table and column names below mirror the Record
   * entity mapping and must change with it.
   */
  async fillMissingBudgetLinks(userId: string, links: RecordBudgetLinkItem[]): Promise<FillRecordBudgetLinksResult> {
    if (links.length === 0) return { updated: 0 };

    const result: unknown = await this.recordRepository.query(
      `UPDATE "records" AS r
          SET "budgetId" = v."budgetId"
         FROM unnest($1::text[], $2::text[]) AS v("id", "budgetId")
        WHERE r."id" = v."id" AND r."userId" = $3 AND r."budgetId" IS NULL`,
      [links.map((l) => l.id), links.map((l) => l.budgetId), userId],
    );
    // pg returns [rows, rowCount] for UPDATE through TypeORM's query().
    const updated = Array.isArray(result) && typeof result[1] === 'number' ? result[1] : 0;
    return { updated };
  }
}
