import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ParsingRule } from './entities/parsing-rule.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ParsingRule])],
  exports: [TypeOrmModule],
})
export class ParsingRulesModule {}
