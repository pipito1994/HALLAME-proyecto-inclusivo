import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FirebaseService } from '../firebase/firebase.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ProfilesService {
  private mockProfiles: any[] = [];

  constructor(
    private prisma: PrismaService,
    private firebaseService: FirebaseService,
  ) {}

  async create(userId: string, encryptedData: string, photoUrl?: string) {
    if (process.env.MOCK_MODE === 'true') {
      const newProfile = {
        id: uuidv4(),
        userId,
        qrUuid: uuidv4(),
        encryptedData,
        photoUrl: 'https://api.dicebear.com/9.x/avataaars/png?seed=Generico',
        isActive: true,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      this.mockProfiles.push(newProfile);
      return newProfile;
    }

    // Asegurar que el usuario existe en PostgreSQL (sincronizado desde Firebase UID)
    await this.prisma.user.upsert({
      where: { id: userId },
      update: {},
      create: {
        id: userId,
        email: 'user@hallame.com', 
        fullName: 'Usuario Hallame',
        phoneNumber: '000',
        passwordHash: 'firebase-auth', // Es autenticado por Firebase
      },
    });

    return this.prisma.profile.create({
      data: {
        userId: userId,
        encryptedData: encryptedData,
        photoUrl: photoUrl || 'https://api.dicebear.com/9.x/avataaars/png?seed=Generico',
        isActive: true,
      },
    });
  }

  async findAllByUser(userId: string) {
    if (process.env.MOCK_MODE === 'true') {
      return this.mockProfiles.filter(p => p.userId === userId);
    }
    return this.prisma.profile.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async update(id: string, userId: string, data: { encryptedData?: string; isActive?: boolean; photoUrl?: string }) {
    if (process.env.MOCK_MODE === 'true') {
      const index = this.mockProfiles.findIndex(p => p.id === id && p.userId === userId);
      if (index === -1) throw new NotFoundException('Perfil no encontrado o sin permisos');
      this.mockProfiles[index] = { ...this.mockProfiles[index], ...data, updatedAt: new Date().toISOString() };
      return this.mockProfiles[index];
    }

    try {
      return await this.prisma.profile.update({
        where: { id, userId },
        data: {
          ...data,
        },
      });
    } catch (error) {
      throw new NotFoundException('Perfil no encontrado o sin permisos para editar');
    }
  }

  async findByQrUuid(qrUuid: string) {
    if (process.env.MOCK_MODE === 'true') {
      const profile = this.mockProfiles.find(p => p.qrUuid === qrUuid);
      if (profile) return profile;

      return {
        id: uuidv4(),
        userId: 'mock-user-123',
        qrUuid: qrUuid,
        photoUrl: 'https://api.dicebear.com/9.x/avataaars/svg?seed=Generico',
        isActive: true,
        encryptedData: 'iv:auth:encryptedText',
      };
    }

    return this.prisma.profile.findUnique({
      where: { qrUuid },
    });
  }

  async logScan(profileId: string, ip: string, userAgent: string) {
    if (process.env.MOCK_MODE === 'true') {
      console.log(`[MOCK LOG] Escaneo registrado para perfil ${profileId} desde IP ${ip}`);
      return;
    }

    await this.prisma.emergencyLog.create({
      data: {
        profileId,
        ipHash: ip,
        userAgent,
      },
    }).catch(err => console.error('Error logueando escaneo en Prisma:', err));

    // ENVIAR NOTIFICACIÓN PUSH AL CUIDADOR
    try {
      const profile = await this.prisma.profile.findUnique({
        where: { id: profileId },
        include: { user: true }
      });

      if (profile?.user?.fcmToken) {
        await this.firebaseService.db.app.messaging().send({
          token: profile.user.fcmToken,
          notification: {
            title: '🚨 ¡Alerta de Escaneo!',
            body: `Alguien ha escaneado el perfil de ${profile.id}. Revisa la ubicación ahora.`,
          },
          data: {
            profileId: profile.id,
            type: 'SCAN_ALERT',
          },
        });
        console.log(`[PUSH] Notificación enviada al usuario ${profile.userId}`);
      }
    } catch (pushErr) {
      console.error('Error enviando notificación push:', pushErr);
    }
  }

  async updateFcmToken(userId: string, fcmToken: string) {
    if (process.env.MOCK_MODE === 'true') {
      console.log(`[MOCK FCM] Token actualizado para ${userId}: ${fcmToken}`);
      return { success: true };
    }
    return this.prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
    });
  }

  async remove(id: string, userId: string) {
    if (process.env.MOCK_MODE === 'true') {
      const index = this.mockProfiles.findIndex(p => p.id === id && p.userId === userId);
      if (index === -1) throw new NotFoundException('Perfil no encontrado');
      this.mockProfiles.splice(index, 1);
      return { success: true };
    }

    try {
      await this.prisma.profile.delete({
        where: { id, userId },
      });
      return { success: true };
    } catch (error) {
      throw new NotFoundException('Perfil no encontrado o sin permisos para eliminar');
    }
  }
}
