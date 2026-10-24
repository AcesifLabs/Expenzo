import { IsEnum } from 'class-validator';
import { GroupRole } from '../groups.constants';

export class UpdateMemberRoleDto {
  @IsEnum(GroupRole)
  role: GroupRole;
}
