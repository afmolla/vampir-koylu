import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../screens/private_chat_screen.dart';
import '../services/dm_chat_service.dart';
import '../services/session_store.dart';
import 'chat_panel.dart';

/// Genel sohbet + ozel odalar listesi.
class GeneralChatHub extends StatefulWidget {
  const GeneralChatHub({
    super.key,
    required this.socket,
    required this.nick,
    this.height,
  });

  final io.Socket? socket;
  final String nick;
  /// Sabit yukseklik; null ise ust widget (Expanded vb.) sinirlar.
  final double? height;

  @override
  State<GeneralChatHub> createState() => _GeneralChatHubState();
}

class _GeneralChatHubState extends State<GeneralChatHub> {
  final _dm = DmChatService();
  String? _myUserId;
  List<DmConversation> _dms = [];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _refreshDms();
    widget.socket?.on('chat:message', _onAnyMessage);
    if (widget.socket != null) {
      _dm.listenDmOpened(widget.socket!, (_) => _refreshDms());
    }
  }

  @override
  void dispose() {
    widget.socket?.off('chat:message', _onAnyMessage);
    super.dispose();
  }

  void _onAnyMessage(dynamic _) {
    if (_tab == 1) _refreshDms();
  }

  Future<void> _loadUser() async {
    final id = await SessionStore().getUserId();
    if (mounted) setState(() => _myUserId = id);
  }

  Future<void> _refreshDms() async {
    final socket = widget.socket;
    if (socket == null) return;
    try {
      final list = await _dm.listViaSocket(socket);
      if (mounted) setState(() => _dms = list);
    } catch (_) {
      final list = await _dm.listViaHttp();
      if (mounted) setState(() => _dms = list);
    }
  }

  void _openPrivate(String peerUserId, String peerNick, {String? channel}) {
    if (_myUserId == null || peerUserId == _myUserId) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrivateChatScreen(
          socket: widget.socket,
          myNick: widget.nick,
          myUserId: _myUserId!,
          peerUserId: peerUserId,
          peerNick: peerNick,
          channel: channel,
        ),
      ),
    ).then((_) => _refreshDms());
  }

  Future<void> _openPrivateFromGeneral(String peerUserId, String peerNick) async {
    final socket = widget.socket;
    if (socket == null || _myUserId == null) return;
    try {
      final conv = await _dm.openDm(
        socket: socket,
        myNick: widget.nick,
        targetUserId: peerUserId,
        targetNick: peerNick,
      );
      if (!mounted || conv == null) return;
      _openPrivate(conv.peerUserId, conv.peerNick, channel: conv.channel);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Özel oda açılamadı')),
        );
      }
    }
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ChoiceChip(
              label: const Text('Genel'),
              selected: _tab == 0,
              onSelected: (_) => setState(() => _tab = 0),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('Özel (${_dms.length})'),
              selected: _tab == 1,
              onSelected: (_) {
                setState(() => _tab = 1);
                _refreshDms();
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _tab == 0
              ? ChatPanel(
                  socket: widget.socket,
                  channel: 'general',
                  nick: widget.nick,
                  currentUserId: _myUserId,
                  onPeerTap: (userId, nick) =>
                      _openPrivateFromGeneral(userId, nick),
                )
              : _dms.isEmpty
                  ? const Center(
                      child: Text(
                        'Genel sohbette birine dokun → özel oda',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _dms.length,
                      itemBuilder: (context, i) {
                        final d = _dms[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.lock_outline, size: 20),
                          title: Text(d.peerNick),
                          subtitle: Text(
                            d.lastMessage.isEmpty
                                ? 'Mesaj yok'
                                : d.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openPrivate(
                            d.peerUserId,
                            d.peerNick,
                            channel: d.channel,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    if (h != null) {
      return SizedBox(height: h, child: _buildContent());
    }
    return _buildContent();
  }
}
