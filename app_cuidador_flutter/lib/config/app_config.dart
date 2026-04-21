class AppConfig {
  /// URL Base del Backend. 
  /// CAMBIAR por tu URL de Cloudflare Tunnel.
  static const String backendBaseUrl = "http://192.168.1.201:3000";

  /// URL Base de la Web del Encontrador.
  /// CAMBIAR por tu URL de Cloudflare Tunnel.
  static const String webBaseUrl = "https://hallame-encontrador-final.vercel.app"; 

  /// Genera la URL para el QR.
  static String getQrUrl(String qrUuid) {
    return "$webBaseUrl/?id=$qrUuid";
  }
}
