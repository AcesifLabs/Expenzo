import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Budget } from './entities/budget.entity';
import { BudgetsController } from './budgets.controller';
import { BudgetsService } from './budgets.service';

@Module({
  imports: [TypeOrmModule.forFeature([Budget])],
  controllers: [BudgetsController],
  providers: [BudgetsService],
  exports: [TypeOrmModule],
})
export class BudgetsModule {}
