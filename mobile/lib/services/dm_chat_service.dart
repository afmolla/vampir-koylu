import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/config.dart';
import 'session_store.dart';

class DmConversation {
  DmConversation({
    required this.channel,
    required this.peerUserId,
    required this.peerNick,
    this.lastMessage = '',
    this.updatedAt,
  });

  final String channel;
  final String peerUserId;
  final String peerNick;
  final String lastMessage;
  final String? updatedAt;

  factory DmConversation.fromJson(Map<String, dynamic> j) {
    return DmConversation(
      channel: j['channel'] as String? ?? '',
      peerUserId: j['peerUserId'] as String? ?? '',
      peerNick: j['peerNick'] as String? ?? '?',
      lastMessage: j['lastMessage'] as String? ?? '',
      updatedAt: j['updatedAt'] as String?,
    );
  }
}

class DmChatService {
  Future<DmConversation?> openDm({
    required io.Socket socket,
    required String myNick,
    required String targetUserId,
    String? targetNick,
  }) async {
    final completer = Completer<Map<String, dynamic>?>();
    socket.emitWithAck(
      'chat:dm:open',
      {
        'targetUserId': targetUserId,
        'targetNick': targetNick,
        'myNick': myNick,
      },
      ack: (data) {
        if (data is Map && data['ok'] == true) {
          completer.complete(Map<String, dynamic>.from(data));
        } else {
          completer.completeError(Exception('dm_open_failed'));
        }
      },
    );
    final data = await completer.future.timeout(const Duration(seconds: 10));
    if (data == null) return null;
    final peer = data['peer'] as Map<String, dynamic>? ?? {};
    return DmConversation(
      channel: data['channel'] as String? ?? '',
      peerUserId: peer['userId'] as String? ?? targetUserId,
      peerNick: peer['nick'] as String? ?? targetNick ?? '?',
    );
  }

  Future<List<DmConversation>> listViaSocket(io.Socket socket) async {
    final completer = Completer<List<DmConversation>>();
    socket.emitWithAck('chat:dm:list', {}, ack: (data) {
      if (data is Map && data['ok'] == true) {
        final list = data['conversations'] as List<dynamic>? ?? [];
        completer.complete(
          list
              .map((e) => DmConversation.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      } else {
        completer.complete([]);
      }
    });
    return completer.future.timeout(const Duration(seconds: 10));
  }

  Future<List<DmConversation>> listViaHttp() async {
    final token = await SessionStore().getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/chat/dm/list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['conversations'] as List<dynamic>? ?? [];
    return list
        .map((e) => DmConversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void listenDmOpened(io.Socket socket, void Function(String channel) onChannel) {
    socket.on('chat:dm:opened', (data) {
      if (data is Map) {
        final ch = data['channel'] as String?;
        if (ch != null && ch.isNotEmpty) {
          socket.emit('chat:join', {'channel': ch});
          onChannel(ch);
        }
      }
    });
  }
}
