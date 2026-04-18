import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';

@Injectable()
export class EncryptionService {
  private readonly algorithm = 'aes-256-gcm';
  // Obtenemos la clave de las variables de entorno o usamos un fallback seguro (solo para dev)
  private readonly key = process.env.ENCRYPTION_KEY || 'esta_es_una_clave_secreta_de_32_caracteres_!';

  encrypt(data: any): string {
    const text = JSON.stringify(data);
    const iv = crypto.randomBytes(16);
    const keyBuffer = crypto.createHash('sha256').update(String(this.key)).digest();
    const cipher = crypto.createCipheriv(this.algorithm, keyBuffer, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag().toString('hex');
    
    // Formato: iv:authTag:encryptedText
    return `${iv.toString('hex')}:${authTag}:${encrypted}`;
  }

  decrypt(encryptedData: string): any {
    try {
      const parts = encryptedData.split(':');
      if (parts.length !== 3) throw new Error('Formato de encriptación inválido');

      const iv = Buffer.from(parts[0], 'hex');
      const authTag = Buffer.from(parts[1], 'hex');
      const encryptedText = parts[2];

      const keyBuffer = crypto.createHash('sha256').update(String(this.key)).digest();
      const decipher = crypto.createDecipheriv(this.algorithm, keyBuffer, iv);
      decipher.setAuthTag(authTag);
      
      let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
      decrypted += decipher.final('utf8');
      
      return JSON.parse(decrypted);
    } catch (error) {
      console.error('Error al desencriptar datos:', error);
      return null;
    }
  }
}
