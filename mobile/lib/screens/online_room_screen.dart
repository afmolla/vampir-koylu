import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/online_room.dart';
import '../services/socket_service.dart';
import '../widgets/chat_panel.dart';

class OnlineRoomScreen extends StatefulWidget {
  const OnlineRoomScreen({
    super.key,
    required this.nick,
    required this.socketService,
    required this.initialRoom,
  });

  final String nick;
  final SocketService socketService;
  final Map<String, dynamic> initialRoom;

  @override
  State<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends State<OnlineRoomScreen> {
  late OnlineRoomState _room;
  bool _showChat = false;
  String _chatChannel = 'general';

  @override
  void initState() {
    super.initState();
    _room = OnlineRoomState.fromJson(widget.initialRoom);
    _chatChannel = 'room:${_room.code}';
    widget.socketService.onRoomState(_onRoomState);
  }

  @override
  void dispose() {
    widget.socketService.offRoomState();
    final socket = widget.socketService.socket;
    socket?.emitWithAck('room:leave', {}, ack: (_) {});
    super.dispose();
  }

  void _onRoomState(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    if (mounted) setState(() => _room = OnlineRoomState.fromJson(map));
  }

  Future<void> _startGame() async {
    final socket = widget.socketService.socket;
    if (socket == null) return;
    final completer = Completer<bool>();
    socket.emitWithAck('room:start', {}, ack: (data) {
      if (data is Map && data['ok'] == true) {
        completer.complete(true);
      } else {
        completer.completeError(
          Exception(data is Map ? data['error'] : 'start_failed'),
        );
      }
    });
    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _gameAction(String type, int targetId) async {
    final socket = widget.socketService.socket;
    if (socket == null) return;
    socket.emitWithAck(
      'game:action',
      {'type': type, 'targetId': targetId},
      ack: (_) {},
    );
  }

  String _phaseLabel(AppLocalizations l10n) {
    final g = _room.game;
    if (g == null) return l10n.roomWaiting;
    if (g.winner != null) {
      return g.winner == 'vampire' ? l10n.vampiresWin : l10n.villagersWin;
    }
    if (g.phase == 'night') return l10n.phaseNight;
    if (g.phase == 'dayVote') return l10n.phaseDay;
    return g.phase;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = _room.game;
    final inLobby = _room.status == 'lobby';

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.roomCode} ${_room.code}'),
        actions: [
          IconButton(
            icon: Icon(_showChat ? Icons.people : Icons.chat),
            onPressed: () => setState(() => _showChat = !_showChat),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: _showChat ? 1 : 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _phaseLabel(l10n),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (g != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.dayLabel} ${g.dayNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    if (g.yourRole != null)
                      Text(
                        l10n.yourRole(g.yourRole!),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: g.yourRole == 'vampire'
                              ? Colors.redAccent
                              : Colors.greenAccent,
                        ),
                      ),
                    if (g.lastVictimName != null)
                      Text(
                        l10n.lastVictim(g.lastVictimName!),
                        textAlign: TextAlign.center,
                      ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l10n.playersCount(_room.players.length, _room.maxPlayers),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        if (inLobby)
                          ..._room.players.map(
                            (p) => ListTile(
                              leading: Icon(
                                p.isHost ? Icons.star : Icons.person,
                                color: p.isHost ? Colors.amber : null,
                              ),
                              title: Text(p.nick),
                              subtitle: p.isHost ? Text(l10n.host) : null,
                            ),
                          ),
                        if (g != null)
                          ...g.players.map((p) {
                            final canTarget =
                                g.canAct && g.validTargets.contains(p.id) && p.alive;
                            return ListTile(
                              title: Text(p.nick),
                              trailing: p.alive
                                  ? null
                                  : Text(l10n.eliminated,
                                      style: const TextStyle(color: Colors.grey)),
                              tileColor: canTarget
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : null,
                              onTap: canTarget
                                  ? () {
                                      final type = g.phase == 'night'
                                          ? 'night_kill'
                                          : 'day_vote';
                                      _gameAction(type, p.id);
                                    }
                                  : null,
                            );
                          }),
                      ],
                    ),
                  ),
                  if (inLobby) ...[
                    Text(
                      l10n.needSixPlayers,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amber),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed:
                          _room.players.length >= 6 ? _startGame : null,
                      child: Text(l10n.startGame),
                    ),
                  ],
                  if (g?.winner != null)
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.backToLobby),
                    ),
                ],
              ),
            ),
          ),
          if (_showChat)
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white12)),
                color: Colors.black12,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _chatChannel = 'room:${_room.code}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _chatChannel.startsWith('room:')
                                      ? Colors.amber
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              l10n.roomChat,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _chatChannel.startsWith('room:')
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _chatChannel.startsWith('room:')
                                    ? Colors.amber
                                    : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _chatChannel = 'general'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _chatChannel == 'general'
                                      ? Colors.amber
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              l10n.generalChat,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _chatChannel == 'general'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _chatChannel == 'general'
                                    ? Colors.amber
                                    : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ChatPanel(
                      socket: widget.socketService.socket,
                      channel: _chatChannel,
                      nick: widget.nick,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
