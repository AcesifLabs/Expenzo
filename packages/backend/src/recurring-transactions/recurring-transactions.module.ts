import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RecurringTransaction } from './entities/recurring-transaction.entity';
import { PendingRecurring } from './entities/pending-recurring.entity';

@Module({
  imports: [TypeOrmModule.forFeature([RecurringTransaction, PendingRecurring])],
  exports: [TypeOrmModule],
})
export class RecurringTransactionsModule {}
