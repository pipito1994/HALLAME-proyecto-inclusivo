import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private firestore: admin.firestore.Firestore;
  private readonly logger = new Logger(FirebaseService.name);

  onModuleInit() {
    if (process.env.MOCK_MODE === 'true') {
      this.logger.warn('⚠️ MOCK MODE ACTIVADO: No se conectará a Firebase Real.');
      return;
    }

    if (!admin.apps.length) {
      // En producción (Render), usamos la variable de entorno FIREBASE_SERVICE_ACCOUNT
      // En desarrollo local, usamos el archivo firebase-key.json
      if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        this.logger.log('Iniciando Firebase desde variable de entorno (producción)');
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      } else {
        this.logger.log('Iniciando Firebase desde archivo local (desarrollo)');
        const serviceAccountPath = path.resolve(__dirname, '../../firebase-key.json');
        if (!fs.existsSync(serviceAccountPath)) {
          throw new Error('firebase-key.json no encontrado. Configura FIREBASE_SERVICE_ACCOUNT en producción.');
        }
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccountPath),
        });
      }
    }
    this.firestore = admin.firestore();
  }

  get db() {
    return this.firestore;
  }

  get messaging() {
    return admin.messaging();
  }
}
