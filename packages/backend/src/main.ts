import './config/force-ipv4'; // MUST be first import
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { AppModule } from './app.module';
import { initializeFirebase } from './config/firebase.config';
import { configureStaticPages } from './config/static-pages';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  initializeFirebase();

  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.enableCors({
    origin: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: 'Content-Type,Accept,Authorization',
    credentials: true,
  });

  app.setGlobalPrefix('api', {
    exclude: ['delete-account'],
  });

  configureStaticPages(app);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`Expenzo backend running on port ${port}`);
}
bootstrap();
