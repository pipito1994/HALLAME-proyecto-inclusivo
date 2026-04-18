require('dotenv').config();
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: '*',
  });
  
  const port = process.env.PORT ?? 3002;
  await app.listen(port);
  return app;
}

// Para despliegue tradicional
if (process.env.NODE_ENV !== 'production') {
  bootstrap();
}

// Para Vercel (opcional: algunos prefieren exportar el handler)
export default bootstrap;
