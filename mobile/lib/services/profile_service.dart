import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'session_store.dart';

class ProfileService {
  ProfileService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> _get(String path) async {
    final token = await SessionStore().getToken();
    final res = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? body]) async {
    final token = await SessionStore().getToken();
    final res = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchProfile() => _get('/api/profile/me');

  Future<Map<String, dynamic>> claimDailyLogin() =>
      _post('/api/profile/daily-login');

  Future<Map<String, dynamic>> claimQuest(String questId) =>
      _post('/api/profile/quests/$questId/claim');

  Future<Map<String, dynamic>> purchaseCosmetic(String cosmeticId) =>
      _post('/api/shop/purchase', {'cosmeticId': cosmeticId});

  void dispose() => _client.close();
}
