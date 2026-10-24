import { SetMetadata } from '@nestjs/common';
import { GroupRole } from '../groups.constants';

export const GROUP_ROLES_KEY = 'groupRoles';

/** Roles allowed on a `/groups/:id/...` route. Without it, any member passes. */
export const GroupRoles = (...roles: GroupRole[]) => SetMetadata(GROUP_ROLES_KEY, roles);
