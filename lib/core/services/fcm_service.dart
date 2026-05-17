import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_client.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient;

  FcmService(this._apiClient);

  Future<void> initialize() async {
    // İzin iste
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Token al ve backend'e gönder
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    // Token yenilenince tekrar gönder
    _messaging.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });

    // Ön planda bildirim göster
    FirebaseMessaging.onMessage.listen((message) {
      // Bildirim zaten sistem tarafından gösterilir
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiClient.post('/fcm-token', data: {
        'fcm_token': token,
        'device_type': 'android',
      });
    } catch (_) {}
  }
}