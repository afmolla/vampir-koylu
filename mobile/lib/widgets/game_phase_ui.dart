import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class GamePhaseVisual {
  const GamePhaseVisual({
    required this.accent,
    required this.glow,
    required this.icon,
  });

  final Color accent;
  final Color glow;
  final IconData icon;
}

class GamePhaseUi {
  static GamePhaseVisual styleFor(String phase, {String? winner}) {
    switch (phase) {
      case 'dayVote':
        return const GamePhaseVisual(
          accent: Color(0xFFC9A227),
          glow: Color(0xFFFFE082),
          icon: Icons.wb_sunny_rounded,
        );
      case 'dawn':
        return const GamePhaseVisual(
          accent: Color(0xFF5C4A1E),
          glow: Color(0xFFFFCC80),
          icon: Icons.wb_twilight_rounded,
        );
      case 'gameOver':
        if (winner == 'vampire') {
          return const GamePhaseVisual(
            accent: Color(0xFF8B1E2D),
            glow: Color(0xFFFF5252),
            icon: Icons.bloodtype_rounded,
          );
        }
        if (winner == 'fool') {
          return const GamePhaseVisual(
            accent: Color(0xFF6A4C93),
            glow: Color(0xFFE1BEE7),
            icon: Icons.psychology_alt_rounded,
          );
        }
        return const GamePhaseVisual(
          accent: Color(0xFF2E7D52),
          glow: Color(0xFF81C784),
          icon: Icons.emoji_events_rounded,
        );
      case 'lobby':
        return const GamePhaseVisual(
          accent: Color(0xFF4A3F55),
          glow: Color(0xFFB39DDB),
          icon: Icons.meeting_room_rounded,
        );
      case 'night':
      default:
        return const GamePhaseVisual(
          accent: Color(0xFF4A1942),
          glow: Color(0xFFCE93D8),
          icon: Icons.nightlight_round,
        );
    }
  }

  static String phaseLabel(
    AppLocalizations l10n,
    String phase, {
    String? winner,
  }) {
    switch (phase) {
      case 'night':
        return l10n.phaseNight;
      case 'dayVote':
        return l10n.phaseDay;
      case 'dawn':
        return l10n.phaseDawn;
      case 'gameOver':
        if (winner == 'vampire') return l10n.vampiresWin;
        if (winner == 'fool') return l10n.foolWins;
        if (winner == 'villager') return l10n.villagersWin;
        return l10n.phaseGameOver;
      case 'lobby':
        return l10n.roomWaiting;
      default:
        return phase;
    }
  }

  static String? messageHint(
    AppLocalizations l10n, {
    String? serverMessage,
    String? lastVictim,
    bool noKillNight = false,
    String? hunterRevengeNick,
  }) {
    if (hunterRevengeNick != null && hunterRevengeNick.isNotEmpty) {
      return l10n.hunterRevenge(hunterRevengeNick);
    }
    if (noKillNight && (lastVictim == null || lastVictim.isEmpty)) {
      return l10n.noKillNight;
    }
    if (lastVictim != null && lastVictim.isNotEmpty) {
      return l10n.lastVictim(lastVictim);
    }
    switch (serverMessage) {
      case 'day_vote':
        return l10n.phaseHintDayVote;
      case 'night':
        return l10n.phaseHintNight;
      case 'game_over':
        return l10n.phaseGameOver;
      default:
        return serverMessage;
    }
  }

  /// Solo: gece öldürme sonrası kısa şafak fazı gösterimi için.
  static String phaseAfterNightKill() => 'dawn';
}
