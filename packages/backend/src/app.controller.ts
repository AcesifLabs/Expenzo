import { Controller, Get } from '@nestjs/common';
import { Public } from './common/decorators/public.decorator';
import { HealthCheckResponse } from './app.types';

@Controller('health')
export class AppController {
  @Public()
  @Get()
  checkHealth(): HealthCheckResponse {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }
}