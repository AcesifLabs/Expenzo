import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExpenseTemplate } from './entities/expense-template.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ExpenseTemplate])],
  exports: [TypeOrmModule],
})
export class ExpenseTemplatesModule {}
