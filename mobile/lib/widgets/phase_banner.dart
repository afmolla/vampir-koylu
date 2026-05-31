import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'game_phase_ui.dart';

/// Üstte animasyonlu faz bandı (gece / şafak / gündüz / oyun bitti).
class PhaseBanner extends StatelessWidget {
  const PhaseBanner({
    super.key,
    required this.phase,
    this.dayNumber = 1,
    this.lastVictim,
    this.winner,
    this.serverMessage,
    this.noKillNight = false,
    this.hunterRevengeNick,
  });

  final String phase;
  final int dayNumber;
  final String? lastVictim;
  final String? winner;
  final String? serverMessage;
  final bool noKillNight;
  final String? hunterRevengeNick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = GamePhaseUi.styleFor(phase, winner: winner);
    final label = GamePhaseUi.phaseLabel(l10n, phase, winner: winner);
    final hint = GamePhaseUi.messageHint(
      l10n,
      serverMessage: serverMessage,
      lastVictim: lastVictim,
      noKillNight: noKillNight,
      hunterRevengeNick: hunterRevengeNick,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey('$phase-$dayNumber-$hint'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              style.accent.withValues(alpha: 0.35),
              style.accent.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(color: style.accent.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: style.glow.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(style.icon, color: style.glow, size: 26),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.dayLabel} $dayNumber',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
            if (hint != null && hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
