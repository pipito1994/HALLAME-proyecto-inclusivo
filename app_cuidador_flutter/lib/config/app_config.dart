class AppConfig {
  /// URL Base del Backend. 
  /// CAMBIAR por tu URL de Cloudflare Tunnel.
  static const String backendBaseUrl = "https://hallame-proyecto-inclusivo.vercel.app";

  /// URL Base de la Web del Encontrador.
  /// CAMBIAR por tu URL de Cloudflare Tunnel.
  static const String webBaseUrl = "https://hallame-web.vercel.app"; 

  /// Genera la URL para el QR.
  static String getQrUrl(String qrUuid) {
    return "$webBaseUrl/?id=$qrUuid";
  }
}
