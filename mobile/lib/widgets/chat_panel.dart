import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../services/session_store.dart';
import '../services/social_service.dart';

class ChatMessage {
  final int id;
  final String channel;
  final String userId;
  final String nick;
  final String content;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.channel,
    required this.userId,
    required this.nick,
    required this.content,
    required this.createdAt,
  });

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

class ChatPanel extends StatefulWidget {
  const ChatPanel({
    super.key,
    required this.socket,
    required this.channel,
    required this.nick,
    this.currentUserId,
    this.onPeerTap,
    this.isPrivate = false,
  });

  final io.Socket? socket;
  final String channel;
  final String nick;
  final String? currentUserId;
  final void Function(String userId, String nick)? onPeerTap;
  final bool isPrivate;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _social = SocialService();
  final List<ChatMessage> _messages = [];
  final Set<String> _mutedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
    widget.socket?.on('chat:message', _onMessage);
  }

  @override
  void didUpdateWidget(covariant ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel) {
      _messages.clear();
      _loadHistory();
    }
    if (oldWidget.socket != widget.socket) {
      oldWidget.socket?.off('chat:message', _onMessage);
      widget.socket?.on('chat:message', _onMessage);
    }
  }

  @override
  void dispose() {
    widget.socket?.off('chat:message', _onMessage);
    _social.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessageActions(ChatMessage msg) {
    if (msg.userId.isEmpty || msg.userId.startsWith('bot:')) return;
    if (widget.currentUserId != null && msg.userId == widget.currentUserId) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Rapor et'),
              onTap: () async {
                Navigator.pop(ctx);
                await _social.report(
                  targetId: msg.userId,
                  targetNick: msg.nick,
                  channel: widget.channel,
                  reason: 'chat',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rapor gönderildi')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('Sustur'),
              onTap: () async {
                Navigator.pop(ctx);
                await _social.muteUser(msg.userId);
                setState(() => _mutedUsers.add(msg.userId));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onMessage(dynamic data) {
    if (data is! Map) return;
    final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
    if (msg.channel != widget.channel) return;
    if (mounted) {
      setState(() => _messages.add(msg));
      _scrollToBottom();
    }
  }

  Future<void> _loadHistory() async {
    try {
      final encoded = Uri.encodeComponent(widget.channel);
      final headers = <String, String>{};
      if (widget.channel.startsWith('dm:')) {
        final token = await SessionStore().getToken();
        if (token != null) headers['Authorization'] = 'Bearer $token';
      }
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat/$encoded'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['messages'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(
              list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)),
            );
          });
          _scrollToBottom();
        }
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.socket == null) return;
    widget.socket!.emitWithAck(
      'chat:send',
      {'channel': widget.channel, 'nick': widget.nick, 'content': text},
      ack: (_) {},
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    '💬',
                    style: TextStyle(fontSize: 32, color: Colors.white24),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    if (_mutedUsers.contains(msg.userId)) {
                      return const SizedBox.shrink();
                    }
                    final isMe = widget.currentUserId != null &&
                        msg.userId == widget.currentUserId;
                    final canTapPeer = !widget.isPrivate &&
                        !isMe &&
                        widget.onPeerTap != null &&
                        msg.userId.isNotEmpty &&
                        !msg.userId.startsWith('bot:');

                    return GestureDetector(
                      onLongPress: () => _showMessageActions(msg),
                      child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: canTapPeer
                                    ? () => widget.onPeerTap!(
                                          msg.userId,
                                          msg.nick,
                                        )
                                    : null,
                                child: Text(
                                  '${msg.nick}: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: canTapPeer
                                        ? Colors.lightBlueAccent
                                        : Colors.amber,
                                    fontSize: 13,
                                    decoration: canTapPeer
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: msg.content,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: l10n.chatHint,
                    hintStyle: const TextStyle(fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.send, size: 20),
                onPressed: _send,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
