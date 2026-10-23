import { NestExpressApplication } from '@nestjs/platform-express';
import { Test, TestingModule } from '@nestjs/testing';
import request = require('supertest');
import { AppController } from '../src/app.controller';
import { configureStaticPages } from '../src/config/static-pages';

jest.setTimeout(30000);

describe('Static pages (e2e)', () => {
  let app: NestExpressApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    app = moduleFixture.createNestApplication<NestExpressApplication>();
    app.setGlobalPrefix('api', { exclude: ['delete-account'] });
    configureStaticPages(app);
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  const get = (path: string) => request(app.getHttpAdapter().getInstance()).get(path);

  it('GET /privacy serves the privacy policy page', async () => {
    const response = await get('/privacy').expect(200);

    expect(response.headers['content-type']).toContain('text/html');
    expect(response.text).toContain('Privacy Policy');
    expect(response.text).toContain('asifzubayerpalak@gmail.com');
    expect(response.text).toContain('Groq');
    expect(response.text).not.toContain('Firestore');
  });

  it('GET /terms serves the terms page', async () => {
    const response = await get('/terms').expect(200);

    expect(response.headers['content-type']).toContain('text/html');
    expect(response.text).toContain('Terms of Service');
  });

  it('GET /privacy.html still works with the full file name', async () => {
    await get('/privacy.html').expect(200);
  });

  it('GET /delete-account.html still works', async () => {
    await get('/delete-account.html').expect(200);
  });

  it('GET /delete-account also serves the deletion page', async () => {
    const response = await get('/delete-account').expect(200);

    expect(response.headers['content-type']).toContain('text/html');
    expect(response.text).toContain('asifzubayerpalak@gmail.com');
  });

  it('GET /api/privacy is not a page: the pages live at the root', async () => {
    await get('/api/privacy').expect(404);
  });
});
