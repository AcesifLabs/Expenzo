import { Body, Controller, Delete, Get, HttpCode, HttpStatus, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateGroupDto } from './dto/create-group.dto';
import { JoinGroupDto } from './dto/join-group.dto';
import { UpdateMemberRoleDto } from './dto/update-member-role.dto';
import { GroupRoles } from './decorators/group-roles.decorator';
import { GroupRequest, GroupRoleGuard } from './guards/group-role.guard';
import { GroupRole } from './groups.constants';
import { GroupsService } from './groups.service';
import { GroupSummaryService } from './group-summary.service';
import { GroupSummaryQueryDto } from './dto/group-summary-query.dto';

@Controller('groups')
@UseGuards(JwtAuthGuard)
export class GroupsController {
  constructor(
    private readonly groupsService: GroupsService,
    private readonly summaryService: GroupSummaryService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@CurrentUser('sub') userId: string, @Body() dto: CreateGroupDto) {
    return this.groupsService.create(userId, dto);
  }

  // "me" and "join" are declared before any `:id` route so they are never read as an id.
  @Get('me')
  getMine(@CurrentUser('sub') userId: string) {
    return this.groupsService.getMine(userId);
  }

  @Post('join')
  @HttpCode(HttpStatus.OK)
  join(@CurrentUser('sub') userId: string, @Body() dto: JoinGroupDto) {
    return this.groupsService.join(userId, dto);
  }

  @Post(':id/invites')
  @UseGuards(GroupRoleGuard)
  @GroupRoles(GroupRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  createInvite(@Param('id') groupId: string, @CurrentUser('sub') userId: string) {
    return this.groupsService.createInvite(groupId, userId);
  }

  /** Any role may read it (Admin, Member, Viewer). */
  @Get(':id/summary')
  @UseGuards(GroupRoleGuard)
  getSummary(@Param('id') groupId: string, @Query() query: GroupSummaryQueryDto) {
    return this.summaryService.getSummary(groupId, query.utcOffsetMinutes);
  }

  @Patch(':id/members/:userId')
  @UseGuards(GroupRoleGuard)
  @GroupRoles(GroupRole.ADMIN)
  updateRole(
    @Param('id') groupId: string,
    @Param('userId') targetId: string,
    @Body() dto: UpdateMemberRoleDto,
    @CurrentUser('sub') callerId: string,
  ) {
    return this.groupsService.updateRole(groupId, targetId, dto, callerId);
  }

  /** Leave (your own userId) or, for an Admin, remove someone else. */
  @Delete(':id/members/:userId')
  @UseGuards(GroupRoleGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  async removeMember(@Param('id') groupId: string, @Param('userId') targetId: string, @Req() request: GroupRequest) {
    await this.groupsService.removeMember(groupId, targetId, request.groupMember!);
  }

  @Delete(':id')
  @UseGuards(GroupRoleGuard)
  @GroupRoles(GroupRole.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteGroup(@Param('id') groupId: string) {
    await this.groupsService.deleteGroup(groupId);
  }
}
