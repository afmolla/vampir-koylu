import 'package:flutter/material.dart';

import '../game/solo_game.dart';
import '../l10n/app_localizations.dart';
import '../widgets/animated_game_background.dart';
import '../widgets/game_phase_ui.dart';
import '../widgets/phase_banner.dart';
import '../widgets/role_reveal_overlay.dart';

class SoloGameScreen extends StatefulWidget {
  const SoloGameScreen({
    super.key,
    required this.nick,
    this.offlineMode = false,
  });

  final String nick;
  final bool offlineMode;

  @override
  State<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends State<SoloGameScreen> {
  late SoloGame _game;
  bool _showRoleReveal = true;
  String? _bannerPhaseOverride;

  @override
  void initState() {
    super.initState();
    _game = SoloGame(humanNick: widget.nick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoNight();
    });
  }

  String get _visualPhase {
    if (_bannerPhaseOverride != null) return _bannerPhaseOverride!;
    final s = _game.state;
    if (s.phase == SoloPhase.gameOver) return 'gameOver';
    if (s.phase == SoloPhase.dayVote) return 'dayVote';
    return 'night';
  }

  void _maybeAutoNight() {
    final before = _game.state.phase;
    _game.autoNightIfNeeded();
    if (_game.state.phase != before && mounted) setState(() {});
  }

  void _flashDawnThenDay() {
    setState(() => _bannerPhaseOverride = GamePhaseUi.phaseAfterNightKill());
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _bannerPhaseOverride = null);
    });
  }

  void _onNightKill(int id) {
    setState(() {
      _game.nightKill(id);
      _game.autoNightIfNeeded();
    });
    _flashDawnThenDay();
  }

  void _onDayVote(int id) {
    setState(() {
      _game.dayVote(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = _game.state;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.soloTitle),
            if (widget.offlineMode)
              Text(
                l10n.offlineModeBanner,
                style: const TextStyle(fontSize: 11, color: Colors.amber),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedGameBackground(
            phase: _visualPhase,
            winner: s.winner,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PhaseBanner(
                      phase: _visualPhase,
                      dayNumber: s.dayNumber,
                      lastVictim: s.lastVictimName,
                      winner: s.winner,
                      serverMessage: s.phase == SoloPhase.night
                          ? 'night'
                          : s.phase == SoloPhase.dayVote
                              ? 'day_vote'
                              : s.phase == SoloPhase.gameOver
                                  ? 'game_over'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    if (s.phase == SoloPhase.gameOver) ...[
                      Expanded(
                        child: Center(
                          child: Text(
                            s.winner == 'villager'
                                ? l10n.villagersWin
                                : l10n.vampiresWin,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _game = SoloGame(humanNick: widget.nick)..start();
                            _showRoleReveal = true;
                            _bannerPhaseOverride = null;
                            _maybeAutoNight();
                          });
                        },
                        child: Text(l10n.playAgain),
                      ),
                    ] else ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: s.alivePlayers.length,
                          itemBuilder: (context, index) {
                            final p = s.alivePlayers[index];
                            final humanId = s.human?.id;
                            final canAct = s.phase == SoloPhase.night
                                ? (s.humanIsVampire && !p.isHuman)
                                : (s.phase == SoloPhase.dayVote &&
                                    p.id != humanId);
                            return Card(
                              color: Colors.black.withValues(alpha: 0.35),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: s.humanIsVampire &&
                                          p.role == SoloRole.vampire
                                      ? Colors.red.shade900
                                      : null,
                                  child: Text(
                                    p.name.isNotEmpty ? p.name[0] : '?',
                                  ),
                                ),
                                title: Text(
                                  p.isHuman
                                      ? '${p.name} (${l10n.you})'
                                      : p.name,
                                ),
                                trailing: canAct
                                    ? IconButton(
                                        icon: Icon(
                                          s.phase == SoloPhase.night
                                              ? Icons.nightlight_round
                                              : Icons.how_to_vote,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        onPressed: () {
                                          if (s.phase == SoloPhase.night) {
                                            _onNightKill(p.id);
                                          } else {
                                            _onDayVote(p.id);
                                          }
                                        },
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      if (s.phase == SoloPhase.night && !s.humanIsVampire)
                        Text(
                          l10n.waitingVampire,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if (s.phase == SoloPhase.dayVote)
                        Text(
                          l10n.tapToVote,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_showRoleReveal)
            RoleRevealOverlay(
              roleId: s.human?.role.name,
              isVampire: s.humanIsVampire,
              onFinished: () => setState(() => _showRoleReveal = false),
            ),
        ],
      ),
    );
  }
}
