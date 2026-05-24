import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'session_store.dart';

class AdminService {
  AdminService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> fetchUsers({
    String filter = 'all',
    String search = '',
    int limit = 80,
    int offset = 0,
  }) async {
    final token = await SessionStore().getToken();
    if (token == null) throw Exception('unauthorized');

    final query = <String, String>{
      'filter': filter,
      'limit': '$limit',
      'offset': '$offset',
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/admin-panel/users')
        .replace(queryParameters: query);

    final res = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 403) throw Exception('forbidden');
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> adjustCoins({
    required String userId,
    required int delta,
  }) async {
    final token = await SessionStore().getToken();
    if (token == null) throw Exception('unauthorized');

    final res = await _client.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/api/admin-panel/users/$userId/coins'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'delta': delta}),
    );

    if (res.statusCode == 403) throw Exception('forbidden');
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}
