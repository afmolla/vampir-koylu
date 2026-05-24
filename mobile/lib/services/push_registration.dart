import 'package:shared_preferences/shared_preferences.dart';

import 'engagement_service.dart';
import 'session_store.dart';

/// FCM yoksa bile sunucuya cihaz token kaydi (dev / bildirim altyapisi).
class PushRegistration {
  static const _tokenKey = 'device_push_token';

  static Future<void> registerAfterLogin() async {
    final userId = await SessionStore().getUserId();
    final authToken = await SessionStore().getToken();
    if (userId == null || authToken == null || authToken.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      token = 'android:$userId';
      await prefs.setString(_tokenKey, token);
    }

    try {
      await EngagementService().registerPushToken(token);
    } catch (_) {}
  }
}
