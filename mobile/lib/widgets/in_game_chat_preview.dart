import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'chat_panel.dart';

/// Oyun sirasinda son gelen mesaji tek satirda gosterir; tiklaninca sohbet acilir.
class InGameChatPreview extends StatefulWidget {
  const InGameChatPreview({
    super.key,
    required this.socket,
    required this.channels,
    required this.onOpenChat,
    this.myUserId,
  });

  final io.Socket? socket;
  final Set<String> channels;
  final VoidCallback onOpenChat;
  final String? myUserId;

  @override
  State<InGameChatPreview> createState() => _InGameChatPreviewState();
}

class _InGameChatPreviewState extends State<InGameChatPreview> {
  ChatMessage? _latest;

  @override
  void initState() {
    super.initState();
    widget.socket?.on('chat:message', _onMessage);
  }

  @override
  void didUpdateWidget(covariant InGameChatPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.socket != widget.socket) {
      oldWidget.socket?.off('chat:message', _onMessage);
      widget.socket?.on('chat:message', _onMessage);
    }
  }

  @override
  void dispose() {
    widget.socket?.off('chat:message', _onMessage);
    super.dispose();
  }

  void _onMessage(dynamic data) {
    if (data is! Map) return;
    final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
    if (!widget.channels.contains(msg.channel)) return;
    if (widget.myUserId != null &&
        msg.userId.isNotEmpty &&
        msg.userId == widget.myUserId) {
      return;
    }
    if (mounted) setState(() => _latest = msg);
  }

  @override
  Widget build(BuildContext context) {
    if (_latest == null) return const SizedBox.shrink();

    final preview =
        '${_latest!.nick}: ${_latest!.content.replaceAll('\n', ' ')}';

    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpenChat,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 18, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.open_in_full, size: 16, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
