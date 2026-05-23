import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/online_room.dart';
import '../services/socket_service.dart';
import '../widgets/animated_game_background.dart';
import '../models/game_roles.dart';
import '../widgets/chat_bottom_sheet.dart';
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
  late bool _fillWithBots;

  String get _roomChannel => 'room:${_room.code}';

  bool get _isHost => _room.players.any(
        (p) => p.isHost && p.nick == widget.nick,
      );

  int get _humanCount => _room.players.where((p) => !p.isBot).length;

  int get _minPlayers => _room.minPlayers;

  bool get _canStart {
    if (!_isHost || _room.status != 'lobby') return false;
    if (_fillWithBots) return _humanCount >= 1;
    return _humanCount >= 2 && _room.players.length >= _minPlayers;
  }

  bool get _canFillBots =>
      _isHost &&
      _room.status == 'lobby' &&
      _fillWithBots &&
      _room.players.length < _minPlayers;

  @override
  void initState() {
    super.initState();
    _room = OnlineRoomState.fromJson(widget.initialRoom);
    _fillWithBots = _room.fillWithBots;
    widget.socketService.onRoomState(_onRoomState);
    widget.socketService.socket?.emit('chat:join', {'channel': _roomChannel});
    _checkRoleReveal(_room);
  }

  Future<bool> _confirmLeave() async {
    if (_room.status != 'playing' || !_isHost) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oyundan çık?'),
        content: const Text(
          'Kurucu olarak çıkarsan oyun iptal olur ve 25 coin cezası uygulanır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çık (-25 coin)'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _leaveRoom() {
    widget.socketService.offRoomState();
    final socket = widget.socketService.socket;
    socket?.emitWithAck('room:leave', {}, ack: (_) {});
  }

  @override
  void dispose() {
    _leaveRoom();
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
      setState(() {
        _room = next;
        _fillWithBots = next.fillWithBots || _fillWithBots;
      });
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

  String _socketErrorMessage(dynamic data) {
    if (data is! Map) return 'İşlem başarısız';
    final err = data['error'] as String? ?? '';
    switch (err) {
      case 'need_more_players':
        return 'Yeterli oyuncu yok — «Bot ile doldur» veya bekleyin.';
      case 'need_two_humans':
        return 'En az 1 kişi gerekli (bot modunda).';
      case 'not_host':
        return 'Sadece oda kurucusu başlatabilir.';
      default:
        return err.isEmpty ? 'İşlem başarısız' : err;
    }
  }

  Future<void> _fillBots() async {
    final socket = widget.socketService.socket;
    if (socket == null) return;
    final completer = Completer<bool>();
    socket.emitWithAck('room:fill-bots', {}, ack: (data) {
      if (data is Map && data['ok'] == true) {
        completer.complete(true);
      } else {
        completer.completeError(Exception(_socketErrorMessage(data)));
      }
    });
    try {
      await completer.future.timeout(const Duration(seconds: 8));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Botlar odaya eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _startGame() async {
    final socket = widget.socketService.socket;
    if (socket == null) return;
    if (_fillWithBots && _room.players.length < _minPlayers) {
      await _fillBots();
    }
    final completer = Completer<bool>();
    socket.emitWithAck('room:start', {
      'fillWithBots': _fillWithBots,
    }, ack: (data) {
      if (data is Map && data['ok'] == true) {
        completer.complete(true);
      } else {
        completer.completeError(Exception(_socketErrorMessage(data)));
      }
    });
    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
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
    final showVoice = _room.status != 'finished';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!await _confirmLeave()) return;
        _leaveRoom();
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${l10n.roomCode} ${_room.code}'),
        backgroundColor: Colors.transparent,
        actions: [
          if (showVoice)
            VoiceChatStrip(
              socket: widget.socketService.socket,
              enabled: true,
              compact: true,
              autoJoin: inGame && game?.winner == null,
            ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Sohbet',
            onPressed: () {
              showAppChatSheet(
                context: context,
                socket: widget.socketService.socket,
                nick: widget.nick,
                title: 'Oda sohbeti',
              );
            },
          ),
        ],
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
                                      subtitle: Text(
                                        [
                                          if (p.isHost) l10n.host,
                                          if (p.isBot) 'Bot',
                                        ].join(' · '),
                                      ),
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
                            _fillWithBots
                                ? '${_room.players.length}/${_room.maxPlayers} · bot ile min $_minPlayers'
                                : '${_room.players.length}/${_room.maxPlayers} · min $_minPlayers kişi',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.amber),
                          ),
                          if (_isHost) ...[
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Eksikleri bot ile doldur',
                                style: TextStyle(fontSize: 14),
                              ),
                              value: _fillWithBots,
                              onChanged: (v) =>
                                  setState(() => _fillWithBots = v ?? true),
                            ),
                            if (_canFillBots)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: OutlinedButton.icon(
                                  onPressed: _fillBots,
                                  icon: const Icon(Icons.smart_toy_outlined),
                                  label: Text(
                                    'Bot ile doldur ($_minPlayers kişi)',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: _canStart ? _startGame : null,
                              child: Text(l10n.startGame),
                            ),
                          ] else
                            const Text(
                              'Oyunu kurucu başlatır.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
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
                  height: 180,
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
    ),
    );
  }
}
