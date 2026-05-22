import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Oyun ekranında dönen / nabız atan gradient arka plan.
class AnimatedGameBackground extends StatefulWidget {
  const AnimatedGameBackground({
    super.key,
    required this.phase,
    required this.child,
    this.winner,
  });

  /// night | dayVote | gameOver | lobby
  final String phase;
  final String? winner;
  final Widget child;

  @override
  State<AnimatedGameBackground> createState() => _AnimatedGameBackgroundState();
}

class _AnimatedGameBackgroundState extends State<AnimatedGameBackground>
    with TickerProviderStateMixin {
  late final AnimationController _rotate;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _rotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotate.dispose();
    _pulse.dispose();
    super.dispose();
  }

  List<Color> _colors() {
    if (widget.phase == 'gameOver') {
      if (widget.winner == 'vampire') {
        return const [
          Color(0xFF2A0810),
          Color(0xFF5C1020),
          Color(0xFF1A0508),
        ];
      }
      return const [
        Color(0xFF0A1A12),
        Color(0xFF1A3D2E),
        Color(0xFF0D0A12),
      ];
    }
    if (widget.phase == 'dayVote') {
      return const [
        Color(0xFF1A1408),
        Color(0xFF3D2E10),
        Color(0xFF2A1F0A),
      ];
    }
    return const [
      Color(0xFF120818),
      Color(0xFF2A1020),
      Color(0xFF0A0610),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotate, _pulse]),
      builder: (context, child) {
        final pulse = 0.55 + _pulse.value * 0.45;
        return CustomPaint(
          painter: _SwirlPainter(
            rotation: _rotate.value * 2 * math.pi,
            pulse: pulse,
            colors: _colors(),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SwirlPainter extends CustomPainter {
  _SwirlPainter({
    required this.rotation,
    required this.pulse,
    required this.colors,
  });

  final double rotation;
  final double pulse;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.sin(rotation) * 0.35,
          math.cos(rotation * 0.7) * 0.35,
        ),
        radius: 1.1 * pulse,
        colors: [
          colors[0],
          colors[1].withValues(alpha: 0.85),
          colors[2],
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
    canvas.restore();

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          colors[1].withValues(alpha: 0.22 * pulse),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * (0.3 + 0.1 * math.sin(rotation * 2)),
            size.height * (0.25 + 0.08 * math.cos(rotation * 1.5)),
          ),
          radius: size.shortestSide * 0.55,
        ),
      );
    canvas.drawRect(rect, glow);
  }

  @override
  bool shouldRepaint(covariant _SwirlPainter old) =>
      old.rotation != rotation || old.pulse != pulse || old.colors != colors;
}
