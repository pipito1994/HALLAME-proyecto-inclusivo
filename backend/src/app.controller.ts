import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    const now = new Date().toLocaleString('es-CL', { timeZone: 'America/Santiago' });
    return `<html><body style="background:#00BFA5;color:white;display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;">
            <div style="text-align:center;">
              <h1>🚀 SISTEMA HALLAME ACTIVO</h1>
              <p>Última actualización: ${now}</p>
            </div>
            </body></html>`;
  }
}
