class AppConfig {
  /// URL Base del Backend. 
  /// CAMBIAR por tu URL de Cloudflare Tunnel.
  static const String backendBaseUrl = "https://sequence-thrown-coat-stem.trycloudflare.com";

  /// URL Base de la Web del Encontrador.
  /// CAMBIAR por tu URL de Cloudflare Tunnel.
  static const String webBaseUrl = "https://pride-voltage-allergy-hearings.trycloudflare.com"; 

  /// Genera la URL para el QR.
  static String getQrUrl(String qrUuid) {
    return "$webBaseUrl/?id=$qrUuid";
  }
}
