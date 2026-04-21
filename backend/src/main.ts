require('dotenv').config();
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

let cachedApp: any;

async function bootstrap() {
  if (!cachedApp) {
    const app = await NestFactory.create(AppModule);
    
    app.enableCors({
      origin: '*',
    });
    
    await app.init();
    cachedApp = app.getHttpAdapter().getInstance();
  }
  return cachedApp;
}

// Exportar el handler para Vercel
export default async (req: any, res: any) => {
  const app = await bootstrap();
  return app(req, res);
};
