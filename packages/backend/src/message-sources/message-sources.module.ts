import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MessageSource } from './entities/message-source.entity';

@Module({
  imports: [TypeOrmModule.forFeature([MessageSource])],
  exports: [TypeOrmModule],
})
export class MessageSourcesModule {}
