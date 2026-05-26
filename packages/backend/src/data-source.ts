import './config/force-ipv4'; // MUST be first import
import { DataSource } from 'typeorm';
import { config } from 'dotenv';
import { User } from './auth/entities/user.entity';
import { Record } from './records/entities/record.entity';
import { Category } from './categories/entities/category.entity';
import { Budget } from './budgets/entities/budget.entity';
import { MessageSource } from './message-sources/entities/message-source.entity';
import { ExpenseTemplate } from './expense-templates/entities/expense-template.entity';
import { ParsingRule } from './parsing-rules/entities/parsing-rule.entity';
import { RecurringTransaction } from './recurring-transactions/entities/recurring-transaction.entity';
import { PendingRecurring } from './recurring-transactions/entities/pending-recurring.entity';
import { getDatabaseSslConfig } from './config/database-ssl';

config();

export default new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  ssl: getDatabaseSslConfig(process.env.DATABASE_URL, process.env.DATABASE_SSL),
  entities: [User, Record, Category, Budget, MessageSource, ExpenseTemplate, ParsingRule, RecurringTransaction, PendingRecurring],
  migrations: [__dirname + '/migrations/**/*{.ts,.js}'],
});
