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
    Map<String, dynamic> decoded = {};
    try {
      final raw = jsonDecode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (_) {}
    if (res.statusCode != 200) {
      final err = decoded['error'] as String? ?? 'http_${res.statusCode}';
      if (err == 'insufficient_coins') {
        throw Exception(
          'Yetersiz coin (gerekli: ${decoded['requiredCoins']})',
        );
      }
      if (err == 'insufficient_balance') {
        throw Exception(
          'Yetersiz bakiye (gerekli: ${decoded['requiredBalance']} ₺)',
        );
      }
      throw Exception(err);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> fetchProfile() => _get('/api/profile/me');

  Future<Map<String, dynamic>> claimDailyLogin() =>
      _post('/api/profile/daily-login');

  Future<Map<String, dynamic>> claimQuest(String questId) =>
      _post('/api/profile/quests/$questId/claim');

  Future<Map<String, dynamic>> purchaseCosmetic(String cosmeticId) =>
      _post('/api/shop/purchase', {'cosmeticId': cosmeticId});

  Future<Map<String, dynamic>> equipCosmetic(String slot, String cosmeticId) =>
      _post('/api/shop/equip', {'slot': slot, 'cosmeticId': cosmeticId});

  Future<Map<String, dynamic>> fetchMatchHistory({int limit = 30}) =>
      _get('/api/profile/matches?limit=$limit');

  Future<Map<String, dynamic>> fetchBalanceHistory({int limit = 20}) =>
      _get('/api/profile/balance/history?limit=$limit');

  Future<Map<String, dynamic>> fetchTournaments() => _get('/api/tournaments');

  Future<Map<String, dynamic>> fetchTournament(String id) =>
      _get('/api/tournaments/$id');

  Future<Map<String, dynamic>> registerTournament(
    String id, {
    required String method,
    String preferredRole = 'random',
  }) =>
      _post('/api/tournaments/$id/register', {
        'method': method,
        'preferredRole': preferredRole,
      });

  Future<Map<String, dynamic>> confirmTournamentPayment(
    String id,
    String paymentRef,
  ) =>
      _post('/api/tournaments/$id/confirm-payment', {'paymentRef': paymentRef});

  Future<Map<String, dynamic>> verifyPlayPurchase({
    required String tournamentId,
    required String paymentRef,
    required String purchaseToken,
    required String productId,
  }) =>
      _post('/api/payments/play/verify', {
        'tournamentId': tournamentId,
        'paymentRef': paymentRef,
        'purchaseToken': purchaseToken,
        'productId': productId,
      });

  Future<Map<String, dynamic>> fetchTournamentLobby(String id) =>
      _get('/api/tournaments/$id/lobby');

  Future<Map<String, dynamic>> openTournamentLobby(String id) =>
      _post('/api/tournaments/$id/open-lobby');

  void dispose() => _client.close();
}
