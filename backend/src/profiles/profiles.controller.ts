import { Controller, Post, Body, Patch, Param, Get, Req, NotFoundException, Headers, Ip, UseGuards, Query } from '@nestjs/common';
import { ProfilesService } from './profiles.service';
import { EncryptionService } from '../security/encryption.service';
import { FirebaseAuthGuard } from '../security/firebase-auth.guard';

@Controller('profiles')
export class ProfilesController {
  constructor(
    private readonly profilesService: ProfilesService,
    private readonly encryptionService: EncryptionService,
  ) {}

  // 1. ENDPOINTS PRIVADOS (Del Cuidador)
  
  @Get()
  @UseGuards(FirebaseAuthGuard)
  async listProfiles(@Req() req: any) {
    const userId = req.user.uid;
    const profiles = await this.profilesService.findAllByUser(userId);
    
    // Desencriptar datos para la lista de la App
    return profiles.map(profile => {
      const decryptedData = this.encryptionService.decrypt(profile.encryptedData);
      return {
        ...profile,
        ...decryptedData,
        // No enviamos el encryptedData original para ahorrar ancho de banda
        encryptedData: undefined, 
      };
    });
  }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  async createProfile(@Req() req: any, @Body() body: any) {
    const userId = req.user.uid;

    const dataToEncrypt = {
      fullName: body.fullName,
      diagnosis: body.diagnosis,
      emergencyContact: body.emergencyContact,
      emergencyContact2: body.emergencyContact2,
    };
    
    const encryptedData = this.encryptionService.encrypt(dataToEncrypt);

    const profile = await this.profilesService.create(userId, encryptedData);
    
    return { 
      message: 'Perfil creado exitosamente', 
      qrUuid: profile.qrUuid,
      profileId: profile.id
    };
  }

  @Patch(':id')
  @UseGuards(FirebaseAuthGuard)
  async updateProfile(@Param('id') id: string, @Req() req: any, @Body() body: any) {
    const userId = req.user.uid;
    
    const dataToEncrypt = {
      fullName: body.fullName,
      diagnosis: body.diagnosis,
      emergencyContact: body.emergencyContact,
      emergencyContact2: body.emergencyContact2,
    };
    
    const encryptedData = this.encryptionService.encrypt(dataToEncrypt);

    await this.profilesService.update(id, userId, {
      encryptedData,
      isActive: body.isActive !== undefined ? body.isActive : true,
    });

    return { success: true, message: 'Perfil actualizado de forma segura.' };
  }


  // 2. ENDPOINTS PÚBLICOS (Del Encontrador)

  @Get('scan/:qrUuid')
  async scanProfile(
    @Param('qrUuid') qrUuid: string,
    @Ip() ip: string,
    @Headers('user-agent') userAgent: string
  ) {
    const profile = await this.profilesService.findByQrUuid(qrUuid);

    // Evitar enumeración o exponer perfiles inactivos
    if (!profile || !profile.isActive) {
      throw new NotFoundException('Perfil no disponible o QR revocado.');
    }

    // Desencriptar datos en memoria para el frontend
    let decryptedData = this.encryptionService.decrypt(profile.encryptedData);

    // En Mock Mode, si falla la desencriptación y no tenemos datos reales, devolvemos el placeholder
    if (!decryptedData && process.env.MOCK_MODE === 'true') {
      decryptedData = {
        fullName: 'Abuelo Juan (Mock)',
        diagnosis: 'Alzheimer (Etapa 1)',
        emergencyContact: '+56 9 1234 5678',
        emergencyContact2: '+56 9 8765 4321',
      };
    }

    if (!decryptedData) {
      throw new NotFoundException('No se pudieron leer los datos del perfil.');
    }

    // Registrar evento de escaneo asíncronamente
    this.profilesService.logScan(profile.id, ip || '0.0.0.0', userAgent || 'Unknown');

    return {
      qrUuid: profile.qrUuid,
      photoUrl: profile.photoUrl,
      ...decryptedData,
    };
  }

  @Post('scan/:qrUuid/location')
  async shareLocation(
    @Param('qrUuid') qrUuid: string, 
    @Body() dto: { lat: number; lng: number }
  ) {
     const profile = await this.profilesService.findByQrUuid(qrUuid);
     if (!profile || !profile.isActive) throw new NotFoundException();

     // Aquí se emitirá por WebSockets a la App Móvil
     console.log(`[ALERTA GPS] Ubicación recibida para el QR ${qrUuid}:`, dto);
     
     return { success: true, message: 'Ubicación enviada al familiar.' };
  }
}
