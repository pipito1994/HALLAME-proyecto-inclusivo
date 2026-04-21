import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    const now = new Date().toLocaleString('es-CL', { timeZone: 'America/Santiago' });
    return `Servidor Hallame ONLINE - Última actualización: ${now}`;
  }
}
