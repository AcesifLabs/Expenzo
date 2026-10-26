import { ExecutionContext, ForbiddenException, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import request = require('supertest');
import { GroupsController } from '../src/groups/groups.controller';
import { GroupsService } from '../src/groups/groups.service';
import { GroupSummaryService } from '../src/groups/group-summary.service';
import { GroupRoleGuard } from '../src/groups/guards/group-role.guard';
import { GroupMember } from '../src/groups/entities/group-member.entity';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';
import { GROUP_NAME_MAX_LENGTH, GroupRole } from '../src/groups/groups.constants';
import { groupErrors } from '../src/groups/group-errors';

jest.setTimeout(30000);

const MY_GROUP = {
  group: { id: 'group-1', name: 'Family', currencyCode: 'BDT', monthlyBudget: null, createdAt: '2026-01-01T00:00:00.000Z' },
  me: { userId: 'user-1', role: GroupRole.ADMIN },
  members: [],
  sharedBudgets: [],
  invite: null,
};

describe('GroupsController (e2e)', () => {
  let app: INestApplication;
  let signedIn: boolean;
  const groupsService = {
    create: jest.fn(),
    getMine: jest.fn(),
    join: jest.fn(),
    createInvite: jest.fn(),
    updateRole: jest.fn(),
    removeMember: jest.fn(),
    deleteGroup: jest.fn(),
  };
  const summaryService = { getSummary: jest.fn() };
  
  const memberRepo = { findOne: jest.fn() };

  beforeEach(async () => {
    signedIn = true;
    for (const fn of Object.values(groupsService)) fn.mockReset().mockResolvedValue(MY_GROUP);
    summaryService.getSummary.mockReset().mockResolvedValue({ groupId: 'group-1' });
    memberRepo.findOne.mockReset().mockResolvedValue({ groupId: 'group-1', userId: 'user-1', role: GroupRole.ADMIN });
    const moduleFixture = await Test.createTestingModule({
      controllers: [GroupsController],
      providers: [
        { provide: GroupsService, useValue: groupsService },
        { provide: GroupSummaryService, useValue: summaryService },
        GroupRoleGuard,
        { provide: getRepositoryToken(GroupMember), useValue: memberRepo },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (context: ExecutionContext) => {
          if (!signedIn) return false;
          context.switchToHttp().getRequest().user = { sub: 'user-1' };
          return true;
        },
      })
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  describe('POST /groups', () => {
    const body = { name: '  Rahman Family  ', currencyCode: 'BDT', monthlyBudget: 50000 };

    it('should create the group for the signed-in user with a trimmed name', async () => {
      const response = await request(app.getHttpServer()).post('/groups').send(body).expect(201);

      expect(response.body).toEqual(MY_GROUP);
      expect(groupsService.create).toHaveBeenCalledWith('user-1', { ...body, name: 'Rahman Family' });
    });

    it('should answer 409 with the code when the caller is already in a group', async () => {
      groupsService.create.mockRejectedValue(groupErrors.alreadyInGroup());

      const response = await request(app.getHttpServer()).post('/groups').send(body).expect(409);

      expect(response.body.code).toBe('ALREADY_IN_GROUP');
    });

    it.each([
      ['an empty name', { ...body, name: '   ' }],
      ['a name over the limit', { ...body, name: 'x'.repeat(GROUP_NAME_MAX_LENGTH + 1) }],
      ['a lowercase currency', { ...body, currencyCode: 'usd' }],
      ['a negative budget', { ...body, monthlyBudget: -5 }],
      ['a budget too large for decimal(12,2)', { ...body, monthlyBudget: 10_000_000_000 }],
      ['a budget with three decimals', { ...body, monthlyBudget: 1.234 }],
      ['extra fields', { ...body, role: 'admin' }],
      ['no name', { currencyCode: 'BDT' }],
    ])('should reject %s', async (_label, invalid) => {
      await request(app.getHttpServer()).post('/groups').send(invalid).expect(400);

      expect(groupsService.create).not.toHaveBeenCalled();
    });

    it('should refuse a request without a signed-in user', async () => {
      signedIn = false;

      await request(app.getHttpServer()).post('/groups').send(body).expect(403);
    });
  });

  describe('GET /groups/me', () => {
    it('should return the caller group', async () => {
      const response = await request(app.getHttpServer()).get('/groups/me').expect(200);

      expect(response.body).toEqual(MY_GROUP);
      expect(groupsService.getMine).toHaveBeenCalledWith('user-1');
    });

    it('should refuse a request without a signed-in user', async () => {
      signedIn = false;

      await request(app.getHttpServer()).get('/groups/me').expect(403);
    });
  });

  describe('POST /groups/:id/invites', () => {
    it('should make a code for an admin', async () => {
      groupsService.createInvite.mockResolvedValue({ code: 'RF4XK2', expiresAt: '2026-03-03T10:00:00.000Z' });

      const response = await request(app.getHttpServer()).post('/groups/group-1/invites').expect(201);

      expect(response.body.code).toBe('RF4XK2');
      expect(groupsService.createInvite).toHaveBeenCalledWith('group-1', 'user-1');
    });

    it.each([GroupRole.MEMBER, GroupRole.VIEWER])('should refuse a %s with 403', async (role) => {
      memberRepo.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', role });

      await request(app.getHttpServer()).post('/groups/group-1/invites').expect(403);
      expect(groupsService.createInvite).not.toHaveBeenCalled();
    });

    it('should answer 404 NOT_IN_GROUP for a non-member', async () => {
      memberRepo.findOne.mockResolvedValue(null);

      const response = await request(app.getHttpServer()).post('/groups/group-2/invites').expect(404);

      expect(response.body.code).toBe('NOT_IN_GROUP');
    });

    it('should refuse a request without a signed-in user', async () => {
      signedIn = false;

      await request(app.getHttpServer()).post('/groups/group-1/invites').expect(403);
    });
  });

  describe('POST /groups/join', () => {
    it('should accept a lowercase code with spaces', async () => {
      await request(app.getHttpServer()).post('/groups/join').send({ code: ' rf4 xk2 ', currencyCode: 'BDT' }).expect(200);

      expect(groupsService.join).toHaveBeenCalledWith('user-1', { code: 'RF4XK2', currencyCode: 'BDT' });
    });

    it.each([
      ['a short code', { code: 'RF4XK', currencyCode: 'BDT' }],
      ['a long code', { code: 'RF4XK22', currencyCode: 'BDT' }],
      ['an I', { code: 'RF4XKI', currencyCode: 'BDT' }],
      ['an O', { code: 'RF4XKO', currencyCode: 'BDT' }],
      ['a 0', { code: 'RF4XK0', currencyCode: 'BDT' }],
      ['a 1', { code: 'RF4XK1', currencyCode: 'BDT' }],
      ['a lowercase currency', { code: 'RF4XK2', currencyCode: 'bdt' }],
      ['no code', { currencyCode: 'BDT' }],
      ['no currency', { code: 'RF4XK2' }],
    ])('should reject %s', async (_label, body) => {
      await request(app.getHttpServer()).post('/groups/join').send(body).expect(400);

      expect(groupsService.join).not.toHaveBeenCalled();
    });

    it.each([
      [groupErrors.inviteNotFound(), 404, 'INVITE_NOT_FOUND'],
      [groupErrors.inviteExpired(), 410, 'INVITE_EXPIRED'],
      [groupErrors.currencyMismatch('USD'), 409, 'CURRENCY_MISMATCH'],
      [groupErrors.groupFull(), 409, 'GROUP_FULL'],
      [groupErrors.alreadyInGroup(), 409, 'ALREADY_IN_GROUP'],
    ])('should pass the error code through (%#)', async (error, status, code) => {
      groupsService.join.mockRejectedValue(error);

      const response = await request(app.getHttpServer())
        .post('/groups/join')
        .send({ code: 'RF4XK2', currencyCode: 'BDT' })
        .expect(status);

      expect(response.body.code).toBe(code);
    });

    it('should refuse a request without a signed-in user', async () => {
      signedIn = false;

      await request(app.getHttpServer()).post('/groups/join').send({ code: 'RF4XK2', currencyCode: 'BDT' }).expect(403);
    });
  });

  const asRole = (role: GroupRole) =>
    memberRepo.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1', role });

  describe('PATCH /groups/:id/members/:userId', () => {
    it('should change the role for an admin', async () => {
      await request(app.getHttpServer()).patch('/groups/group-1/members/user-2').send({ role: 'viewer' }).expect(200);

      expect(groupsService.updateRole).toHaveBeenCalledWith('group-1', 'user-2', { role: GroupRole.VIEWER }, 'user-1');
    });

    it('should reject an unknown role', async () => {
      await request(app.getHttpServer()).patch('/groups/group-1/members/user-2').send({ role: 'owner' }).expect(400);
    });

    it('should refuse a member', async () => {
      asRole(GroupRole.MEMBER);

      await request(app.getHttpServer()).patch('/groups/group-1/members/user-2').send({ role: 'viewer' }).expect(403);
    });

    it('should pass LAST_ADMIN through as 409', async () => {
      groupsService.updateRole.mockRejectedValue(groupErrors.lastAdmin());

      const response = await request(app.getHttpServer())
        .patch('/groups/group-1/members/user-1')
        .send({ role: 'member' })
        .expect(409);

      expect(response.body.code).toBe('LAST_ADMIN');
    });
  });

  describe('DELETE /groups/:id/members/:userId', () => {
    it('should let a member leave with 204 and pass the membership on', async () => {
      asRole(GroupRole.MEMBER);
      groupsService.removeMember.mockResolvedValue(undefined);

      await request(app.getHttpServer()).delete('/groups/group-1/members/user-1').expect(204);

      expect(groupsService.removeMember).toHaveBeenCalledWith(
        'group-1',
        'user-1',
        expect.objectContaining({ userId: 'user-1', role: GroupRole.MEMBER }),
      );
    });

    it('should pass a 403 from the service through', async () => {
      asRole(GroupRole.MEMBER);
      groupsService.removeMember.mockRejectedValue(new ForbiddenException());

      await request(app.getHttpServer()).delete('/groups/group-1/members/user-2').expect(403);
    });
  });

  describe('DELETE /groups/:id', () => {
    it('should delete the group for an admin', async () => {
      groupsService.deleteGroup.mockResolvedValue(undefined);

      await request(app.getHttpServer()).delete('/groups/group-1').expect(204);

      expect(groupsService.deleteGroup).toHaveBeenCalledWith('group-1');
    });

    it('should refuse a member', async () => {
      asRole(GroupRole.MEMBER);

      await request(app.getHttpServer()).delete('/groups/group-1').expect(403);
      expect(groupsService.deleteGroup).not.toHaveBeenCalled();
    });

    it('should answer 404 for a non-member', async () => {
      memberRepo.findOne.mockResolvedValue(null);

      await request(app.getHttpServer()).delete('/groups/group-1').expect(404);
    });
  });

  it.each([
    ['patch', '/groups/group-1/members/user-2'],
    ['delete', '/groups/group-1/members/user-2'],
    ['delete', '/groups/group-1'],
  ] as const)('%s %s should refuse a request without a signed-in user', async (verb, path) => {
    signedIn = false;

    await request(app.getHttpServer())[verb](path).send({ role: 'viewer' }).expect(403);
  });

  describe('GET /groups/:id/summary', () => {
    it('should answer a viewer and pass the offset as a number', async () => {
      asRole(GroupRole.VIEWER);

      await request(app.getHttpServer()).get('/groups/group-1/summary').query({ utcOffsetMinutes: '360' }).expect(200);

      expect(summaryService.getSummary).toHaveBeenCalledWith('group-1', 360);
    });

    it('should default the offset to 0', async () => {
      await request(app.getHttpServer()).get('/groups/group-1/summary').expect(200);

      expect(summaryService.getSummary).toHaveBeenCalledWith('group-1', 0);
    });

    it('should answer 404 for a non-member', async () => {
      memberRepo.findOne.mockResolvedValue(null);

      await request(app.getHttpServer()).get('/groups/group-1/summary').expect(404);
    });

    it.each(['900', '-900', '1.5', 'abc'])('should reject utcOffsetMinutes=%s', async (offset) => {
      await request(app.getHttpServer()).get('/groups/group-1/summary').query({ utcOffsetMinutes: offset }).expect(400);
    });

    it('should refuse a request without a signed-in user', async () => {
      signedIn = false;

      await request(app.getHttpServer()).get('/groups/group-1/summary').expect(403);
    });
  });
});
