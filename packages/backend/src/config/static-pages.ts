import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';


export function configureStaticPages(app: NestExpressApplication): void {
  app.useStaticAssets(join(__dirname, '..', '..', 'public'), { extensions: ['html'] });
}
