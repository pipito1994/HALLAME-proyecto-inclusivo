import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<String?> initialize() async {
    // Solicitar permisos
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        await syncToken(token);
      }

      // Escuchar cuando el token cambie
      _messaging.onTokenRefresh.listen((newToken) {
        syncToken(newToken);
      });

      return token;
    }
    return null;
  }

  static Future<void> syncToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final idToken = await user.getIdToken();
      final url = Uri.parse('${AppConfig.backendBaseUrl}/profiles/fcm-token');
      await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );
    } catch (e) {
      print('Error sincronizando FCM token: $e');
    }
  }
}
