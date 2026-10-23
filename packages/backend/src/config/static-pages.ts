import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

/** Serves public/ at the site root; `/privacy` resolves to privacy.html. */
export function configureStaticPages(app: NestExpressApplication): void {
  app.useStaticAssets(join(__dirname, '..', '..', 'public'), { extensions: ['html'] });
}
