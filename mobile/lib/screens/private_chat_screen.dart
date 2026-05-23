import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../services/dm_chat_service.dart';
import '../widgets/chat_panel.dart';

/// Ikili ozel oda — oyun icindeyken de acik kalir.
class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen({
    super.key,
    required this.socket,
    required this.myNick,
    required this.myUserId,
    required this.peerUserId,
    required this.peerNick,
    this.channel,
  });

  final io.Socket? socket;
  final String myNick;
  final String myUserId;
  final String peerUserId;
  final String peerNick;
  final String? channel;

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final _dm = DmChatService();
  String? _channel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  Future<void> _initChannel() async {
    if (widget.channel != null && widget.channel!.isNotEmpty) {
      widget.socket?.emit('chat:join', {'channel': widget.channel});
      if (mounted) {
        setState(() {
          _channel = widget.channel;
          _loading = false;
        });
      }
      return;
    }
    final socket = widget.socket;
    if (socket == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final conv = await _dm.openDm(
        socket: socket,
        myNick: widget.myNick,
        targetUserId: widget.peerUserId,
        targetNick: widget.peerNick,
      );
      if (mounted) {
        setState(() {
          _channel = conv?.channel;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Özel: ${widget.peerNick}'),
            const Text(
              'Oyun bitene kadar kaybolmaz',
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _channel == null
              ? const Center(child: Text('Oda açılamadı'))
              : SafeArea(
                  child: ChatPanel(
                    socket: widget.socket,
                    channel: _channel!,
                    nick: widget.myNick,
                    currentUserId: widget.myUserId,
                    isPrivate: true,
                  ),
                ),
    );
  }
}
