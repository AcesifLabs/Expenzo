import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GroupMember } from '../entities/group-member.entity';
import { GroupRole } from '../groups.constants';
import { GROUP_ROLES_KEY } from '../decorators/group-roles.decorator';
import { groupErrors } from '../group-errors';

export interface GroupRequest {
  params: { id?: string };
  user?: { sub?: string };
  
  groupMember?: GroupMember;
}


@Injectable()
export class GroupRoleGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    @InjectRepository(GroupMember) private readonly memberRepo: Repository<GroupMember>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<GroupRequest>();
    const groupId = request.params.id;
    const userId = request.user?.sub;
    const member = groupId && userId ? await this.memberRepo.findOne({ where: { groupId, userId } }) : null;
    if (!member) throw groupErrors.notInGroup();

    const roles = this.reflector.getAllAndOverride<GroupRole[] | undefined>(GROUP_ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (roles && !roles.includes(member.role)) throw new ForbiddenException('This role cannot do that');

    request.groupMember = member;
    return true;
  }
}
