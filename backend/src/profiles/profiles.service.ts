import { Injectable, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ProfilesService {
  private mockProfiles: any[] = [];

  constructor(private firebaseService: FirebaseService) {}

  async create(userId: string, encryptedData: string) {
    const profileId = uuidv4();
    const qrUuid = uuidv4();

    const newProfile = {
      id: profileId,
      userId,
      qrUuid,
      encryptedData,
      photoUrl: 'https://api.dicebear.com/9.x/avataaars/svg?seed=Generico',
      isActive: true,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    if (process.env.MOCK_MODE === 'true') {
      this.mockProfiles.push(newProfile);
      return newProfile;
    }

    const db = this.firebaseService.db;
    // Ensure mock user exists in Firestore
    await db.collection('users').doc(userId).set({
      email: 'mock@user.com',
      fullName: 'Mock User',
      phoneNumber: '000',
    }, { merge: true });

    await db.collection('profiles').doc(profileId).set(newProfile);
    
    return newProfile;
  }

  async update(id: string, data: { encryptedData?: string; isActive?: boolean }) {
    const db = this.firebaseService.db;
    const profileRef = db.collection('profiles').doc(id);
    const doc = await profileRef.get();
    
    if (!doc.exists) throw new NotFoundException('Perfil no encontrado');

    await profileRef.update({
      ...data,
      updatedAt: new Date().toISOString(),
    });

    return { id, ...doc.data(), ...data };
  }

  async findByQrUuid(qrUuid: string) {
    if (process.env.MOCK_MODE === 'true') {
      const profile = this.mockProfiles.find(p => p.qrUuid === qrUuid);
      if (profile) return profile;

      // Fallback para el "Abuelo Juan" si no existe el UUID (para que siempre funcione algo)
      return {
        id: 'mock-id-123',
        userId: 'mock-user-123',
        qrUuid: qrUuid,
        photoUrl: 'https://api.dicebear.com/9.x/avataaars/svg?seed=Generico',
        isActive: true,
        encryptedData: 'iv:auth:encryptedText',
      };
    }
    const db = this.firebaseService.db;
    const snapshot = await db.collection('profiles').where('qrUuid', '==', qrUuid).limit(1).get();
    
    if (snapshot.empty) return null;
    
    return snapshot.docs[0].data();
  }

  async logScan(profileId: string, ip: string, userAgent: string) {
    if (process.env.MOCK_MODE === 'true') {
      console.log(`[MOCK LOG] Escaneo registrado para perfil ${profileId} desde IP ${ip}`);
      return;
    }
    const db = this.firebaseService.db;
    
    db.collection('emergencyLogs').add({
      profileId,
      ipHash: ip,
      userAgent,
      scannedAt: new Date().toISOString(),
    }).catch(err => console.error('Error logueando escaneo en Firebase:', err));
  }
}
