import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/friends_service.dart';
import '../services/session_store.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    super.key,
    this.roomCode,
    this.hostNick,
  });

  /// Doluysa her arkadaşa odaya davet gönderilir.
  final String? roomCode;
  final String? hostNick;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _api = FriendsService();
  final _nickController = TextEditingController();
  List<Map<String, dynamic>> _friends = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nickController.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _friends = await _api.listFriends();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final nick = _nickController.text.trim();
    if (nick.isEmpty) return;
    try {
      await _api.addFriend(nick: nick);
      _nickController.clear();
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _inviteFriend(String friendId, String friendNick) async {
    final code = widget.roomCode;
    if (code == null || friendId.isEmpty) return;
    try {
      await _api.inviteToRoom(
        friendId: friendId,
        roomCode: code,
        hostNick: widget.hostNick ?? 'Host',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$friendNick davet edildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _copyInvite() async {
    final code = await SessionStore().getUserId();
    final link = 'vampir://join?ref=$code';
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Davet linki kopyalandı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _copyInvite,
            tooltip: 'Davet linki',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nickController,
                    decoration: const InputDecoration(
                      labelText: 'Nick ile ekle',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Ekle')),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _friends.isEmpty
                    ? const Center(child: Text('Henüz arkadaş yok'))
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, i) {
                          final f = _friends[i];
                          final friendId = f['id'] as String? ?? '';
                          final friendNick = f['nick'] as String? ?? '?';
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(friendNick),
                            trailing: widget.roomCode != null
                                ? IconButton(
                                    icon: const Icon(Icons.send),
                                    tooltip: 'Odaya davet',
                                    onPressed: () => _inviteFriend(
                                      friendId,
                                      friendNick,
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
