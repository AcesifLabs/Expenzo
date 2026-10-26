import { UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { DELETED_USER_MESSAGE, JwtStrategy } from './jwt.strategy';

describe('JwtStrategy', () => {
  const users = { findOne: jest.fn() };
  const strategy = new JwtStrategy({ get: () => 'secret' } as unknown as ConfigService, users as unknown as Repository<User>);
  const payload = { sub: 'user-1', firebaseUid: 'uid-1', iat: 0, exp: 0 };

  it('should accept a JWT whose user exists', async () => {
    users.findOne.mockResolvedValue({ id: 'user-1', firebaseUid: 'uid-1' });

    await expect(strategy.validate(payload)).resolves.toEqual({ sub: 'user-1', firebaseUid: 'uid-1' });
  });

  
  
  it('should reject a valid JWT whose user was deleted', async () => {
    users.findOne.mockResolvedValue(null);

    const validation = strategy.validate(payload);

    await expect(validation).rejects.toBeInstanceOf(UnauthorizedException);
    await expect(validation).rejects.toThrow(DELETED_USER_MESSAGE);
  });
});
