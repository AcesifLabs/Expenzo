import { NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AuthService } from './auth.service';
import { User } from './entities/user.entity';
import { DataSource } from 'typeorm';
import { GroupsService } from '../groups/groups.service';
import { firebaseAuth } from '../config/firebase.config';

jest.mock('../config/firebase.config', () => ({ firebaseAuth: jest.fn() }));

describe('AuthService', () => {
  let service: AuthService;
  let env: Record<string, string | undefined>;
  const verifyIdToken = jest.fn();
  const userRepo = {
    findOne: jest.fn(),
    create: jest.fn((u: Partial<User>) => u),
    save: jest.fn((u: Partial<User>) => Promise.resolve(u)),
    remove: jest.fn(),
  };
  const manager = { findOne: jest.fn(), remove: jest.fn() };
  const dataSource = { transaction: jest.fn((work: (m: typeof manager) => unknown) => work(manager)) };
  const groupsService = { applyLeaveRules: jest.fn() };
  const devToken = 'dev-' + Buffer.from(JSON.stringify({ uid: 'victim-uid' })).toString('base64');

  beforeEach(async () => {
    env = {};
    jest.clearAllMocks();
    verifyIdToken.mockRejectedValue(new Error('Decoding Firebase ID token failed'));
    (firebaseAuth as jest.Mock).mockReturnValue({ verifyIdToken });
    userRepo.findOne.mockResolvedValue(null);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: userRepo },
        { provide: JwtService, useValue: { sign: () => 'jwt' } },
        { provide: ConfigService, useValue: { get: (key: string) => env[key] } },
        { provide: DataSource, useValue: dataSource },
        { provide: GroupsService, useValue: groupsService },
      ],
    }).compile();

    service = module.get(AuthService);
  });

  describe('loginWithFirebaseToken with a dev- token', () => {
    it('should verify it as a Firebase token when dev tokens are not switched on', async () => {
      await expect(service.loginWithFirebaseToken(devToken)).rejects.toBeInstanceOf(UnauthorizedException);

      expect(verifyIdToken).toHaveBeenCalledWith(devToken);
      expect(userRepo.save).not.toHaveBeenCalled();
    });

    it('should refuse it in production even when switched on', async () => {
      env = { ALLOW_DEV_TOKENS: 'true', NODE_ENV: 'production' };

      await expect(service.loginWithFirebaseToken(devToken)).rejects.toBeInstanceOf(UnauthorizedException);

      expect(userRepo.save).not.toHaveBeenCalled();
    });

    it('should sign in as the token uid when switched on outside production', async () => {
      env = { ALLOW_DEV_TOKENS: 'true', NODE_ENV: 'development' };

      const result = await service.loginWithFirebaseToken(devToken);

      expect(result.accessToken).toBe('jwt');
      expect(result.user.firebaseUid).toBe('victim-uid');
      expect(verifyIdToken).not.toHaveBeenCalled();
    });
  });

  describe('deleteAccount', () => {
    const user = { id: 'user-1' } as User;

    beforeEach(() => {
      manager.findOne.mockResolvedValue(null);
      groupsService.applyLeaveRules.mockResolvedValue(undefined);
    });

    it('should remove the user row in a transaction', async () => {
      userRepo.findOne.mockResolvedValue(user);

      await expect(service.deleteAccount('user-1')).resolves.toEqual({ deleted: true, userId: 'user-1' });

      expect(dataSource.transaction).toHaveBeenCalledTimes(1);
      expect(manager.remove).toHaveBeenCalledWith(user);
      expect(groupsService.applyLeaveRules).not.toHaveBeenCalled();
    });

    it('should leave the family group before removing the user', async () => {
      userRepo.findOne.mockResolvedValue(user);
      manager.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1' });

      await service.deleteAccount('user-1');

      expect(groupsService.applyLeaveRules).toHaveBeenCalledWith(manager, 'group-1', 'user-1');
      expect(groupsService.applyLeaveRules.mock.invocationCallOrder[0]).toBeLessThan(
        manager.remove.mock.invocationCallOrder[0],
      );
    });

    it('should keep the user when the leave rules fail', async () => {
      userRepo.findOne.mockResolvedValue(user);
      manager.findOne.mockResolvedValue({ groupId: 'group-1', userId: 'user-1' });
      groupsService.applyLeaveRules.mockRejectedValue(new Error('db down'));

      await expect(service.deleteAccount('user-1')).rejects.toThrow('db down');

      expect(manager.remove).not.toHaveBeenCalled();
    });

    it('should throw NotFound when the user is already gone', async () => {
      await expect(service.deleteAccount('user-1')).rejects.toBeInstanceOf(NotFoundException);

      expect(manager.remove).not.toHaveBeenCalled();
    });
  });
});
