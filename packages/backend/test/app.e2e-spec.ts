import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request = require('supertest');
import { AppController } from '../src/app.controller';

jest.setTimeout(30000);

describe('AppController (e2e)', () => {
  let app: INestApplication | undefined;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterEach(async () => {
    await app?.close();
  });

  it('/health (GET)', async () => {
    if (!app) {
      throw new Error('Nest application did not initialize');
    }

    const response = await request(app.getHttpAdapter().getInstance()).get('/health').expect(200);

    expect(response.body).toEqual({
      status: 'ok',
      timestamp: expect.any(String),
    });
  });
});
