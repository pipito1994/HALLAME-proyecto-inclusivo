require('dotenv').config();
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Habilitar CORS para permitir que la Web App (Next.js) haga peticiones
  app.enableCors({
    origin: '*', // En producción, cambiar por el dominio real de la Web App
  });
  
  await app.listen(process.env.PORT ?? 3002);
  console.log(`Application is running on: http://localhost:3002`);
}
bootstrap();
