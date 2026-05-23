import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'session_store.dart';

class SocialService {
  SocialService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> report({
    String? targetId,
    String? targetNick,
    String? channel,
    String reason = 'other',
  }) async {
    final token = await SessionStore().getToken();
    await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/social/report'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (targetId != null) 'targetId': targetId,
        if (targetNick != null) 'targetNick': targetNick,
        if (channel != null) 'channel': channel,
        'reason': reason,
      }),
    );
  }

  Future<void> muteUser(String userId) async {
    final token = await SessionStore().getToken();
    await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/social/mute'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );
  }

  void dispose() => _client.close();
}
