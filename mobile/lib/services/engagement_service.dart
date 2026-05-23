import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'session_store.dart';

class EngagementService {
  EngagementService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, String>> _headers() async {
    final token = await SessionStore().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? body]) async {
    final res = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('HTTP ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchHome() => _get('/api/engagement/home');

  Future<Map<String, dynamic>> fetchLive() => _get('/api/engagement/live');

  Future<Map<String, dynamic>> claimDailyLogin() =>
      _post('/api/engagement/daily-login');

  Future<Map<String, dynamic>> claimWeeklyQuest(String id) =>
      _post('/api/engagement/weekly/$id/claim');

  Future<Map<String, dynamic>> applyReferral(String code) =>
      _post('/api/engagement/referral', {'code': code});

  Future<Map<String, dynamic>> fetchLeaderboard({String type = 'xp'}) =>
      _get('/api/engagement/leaderboard?type=$type&limit=30');

  Future<Map<String, dynamic>> fetchSeason() => _get('/api/engagement/season');

  Future<Map<String, dynamic>> claimSeasonTier(int tier, {String track = 'free'}) =>
      _post('/api/engagement/season/claim', {'tier': tier, 'track': track});

  Future<void> registerPushToken(String token) async {
    await _post('/api/engagement/push-token', {
      'token': token,
      'platform': 'android',
    });
  }

  void dispose() => _client.close();
}
