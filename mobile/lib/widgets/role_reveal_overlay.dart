import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/game_roles.dart';

/// Rol açılışı — fade + scale geçişi (tüm roller).
class RoleRevealOverlay extends StatefulWidget {
  const RoleRevealOverlay({
    super.key,
    this.isVampire = false,
    this.roleId,
    required this.onFinished,
  });

  final bool isVampire;
  final String? roleId;
  final VoidCallback onFinished;

  @override
  State<RoleRevealOverlay> createState() => _RoleRevealOverlayState();
}

class _RoleRevealOverlayState extends State<RoleRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      reverseCurve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (mounted) widget.onFinished();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final meta = roleMeta(widget.roleId ?? (widget.isVampire ? 'vampire' : 'villager'));
    final isV = meta.isEvil;
    final accent = meta.color;
    final glow = isV ? const Color(0xFFFF5252) : const Color(0xFF81C784);

    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.black.withValues(alpha: 0.92),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.45),
                    const Color(0xFF0D0A12),
                  ],
                  radius: 1.2,
                ),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glow.withValues(alpha: 0.55),
                            blurRadius: 48,
                            spreadRadius: 8,
                          ),
                        ],
                        border: Border.all(color: glow, width: 3),
                        gradient: RadialGradient(
                          colors: [
                            accent.withValues(alpha: 0.9),
                            accent.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                      child: Icon(meta.icon, size: 72, color: Colors.white),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      meta.label(locale),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        isV
                            ? l10n.roleRevealVampireHint
                            : l10n.roleRevealVillagerHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
