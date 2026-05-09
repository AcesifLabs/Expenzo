import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_GUARD } from '@nestjs/core';
import { AuthModule } from './auth/auth.module';
import { CommonModule } from './common/common.module';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { RecordsModule } from './records/records.module';
import { CategoriesModule } from './categories/categories.module';
import { BudgetsModule } from './budgets/budgets.module';
import { MessageSourcesModule } from './message-sources/message-sources.module';
import { ExpenseTemplatesModule } from './expense-templates/expense-templates.module';
import { ParsingRulesModule } from './parsing-rules/parsing-rules.module';
import { RecurringTransactionsModule } from './recurring-transactions/recurring-transactions.module';
import { SyncModule } from './sync/sync.module';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.get<string>('DATABASE_URL'),
        ssl: { rejectUnauthorized: false },
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: false, // use migrations
        logging: config.get('NODE_ENV') !== 'production',
        autoLoadEntities: true,
        extra: {
          connectionTimeoutMillis: 15000,
        },
      }),
    }),
    CommonModule,
    AuthModule,
    RecordsModule,
    CategoriesModule,
    BudgetsModule,
    MessageSourcesModule,
    ExpenseTemplatesModule,
    ParsingRulesModule,
    RecurringTransactionsModule,
    SyncModule,
  ],
  controllers: [AppController],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
