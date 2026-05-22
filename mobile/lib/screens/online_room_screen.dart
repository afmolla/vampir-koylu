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

  String get _roomChannel => 'room:${_room.code}';

  @override
  void initState() {
    super.initState();
    _room = OnlineRoomState.fromJson(widget.initialRoom);
    widget.socketService.onRoomState(_onRoomState);
    widget.socketService.socket?.emit('chat:join', {'channel': _roomChannel});
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 16),
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
                                  : Text(l10n.eliminated, style: const TextStyle(color: Colors.grey)),
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
                      l10n.needTwoPlayers,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amber),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _room.players.length >= 2 ? _startGame : null,
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
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(l10n.chatRoom, style: Theme.of(context).textTheme.labelLarge),
          ),
          SizedBox(
            height: 180,
            child: ChatPanel(
              socket: widget.socketService.socket,
              channel: _roomChannel,
              nick: widget.nick,
            ),
          ),
        ],
      ),
    );
  }
}
