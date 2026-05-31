import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../l10n/app_localizations.dart';
import '../services/chat_session_store.dart';
import '../services/social_service.dart';

export '../services/chat_session_store.dart' show ChatMessage;

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
  final _focusNode = FocusNode();
  final _social = SocialService();
  final Set<String> _mutedUsers = {};
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    ChatSessionStore.bindSocket(widget.socket);
    _reloadFromStore();
    ChatSessionStore.revision.addListener(_reloadFromStore);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(covariant ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel) {
      _reloadFromStore();
    }
    if (oldWidget.socket != widget.socket) {
      ChatSessionStore.bindSocket(widget.socket);
    }
  }

  void _reloadFromStore() {
    if (!mounted) return;
    setState(() {
      _messages = ChatSessionStore.forChannel(widget.channel);
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    ChatSessionStore.revision.removeListener(_reloadFromStore);
    _social.dispose();
    _focusNode.dispose();
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

  static const _quickPhrases = [
    '👀 Şüpheli',
    '✓ Güveniyorum',
    '🤫 Sus',
    '🗳️ Oy ver',
  ];

  void _sendPreset(String text) {
    _controller.text = text;
    _send();
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
                    final isMe = (widget.currentUserId != null &&
                            msg.userId == widget.currentUserId) ||
                        msg.nick.toLowerCase() ==
                            widget.nick.toLowerCase();
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
        if (!widget.isPrivate)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _quickPhrases.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final phrase = _quickPhrases[i];
                return ActionChip(
                  label: Text(phrase, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.socket == null
                      ? null
                      : () => _sendPreset(phrase),
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
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.text,
                  scrollPadding: const EdgeInsets.only(bottom: 120),
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
