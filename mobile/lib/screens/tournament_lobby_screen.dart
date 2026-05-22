import 'dart:async';

import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/session_store.dart';
import '../services/socket_service.dart';
import 'online_room_screen.dart';

class TournamentLobbyScreen extends StatefulWidget {
  const TournamentLobbyScreen({
    super.key,
    required this.tournamentId,
    required this.title,
    required this.nick,
  });

  final String tournamentId;
  final String title;
  final String nick;

  @override
  State<TournamentLobbyScreen> createState() => _TournamentLobbyScreenState();
}

class _TournamentLobbyScreenState extends State<TournamentLobbyScreen> {
  final _api = ProfileService();
  final _socketService = SocketService();
  Map<String, dynamic>? _lobby;
  bool _loading = true;
  bool _joining = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _api.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final data = await _api.fetchTournamentLobby(widget.tournamentId);
      if (mounted) setState(() => _lobby = data);
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _openLobby() async {
    try {
      await _api.openTournamentLobby(widget.tournamentId);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _enterRoom() async {
    final code = _lobby?['roomCode'] as String?;
    if (code == null || code.isEmpty) return;

    setState(() => _joining = true);
    try {
      final token = await SessionStore().getToken();
      if (token == null) throw Exception('Giriş gerekli');
      await _socketService.connect(token: token);
      final socket = _socketService.socket;
      if (socket == null) throw Exception('Bağlantı yok');

      final completer = Completer<dynamic>();
      socket.emitWithAck(
        'room:join',
        {'code': code, 'nick': widget.nick},
        ack: (data) => completer.complete(data),
      );
      final room = await completer.future.timeout(const Duration(seconds: 12));

      if (room is! Map || room['ok'] != true) {
        throw Exception(room is Map ? room['error'] : 'join_failed');
      }

      final roomState = room['room'] as Map<String, dynamic>?;
      if (!mounted || roomState == null) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnlineRoomScreen(
            nick: widget.nick,
            socketService: _socketService,
            initialRoom: roomState,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lobiye girilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _lobby == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final open = _lobby?['open'] == true;
    final snap = _lobby?['snapshot'] as Map<String, dynamic>?;
    final players = snap?['players'] as List<dynamic>? ?? [];
    final registered = _lobby?['registered'] as List<dynamic>? ?? [];
    final roomCode = _lobby?['roomCode'] as String?;
    final paid = _lobby?['paidEntries'] as int? ?? registered.length;
    final min = _lobby?['minPlayers'] as int? ?? 6;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} — Lobi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!open) ...[
            Text(
              'Kayıtlı oyuncu: $paid / $min (lobi için min dolmalı)',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: paid >= min ? _openLobby : null,
              child: const Text('Lobiyi aç'),
            ),
          ] else ...[
            Card(
              color: const Color(0xFF1A2838),
              child: ListTile(
                leading: const Icon(Icons.meeting_room, color: Colors.amber),
                title: Text('Oda kodu: $roomCode'),
                subtitle: Text(
                  'Lobide ${players.length} oyuncu · min $min',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Kayıtlılar', style: TextStyle(fontWeight: FontWeight.bold)),
            ...registered.map((r) {
              final m = r as Map<String, dynamic>;
              final inRoom = players.any(
                (p) => (p as Map)['userId'] == m['userId'],
              );
              return ListTile(
                dense: true,
                leading: Icon(
                  inRoom ? Icons.wifi : Icons.wifi_off,
                  color: inRoom ? Colors.greenAccent : Colors.white38,
                ),
                title: Text(m['nick'] as String? ?? '—'),
                trailing: Text(inRoom ? 'Bağlı' : 'Bekliyor'),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _joining ? null : _enterRoom,
                icon: _joining
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_joining ? 'Bağlanıyor…' : 'Lobiye gir ve bekle'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Host «Oyunu başlat» deyince maç başlar. Herkes lobide bağlı olmalı.',
              style: TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
