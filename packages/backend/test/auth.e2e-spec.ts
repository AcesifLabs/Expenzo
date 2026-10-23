import { ExecutionContext, INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request = require('supertest');
import { AuthController } from '../src/auth/auth.controller';
import { AuthService } from '../src/auth/auth.service';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';

jest.setTimeout(30000);

describe('AuthController (e2e)', () => {
  let app: INestApplication;
  const authService = { deleteAccount: jest.fn() };
  let signedIn: boolean;

  beforeEach(async () => {
    signedIn = true;
    authService.deleteAccount.mockReset().mockResolvedValue({ deleted: true, userId: 'user-1' });
    const moduleFixture = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: authService }],
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
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('DELETE /auth/account should delete the signed-in user', async () => {
    const response = await request(app.getHttpServer()).delete('/auth/account').expect(200);

    expect(response.body).toEqual({ deleted: true, userId: 'user-1' });
    expect(authService.deleteAccount).toHaveBeenCalledWith('user-1');
  });

  it('DELETE /auth/account should refuse a request without a signed-in user', async () => {
    signedIn = false;

    await request(app.getHttpServer()).delete('/auth/account').expect(403);

    expect(authService.deleteAccount).not.toHaveBeenCalled();
  });
});
