import 'package:flutter/material.dart';

import '../game/solo_game.dart';
import '../l10n/app_localizations.dart';

class SoloGameScreen extends StatefulWidget {
  const SoloGameScreen({super.key, required this.nick});

  final String nick;

  @override
  State<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends State<SoloGameScreen> {
  late SoloGame _game;

  @override
  void initState() {
    super.initState();
    _game = SoloGame(humanNick: widget.nick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoNight();
    });
  }

  void _maybeAutoNight() {
    final before = _game.state.phase;
    _game.autoNightIfNeeded();
    if (_game.state.phase != before && mounted) setState(() {});
  }

  void _onNightKill(int id) {
    setState(() {
      _game.nightKill(id);
      _game.autoNightIfNeeded();
    });
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
      appBar: AppBar(
        title: Text(l10n.soloTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(
                title: _game.roleRevealForHuman(),
                subtitle: s.message ?? '',
                day: s.dayNumber,
              ),
              const SizedBox(height: 16),
              if (s.phase == SoloPhase.gameOver) ...[
                Expanded(
                  child: Center(
                    child: Text(
                      s.winner == 'villager' ? l10n.villagersWin : l10n.vampiresWin,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _game = SoloGame(humanNick: widget.nick)..start();
                      _maybeAutoNight();
                    });
                  },
                  child: Text(l10n.playAgain),
                ),
              ] else ...[
                Text(
                  s.phase == SoloPhase.night ? l10n.phaseNight : l10n.phaseDay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: s.alivePlayers.length,
                    itemBuilder: (context, index) {
                      final p = s.alivePlayers[index];
                      final humanId = s.human?.id;
                      final canAct = s.phase == SoloPhase.night
                          ? (s.humanIsVampire && !p.isHuman)
                          : (s.phase == SoloPhase.dayVote && p.id != humanId);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(p.name.isNotEmpty ? p.name[0] : '?'),
                          ),
                          title: Text(
                            p.isHuman ? '${p.name} (${l10n.you})' : p.name,
                          ),
                          trailing: canAct
                              ? IconButton(
                                  icon: Icon(
                                    s.phase == SoloPhase.night
                                        ? Icons.nightlight_round
                                        : Icons.how_to_vote,
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.day,
  });

  final String title;
  final String subtitle;
  final int day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('${l10n.dayLabel} $day', style: const TextStyle(color: Colors.white54)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ],
        ),
      ),
    );
  }
}
