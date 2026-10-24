import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../auth/entities/user.entity';
import { Budget } from '../budgets/entities/budget.entity';
import { Record } from '../records/entities/record.entity';
import { Group } from './entities/group.entity';
import { GroupMember } from './entities/group-member.entity';
import { GroupInvite } from './entities/group-invite.entity';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';
import { GroupSummaryService } from './group-summary.service';
import { GroupRoleGuard } from './guards/group-role.guard';

@Module({
  imports: [TypeOrmModule.forFeature([Group, GroupMember, GroupInvite, Budget, User, Record])],
  controllers: [GroupsController],
  providers: [GroupsService, GroupSummaryService, GroupRoleGuard],
  exports: [GroupsService, TypeOrmModule],
})
export class GroupsModule {}
