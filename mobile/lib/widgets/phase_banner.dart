import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'game_phase_ui.dart';

/// Üstte animasyonlu faz bandı (gece / şafak / gündüz / oyun bitti).
class PhaseBanner extends StatefulWidget {
  const PhaseBanner({
    super.key,
    required this.phase,
    this.dayNumber = 1,
    this.lastVictim,
    this.winner,
    this.serverMessage,
    this.noKillNight = false,
    this.hunterRevengeNick,
    this.phaseEndsAt,
  });

  final String phase;
  final int dayNumber;
  final String? lastVictim;
  final String? winner;
  final String? serverMessage;
  final bool noKillNight;
  final String? hunterRevengeNick;
  final int? phaseEndsAt;

  @override
  State<PhaseBanner> createState() => _PhaseBannerState();
}

class _PhaseBannerState extends State<PhaseBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  int? get _secondsLeft {
    final end = widget.phaseEndsAt;
    if (end == null) return null;
    final left =
        ((end - DateTime.now().millisecondsSinceEpoch) / 1000).ceil();
    return left > 0 ? left : 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = GamePhaseUi.styleFor(widget.phase, winner: widget.winner);
    final label =
        GamePhaseUi.phaseLabel(l10n, widget.phase, winner: widget.winner);
    final hint = GamePhaseUi.messageHint(
      l10n,
      serverMessage: widget.serverMessage,
      lastVictim: widget.lastVictim,
      noKillNight: widget.noKillNight,
      hunterRevengeNick: widget.hunterRevengeNick,
    );
    final secs = _secondsLeft;

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
        key: ValueKey('${widget.phase}-${widget.dayNumber}-$hint-$secs'),
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
              '${l10n.dayLabel} ${widget.dayNumber}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
            if (secs != null) ...[
              const SizedBox(height: 6),
              Text(
                '⏱ ${secs}s',
                style: TextStyle(
                  color: secs <= 15
                      ? Colors.orangeAccent
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
