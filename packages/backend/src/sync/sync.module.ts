import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SyncController } from './sync.controller';
import { SyncService } from './sync.service';
import { Record } from '../records/entities/record.entity';
import { Category } from '../categories/entities/category.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { MessageSource } from '../message-sources/entities/message-source.entity';
import { ExpenseTemplate } from '../expense-templates/entities/expense-template.entity';
import { ParsingRule } from '../parsing-rules/entities/parsing-rule.entity';
import { RecurringTransaction } from '../recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from '../recurring-transactions/entities/pending-recurring.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Record, Category, Budget, MessageSource, ExpenseTemplate, ParsingRule, RecurringTransaction, PendingRecurring])],
  controllers: [SyncController],
  providers: [SyncService],
})
export class SyncModule {}
