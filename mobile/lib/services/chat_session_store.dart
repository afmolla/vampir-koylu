import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Uygulama oturumu sohbet onbellegi — panel kapaninca silinmez; oda cikis / disconnect ile temizlenir.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.channel,
    required this.userId,
    required this.nick,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String channel;
  final String userId;
  final String nick;
  final String content;
  final String createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    return ChatMessage(
      id: j['id'] as int? ?? 0,
      channel: j['channel'] as String? ?? '',
      userId: j['user_id'] as String? ?? '',
      nick: j['nick'] as String? ?? '?',
      content: j['content'] as String? ?? '',
      createdAt: j['created_at'] as String? ?? '',
    );
  }
}

class ChatSessionStore {
  ChatSessionStore._();

  static const _maxPerChannel = 400;

  static final ValueNotifier<int> revision = ValueNotifier(0);
  static final Map<String, List<ChatMessage>> _byChannel = {};

  static io.Socket? _socket;
  static void Function(dynamic)? _handler;

  static void bindSocket(io.Socket? socket) {
    if (_socket != null && _handler != null) {
      _socket!.off('chat:message', _handler);
    }
    _socket = socket;
    _handler = _onSocketMessage;
    socket?.on('chat:message', _handler!);
  }

  static void _onSocketMessage(dynamic data) {
    if (data is! Map) return;
    add(ChatMessage.fromJson(Map<String, dynamic>.from(data)));
  }

  static void add(ChatMessage msg) {
    final list = _byChannel.putIfAbsent(msg.channel, () => []);
    if (list.isNotEmpty &&
        list.last.id == msg.id &&
        list.last.content == msg.content) {
      return;
    }
    list.add(msg);
    if (list.length > _maxPerChannel) {
      list.removeRange(0, list.length - _maxPerChannel);
    }
    revision.value++;
  }

  static List<ChatMessage> forChannel(String channel) =>
      List.unmodifiable(_byChannel[channel] ?? []);

  static ChatMessage? latestForChannels(
    Iterable<String> channels, {
    String? excludeUserId,
  }) {
    ChatMessage? best;
    for (final ch in channels) {
      final list = _byChannel[ch];
      if (list == null || list.isEmpty) continue;
      for (var i = list.length - 1; i >= 0; i--) {
        final m = list[i];
        if (excludeUserId != null &&
            m.userId.isNotEmpty &&
            m.userId == excludeUserId) {
          continue;
        }
        if (best == null || m.id > best.id) best = m;
        break;
      }
    }
    return best;
  }

  /// Oda lobisi / oyun kanallari (room:, dead:, vampire:).
  static void clearForRoom(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    if (code.isEmpty) return;
    final remove = <String>[];
    for (final key in _byChannel.keys) {
      if (key == 'room:$code' || key == 'dead:$code' || key == 'vampire:$code') {
        remove.add(key);
      }
    }
    for (final k in remove) {
      _byChannel.remove(k);
    }
    if (remove.isNotEmpty) revision.value++;
  }

  static void clearAll() {
    _byChannel.clear();
    revision.value++;
    if (_socket != null && _handler != null) {
      _socket!.off('chat:message', _handler);
    }
    _socket = null;
    _handler = null;
  }
}
