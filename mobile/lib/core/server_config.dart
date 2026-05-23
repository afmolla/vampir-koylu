import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

/// Çalışma zamanı API adresi (APK içine gömülü + kayıtlı + otomatik bulma).
class ServerConfig {
  ServerConfig._();

  static const _prefsKey = 'api_base_url';
  static String _base = AppConfig.defaultApiBaseUrl;

  static String get effectiveBaseUrl => _base;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey)?.trim();
    if (saved != null && saved.isNotEmpty) {
      _base = _normalize(saved);
    } else {
      _base = _normalize(AppConfig.defaultApiBaseUrl);
    }
  }

  static Future<void> setBaseUrl(String url) async {
    _base = _normalize(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _base);
  }

  static String _normalize(String url) {
    var t = url.trim();
    while (t.endsWith('/')) {
      t = t.substring(0, t.length - 1);
    }
    return t;
  }

  static List<String> connectionCandidates() {
    final seen = <String>{};
    void add(String? u) {
      if (u == null || u.isEmpty) return;
      seen.add(_normalize(u));
    }

    add(_base);
    add(AppConfig.defaultApiBaseUrl);
    add('http://85.95.251.204:3002');
    add('http://85.95.251.204:3000');
    return seen.toList();
  }

  /// İlk çalışan vampir-koylu `/health` adresini döner (Next.js 404 elenir).
  static Future<String?> findReachable() async {
    final client = http.Client();
    try {
      for (final base in connectionCandidates()) {
        try {
          final res = await client
              .get(Uri.parse('$base/health'))
              .timeout(const Duration(seconds: 6));
          if (res.statusCode != 200) continue;
          final body = jsonDecode(res.body);
          if (body is Map &&
              body['ok'] == true &&
              body['service'] == 'vampir-koylu-server') {
            return base;
          }
        } catch (_) {}
      }
    } finally {
      client.close();
    }
    return null;
  }
}
