import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/online_room.dart';
import '../services/socket_service.dart';
import '../widgets/animated_game_background.dart';
import '../models/game_roles.dart';
import '../widgets/multi_channel_chat.dart';
import '../widgets/voice_chat_strip.dart';
import 'match_summary_screen.dart';
import '../widgets/game_phase_ui.dart';
import '../widgets/phase_banner.dart';
import '../widgets/role_reveal_overlay.dart';

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
  bool _showRoleReveal = false;
  String? _bannerPhaseOverride;

  String get _roomChannel => 'room:${_room.code}';

  @override
  void initState() {
    super.initState();
    _room = OnlineRoomState.fromJson(widget.initialRoom);
    widget.socketService.onRoomState(_onRoomState);
    widget.socketService.socket?.emit('chat:join', {'channel': _roomChannel});
    _checkRoleReveal(_room);
  }

  @override
  void dispose() {
    widget.socketService.offRoomState();
    final socket = widget.socketService.socket;
    socket?.emitWithAck('room:leave', {}, ack: (_) {});
    super.dispose();
  }

  void _checkRoleReveal(OnlineRoomState room) {
    final role = room.game?.yourRole;
    if (role != null && room.status == 'playing') {
      setState(() => _showRoleReveal = true);
    }
  }

  void _maybeOpenSummary(OnlineRoomState room) {
    final summary = room.game?.matchSummary;
    if (summary == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MatchSummaryScreen(
            summary: Map<String, dynamic>.from(summary),
          ),
        ),
      );
    });
  }

  void _onRoomState(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    final next = OnlineRoomState.fromJson(map);
    final prevPhase = _room.game?.phase;
    final nextPhase = next.game?.phase;

    if (prevPhase == 'night' && nextPhase == 'dayVote') {
      setState(() => _bannerPhaseOverride = GamePhaseUi.phaseAfterNightKill());
      Future<void>.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _bannerPhaseOverride = null);
      });
    }

    if (mounted) {
      setState(() => _room = next);
      _checkRoleReveal(next);
      if (next.game?.winner != null) _maybeOpenSummary(next);
    }
  }

  String get _visualPhase {
    if (_bannerPhaseOverride != null) return _bannerPhaseOverride!;
    if (_room.status == 'lobby') return 'lobby';
    final g = _room.game;
    if (g == null) return 'lobby';
    if (g.winner != null || g.phase == 'gameOver') return 'gameOver';
    return g.phase;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = _room.game;
    final inLobby = _room.status == 'lobby';
    final inGame = game != null && !inLobby;
    final activeGame = inGame ? game : null;
    final showVoice = activeGame != null && activeGame.winner == null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${l10n.roomCode} ${_room.code}'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedGameBackground(
            phase: _visualPhase,
            winner: game?.winner,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PhaseBanner(
                          phase: _visualPhase,
                          dayNumber: game?.dayNumber ?? 1,
                          lastVictim: game?.lastVictimName,
                          winner: game?.winner,
                          serverMessage: game?.message,
                        ),
                        const SizedBox(height: 12),
                        if (game?.yourRole != null)
                          Text(
                            l10n.yourRole(
                              roleMeta(game!.yourRole).label(
                                Localizations.localeOf(context).languageCode,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: roleMeta(game.yourRole).color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          l10n.playersCount(
                            _room.players.length,
                            _room.maxPlayers,
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            children: [
                              if (inLobby)
                                ..._room.players.map(
                                  (p) => Card(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    child: ListTile(
                                      leading: Icon(
                                        p.isHost ? Icons.star : Icons.person,
                                        color: p.isHost ? Colors.amber : null,
                                      ),
                                      title: Text(p.nick),
                                      subtitle:
                                          p.isHost ? Text(l10n.host) : null,
                                    ),
                                  ),
                                ),
                              if (game != null)
                                ...game.players.map((p) {
                                  final canTarget = game.canAct &&
                                      game.validTargets.contains(p.id) &&
                                      p.alive;
                                  return Card(
                                    color: canTarget
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.3),
                                    child: ListTile(
                                      title: Text(p.nick),
                                      trailing: p.alive
                                          ? null
                                          : Text(
                                              l10n.eliminated,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                      onTap: canTarget
                                          ? () {
                                              final type = game.phase == 'night'
                                                  ? 'night_kill'
                                                  : 'day_vote';
                                              _gameAction(type, p.id);
                                            }
                                          : null,
                                    ),
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
                            onPressed:
                                _room.players.length >= 2 ? _startGame : null,
                            child: Text(l10n.startGame),
                          ),
                        ],
                        if (game?.winner != null)
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.backToLobby),
                          ),
                      ],
                    ),
                  ),
                ),
                if (activeGame == null || activeGame.winner != null)
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                if (showVoice) ...[
                  VoiceChatStrip(
                    socket: widget.socketService.socket,
                    enabled: activeGame.chatChannels.any(
                      (c) => (c as Map)['type'] == 'proximity',
                    ),
                  ),
                ],
                if (_room.status != 'finished')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Text(
                      l10n.chatRoom,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                MultiChannelChat(
                  socket: widget.socketService.socket,
                  nick: widget.nick,
                  height: showVoice ? 140 : 180,
                  channels: activeGame?.chatChannels ?? game?.chatChannels ?? [
                    {'id': _roomChannel, 'type': 'room'},
                  ],
                ),
              ],
            ),
          ),
          if (_showRoleReveal && game?.yourRole != null)
            RoleRevealOverlay(
              roleId: game!.yourRole,
              onFinished: () => setState(() => _showRoleReveal = false),
            ),
        ],
      ),
    );
  }
}
