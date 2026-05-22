import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../services/session_store.dart';
import '../services/socket_service.dart';
import 'online_room_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key, required this.nick});

  final String nick;

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final _joinController = TextEditingController();
  final _socketService = SocketService();
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;
  String? _error;
  int _maxPlayers = 2;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/rooms'),
      );
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['rooms'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _rooms = list.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _withSocket(Future<void> Function(dynamic socket) fn) async {
    final token = await SessionStore().getToken();
    if (token == null || token.isEmpty) throw Exception('no_token');
    final socket = await _socketService.connect(token: token);
    await fn(socket);
  }

  Future<void> _createRoom() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _withSocket((socket) async {
        final completer = Completer<Map<String, dynamic>?>();
        socket.emitWithAck(
          'room:create',
          {'nick': widget.nick, 'maxPlayers': _maxPlayers},
          ack: (data) {
            if (data is Map && data['ok'] == true) {
              completer.complete(data['room'] as Map<String, dynamic>?);
            } else {
              completer.completeError(Exception(data?.toString() ?? 'create_failed'));
            }
          },
        );
        final room = await completer.future.timeout(const Duration(seconds: 10));
        if (!mounted || room == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnlineRoomScreen(
              nick: widget.nick,
              socketService: _socketService,
              initialRoom: room,
            ),
          ),
        );
        _loadRooms();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}\n$e')),
        );
      }
    }
  }

  Future<void> _joinRoom([String? code]) async {
    final l10n = AppLocalizations.of(context)!;
    final c = (code ?? _joinController.text).trim().toUpperCase();
    if (c.length < 4) return;
    try {
      await _withSocket((socket) async {
        final completer = Completer<Map<String, dynamic>?>();
        socket.emitWithAck(
          'room:join',
          {'code': c, 'nick': widget.nick},
          ack: (data) {
            if (data is Map && data['ok'] == true) {
              completer.complete(data['room'] as Map<String, dynamic>?);
            } else {
              final err = data is Map ? data['error'] : 'join_failed';
              completer.completeError(Exception('$err'));
            }
          },
        );
        final room = await completer.future.timeout(const Duration(seconds: 10));
        if (!mounted || room == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnlineRoomScreen(
              nick: widget.nick,
              socketService: _socketService,
              initialRoom: room,
            ),
          ),
        );
        _loadRooms();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}\n$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onlinePlay),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRooms),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.onlineLobbyTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.onlineLobbyDesc, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _joinController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.roomCodeHint,
                    hintText: 'ABC123',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: () => _joinRoom(), child: Text(l10n.joinRoom)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.maxPlayers),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _maxPlayers,
                items: const [6, 7, 8]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) => setState(() => _maxPlayers = v ?? 6),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _createRoom,
                icon: const Icon(Icons.add),
                label: Text(l10n.createRoom),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.openRooms, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          if (!_loading && _rooms.isEmpty)
            Text(l10n.noOpenRooms, style: const TextStyle(color: Colors.white54)),
          ..._rooms.map((r) {
            return Card(
              child: ListTile(
                title: Text('${r['code']} — ${r['playerCount']}/${r['maxPlayers']}'),
                subtitle: Text(l10n.hostLabel(r['hostNick'] as String? ?? '?')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _joinRoom(r['code'] as String?),
              ),
            );
          }),
        ],
      ),
    );
  }
}
