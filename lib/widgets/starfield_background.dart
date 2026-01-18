import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/retro_theme.dart';

class StarfieldBackground extends StatefulWidget {
  final Widget child;

  const StarfieldBackground({super.key, required this.child});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _stars = _generateStars();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Star> _generateStars() {
    const smallCount = 60;
    const mediumCount = 30;
    const glowCount = 12;

    final random = Random(42);
    final stars = <_Star>[];

    for (var i = 0; i < smallCount; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 0.6 + 0.4,
          speed: 0.06 + random.nextDouble() * 0.04,
          twinkleOffset: random.nextDouble() * pi * 2,
          layer: 0,
        ),
      );
    }

    for (var i = 0; i < mediumCount; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 0.8 + 0.7,
          speed: 0.08 + random.nextDouble() * 0.05,
          twinkleOffset: random.nextDouble() * pi * 2,
          layer: 1,
        ),
      );
    }

    for (var i = 0; i < glowCount; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 1.6 + 1.2,
          speed: 0.11 + random.nextDouble() * 0.05,
          twinkleOffset: random.nextDouble() * pi * 2,
          layer: 2,
        ),
      );
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF050711),
                RetroTheme.background,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _StarfieldPainter(
              stars: _stars,
              time: _controller.value,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.04),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double twinkleOffset;
  final int layer;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.twinkleOffset,
    required this.layer,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;

  const _StarfieldPainter({
    required this.stars,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const gridSpacing = 32.0;
    for (var x = 0.0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final starPaint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final layerSpeedMultiplier = 1.0 + star.layer * 0.4;
      final dy = (star.y + time * star.speed * layerSpeedMultiplier) % 1.0;
      final dx = (star.x + time * star.speed * 0.2 * layerSpeedMultiplier) % 1.0;

      final position = Offset(dx * size.width, dy * size.height);

      final twinkle = 0.6 + 0.4 * (0.5 + 0.5 * sin(time * 2 * pi + star.twinkleOffset));
      final baseColor = star.layer == 2
          ? RetroTheme.primary
          : Colors.white.withValues(alpha: star.layer == 1 ? 0.9 : 0.7);

      starPaint.color = baseColor.withValues(alpha: baseColor.a / 255 * twinkle);

      canvas.drawCircle(position, star.radius * twinkle, starPaint);

      if (star.layer == 2) {
        final glowPaint = Paint()
          ..color = RetroTheme.accent.withValues(alpha: 0.4 * twinkle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(position, star.radius * 3, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.stars != stars;
  }
}

