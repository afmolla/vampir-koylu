import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConfig.apiBaseUrl}$path').replace(
      queryParameters: query,
    );
  }

  Future<Map<String, dynamic>> getVersion() async {
    final res = await _client.get(
      _uri('/api/version', {
        'clientVersion': AppConfig.clientVersion,
        'platform': AppConfig.platform,
      }),
    );
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
