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
  static bool _facebookEnabled = false;
  static List<Map<String, dynamic>> _iceServers = _defaultIce;
  static bool _tournamentAllowBots = false;

  static List<Map<String, dynamic>> _defaultIce = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ];

  static List<Map<String, dynamic>> get iceServers => _iceServers;
  static bool get tournamentAllowBots => _tournamentAllowBots;

  static bool get facebookSignInEnabled => _facebookEnabled;

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
          final raw = jsonDecode(res.body);
          if (raw is! Map<String, dynamic>) continue;
          _facebookEnabled = raw['facebookSignInEnabled'] == true;
          _tournamentAllowBots = raw['tournamentAllowBots'] == true;
          final ice = raw['iceServers'];
          if (ice is List && ice.isNotEmpty) {
            _iceServers = ice
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          final id = raw['googleWebClientId'] as String?;
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
