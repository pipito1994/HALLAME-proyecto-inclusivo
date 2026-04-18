import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { FirebaseModule } from './firebase/firebase.module';
import { SecurityModule } from './security/security.module';
import { ProfilesModule } from './profiles/profiles.module';

@Module({
  imports: [
    FirebaseModule,
    SecurityModule,
    ProfilesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
