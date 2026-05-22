import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const Duration requestTimeout = Duration(seconds: 15);

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConfig.apiBaseUrl}$path').replace(
      queryParameters: query,
    );
  }

  Future<String> currentVersion() => _appVersion();

  Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) return info.version;
    } catch (_) {}
    return AppConfig.clientVersion;
  }

  /// Sunucunun ayakta olduğunu doğrular (`GET /health`).
  Future<void> checkServer() async {
    final res = await _client
        .get(_uri('/health'))
        .timeout(requestTimeout);
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['ok'] != true) {
      throw ApiException(res.statusCode, 'health not ok');
    }
  }

  Future<Map<String, dynamic>> getVersion() async {
    final version = await _appVersion();
    final res = await _client
        .get(
          _uri('/api/version', {
            'clientVersion': version,
            'platform': AppConfig.platform,
          }),
        )
        .timeout(requestTimeout);
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe({required String token}) async {
    final res = await _client.get(
      _uri('/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 401 || res.statusCode == 404) {
      throw ApiException(res.statusCode, res.body);
    }
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> guestLogin({
    required String nick,
    required String locale,
  }) async {
    final res = await _client.post(
      _uri('/api/auth/guest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nick': nick, 'locale': locale}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode)';
}
