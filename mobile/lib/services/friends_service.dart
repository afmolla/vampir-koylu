import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'session_store.dart';

class FriendsService {
  FriendsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Map<String, dynamic>>> listFriends() async {
    final token = await SessionStore().getToken();
    final res = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/friends'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['friends'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  Future<void> addFriend({String? friendId, String? nick}) async {
    final token = await SessionStore().getToken();
    await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/friends/add'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (friendId != null) 'friendId': friendId,
        if (nick != null) 'nick': nick,
      }),
    );
  }

  Future<void> inviteToRoom({
    required String friendId,
    required String roomCode,
    required String hostNick,
  }) async {
    final token = await SessionStore().getToken();
    await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/friends/invite-room'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'friendId': friendId,
        'roomCode': roomCode,
        'hostNick': hostNick,
      }),
    );
  }

  void dispose() => _client.close();
}
