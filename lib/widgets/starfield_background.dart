import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/retro_theme.dart';

class StarfieldBackground extends StatefulWidget {
  final Widget child;
  final double speedMultiplier;

  const StarfieldBackground({
    super.key,
    required this.child,
    this.speedMultiplier = 1.0,
  });

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground> {
  late final Ticker _ticker;
  late final List<_Star> _stars;

  // Always-increasing wall-clock seconds — NEVER resets, no jump ever.
  double _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _stars = _generateStars();

    // Ticker fires every frame, giving us a monotonically-increasing elapsed.
    // Because _elapsedSeconds only goes UP, (y + elapsed*speed) % 1.0 is
    // always smooth — no discontinuity, no cut, ever.
    _ticker = Ticker((elapsed) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds = elapsed.inMicroseconds / 1e6;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<_Star> _generateStars() {
    const smallCount  = 70;
    const mediumCount = 35;
    const glowCount   = 15;

    final rng   = Random(42);
    final stars = <_Star>[];

    for (var i = 0; i < smallCount; i++) {
      stars.add(_Star(
        x:             rng.nextDouble(),
        y:             rng.nextDouble(),   // staggered so screen is full from frame 0
        radius:        rng.nextDouble() * 0.6 + 0.4,
        speed:         0.022 + rng.nextDouble() * 0.018,
        twinkleOffset: rng.nextDouble() * pi * 2,
        layer:         0,
      ));
    }

    for (var i = 0; i < mediumCount; i++) {
      stars.add(_Star(
        x:             rng.nextDouble(),
        y:             rng.nextDouble(),
        radius:        rng.nextDouble() * 0.8 + 0.7,
        speed:         0.030 + rng.nextDouble() * 0.022,
        twinkleOffset: rng.nextDouble() * pi * 2,
        layer:         1,
      ));
    }

    for (var i = 0; i < glowCount; i++) {
      stars.add(_Star(
        x:             rng.nextDouble(),
        y:             rng.nextDouble(),
        radius:        rng.nextDouble() * 1.6 + 1.2,
        speed:         0.040 + rng.nextDouble() * 0.020,
        twinkleOffset: rng.nextDouble() * pi * 2,
        layer:         2,
      ));
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Color(0xFF050711), RetroTheme.background],
        ),
      ),
      child: CustomPaint(
        painter: _StarfieldPainter(
          stars:            _stars,
          elapsedSeconds:   _elapsedSeconds,
          speedMultiplier:  widget.speedMultiplier,
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
              end:   Alignment.bottomCenter,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Star {
  final double x;
  final double y;
  final double radius;
  final double speed;         // fraction of screen per second
  final double twinkleOffset;
  final int    layer;

  const _Star({
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
  final double      elapsedSeconds;
  final double      speedMultiplier;

  const _StarfieldPainter({
    required this.stars,
    required this.elapsedSeconds,
    required this.speedMultiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle grid
    final gridPaint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.4;
    const gridSpacing = 40.0;
    for (var x = 0.0; x < size.width;  x += gridSpacing)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    for (var y = 0.0; y < size.height; y += gridSpacing)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

    final starPaint  = Paint()..style = PaintingStyle.fill;
    final isHyper    = speedMultiplier > 2.0;

    for (final star in stars) {
      // Deeper layers fall faster (parallax)
      final layerMult   = 1.0 + star.layer * 0.5;
      final effectiveSpd = star.speed * layerMult * speedMultiplier;

      // ── THE KEY: elapsedSeconds NEVER resets → dy is always continuous ──
      final dy = (star.y + elapsedSeconds * effectiveSpd) % 1.0;
      final pos = Offset(star.x * size.width, dy * size.height);

      // Gentle twinkle using wall-clock time (also continuous)
      final twinkle = 0.55 + 0.45 * sin(elapsedSeconds * 2.5 + star.twinkleOffset).abs();

      final baseColor = star.layer == 2
          ? RetroTheme.primary
          : Colors.white.withValues(alpha: star.layer == 1 ? 0.85 : 0.65);

      starPaint.color = baseColor.withValues(
        alpha: (baseColor.a / 255) * twinkle,
      );

      if (isHyper) {
        final streakLen = 18.0 * speedMultiplier * star.radius;
        final endPos    = Offset(pos.dx, pos.dy - streakLen);
        if (endPos.dy < 0) {
          canvas.drawLine(
            Offset(pos.dx, size.height + pos.dy),
            Offset(pos.dx, size.height + pos.dy - streakLen),
            starPaint..strokeWidth = star.radius,
          );
        }
        canvas.drawLine(pos, endPos, starPaint..strokeWidth = star.radius);
      } else {
        canvas.drawCircle(pos, star.radius * twinkle, starPaint);
        if (star.layer == 2) {
          canvas.drawCircle(
            pos,
            star.radius * 3.5,
            Paint()
              ..color      = RetroTheme.accent.withValues(alpha: 0.30 * twinkle)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) =>
      old.elapsedSeconds != elapsedSeconds;
}
