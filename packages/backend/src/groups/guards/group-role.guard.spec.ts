import { ExecutionContext, ForbiddenException, NotFoundException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { GroupRoleGuard } from './group-role.guard';
import { GroupRole } from '../groups.constants';

describe('GroupRoleGuard', () => {
  const memberRepo = { findOne: jest.fn() };
  const reflector = { getAllAndOverride: jest.fn() };
  let guard: GroupRoleGuard;
  let request: { params: { id?: string }; user?: { sub?: string }; groupMember?: unknown };

  const context = () =>
    ({
      switchToHttp: () => ({ getRequest: () => request }),
      getHandler: () => undefined,
      getClass: () => undefined,
    }) as unknown as ExecutionContext;

  beforeEach(() => {
    memberRepo.findOne.mockReset();
    reflector.getAllAndOverride.mockReset().mockReturnValue(undefined);
    request = { params: { id: 'group-1' }, user: { sub: 'user-1' } };
    guard = new GroupRoleGuard(reflector as unknown as Reflector, memberRepo as never);
  });

  it('should answer 404 NOT_IN_GROUP for a non-member', async () => {
    memberRepo.findOne.mockResolvedValue(null);

    const error = await guard.canActivate(context()).catch((e: unknown) => e);

    expect(error).toBeInstanceOf(NotFoundException);
    expect((error as NotFoundException).getResponse()).toEqual(expect.objectContaining({ code: 'NOT_IN_GROUP' }));
    expect(memberRepo.findOne).toHaveBeenCalledWith({ where: { groupId: 'group-1', userId: 'user-1' } });
  });

  it('should answer 403 when a member calls an admin-only route', async () => {
    memberRepo.findOne.mockResolvedValue({ role: GroupRole.MEMBER });
    reflector.getAllAndOverride.mockReturnValue([GroupRole.ADMIN]);

    await expect(guard.canActivate(context())).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('should let an admin through and keep the membership on the request', async () => {
    const member = { role: GroupRole.ADMIN };
    memberRepo.findOne.mockResolvedValue(member);
    reflector.getAllAndOverride.mockReturnValue([GroupRole.ADMIN]);

    await expect(guard.canActivate(context())).resolves.toBe(true);
    expect(request.groupMember).toBe(member);
  });

  it('should let any member through when the route names no roles', async () => {
    memberRepo.findOne.mockResolvedValue({ role: GroupRole.VIEWER });

    await expect(guard.canActivate(context())).resolves.toBe(true);
  });
});
