import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Goal } from './entities/goal.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Goal])],
  exports: [TypeOrmModule],
})
export class GoalsModule {}
