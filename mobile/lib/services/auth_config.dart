import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import '../core/server_config.dart';

/// Google Web Client ID — APK icine gomulu veya sunucudan.
class AuthConfig {
  AuthConfig._();

  static const _prefsKey = 'google_web_client_id';
  static String? _cachedGoogleId;

  static String get googleServerClientId {
    final cached = _cachedGoogleId?.trim();
    if (cached != null && cached.isNotEmpty) return cached;
    return AppConfig.googleServerClientId.trim();
  }

  static bool get hasGoogleClientId => googleServerClientId.isNotEmpty;

  static Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && hasGoogleClientId) return;

    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final saved = prefs.getString(_prefsKey)?.trim();
      if (saved != null && saved.isNotEmpty) {
        _cachedGoogleId = saved;
        return;
      }
      final baked = AppConfig.googleServerClientId.trim();
      if (baked.isNotEmpty) {
        _cachedGoogleId = baked;
        return;
      }
    }

    final client = http.Client();
    try {
      for (final base in ServerConfig.connectionCandidates()) {
        try {
          final res = await client
              .get(Uri.parse('$base/api/config/public'))
              .timeout(const Duration(seconds: 8));
          if (res.statusCode != 200) continue;
          final body = jsonDecode(res.body);
          if (body is! Map<String, dynamic>) continue;
          final id = body['googleWebClientId'] as String?;
          if (id != null && id.trim().isNotEmpty) {
            _cachedGoogleId = id.trim();
            await prefs.setString(_prefsKey, _cachedGoogleId!);
            return;
          }
        } catch (_) {}
      }
    } finally {
      client.close();
    }
  }
}
