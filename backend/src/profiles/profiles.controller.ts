import { Controller, Post, Body, Patch, Param, Get, Req, NotFoundException, Headers, Ip } from '@nestjs/common';
import { ProfilesService } from './profiles.service';
import { EncryptionService } from '../security/encryption.service';

@Controller('profiles')
export class ProfilesController {
  constructor(
    private readonly profilesService: ProfilesService,
    private readonly encryptionService: EncryptionService,
  ) {}

  // 1. ENDPOINTS PRIVADOS (Del Cuidador)
  // Nota: En el futuro esto requerirá validación de JWT (@UseGuards(JwtAuthGuard))

  @Post()
  async createProfile(@Body() body: any) {
    // Simulamos un userId por ahora
    const mockUserId = '11111111-1111-1111-1111-111111111111'; 

    // Encriptamos los datos sensibles
    const dataToEncrypt = {
      fullName: body.fullName,
      diagnosis: body.diagnosis,
      emergencyContact: body.emergencyContact,
      emergencyContact2: body.emergencyContact2,
    };
    
    const encryptedData = this.encryptionService.encrypt(dataToEncrypt);

    const profile = await this.profilesService.create(mockUserId, encryptedData);
    
    return { 
      message: 'Perfil creado exitosamente', 
      qrUuid: profile.qrUuid,
      profileId: profile.id
    };
  }

  @Patch(':id')
  async updateProfile(@Param('id') id: string, @Body() body: any) {
    // Validar propiedad del perfil (pendiente de auth)
    
    const dataToEncrypt = {
      fullName: body.fullName,
      diagnosis: body.diagnosis,
      emergencyContact: body.emergencyContact,
      emergencyContact2: body.emergencyContact2,
    };
    
    const encryptedData = this.encryptionService.encrypt(dataToEncrypt);

    await this.profilesService.update(id, {
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
