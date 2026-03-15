import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';

class GalaxyCard extends StatefulWidget {
  final String name;
  final VoidCallback onTap;
  final String? id;

  const GalaxyCard({
    super.key,
    required this.name,
    required this.onTap,
    this.id,
  });

  @override
  State<GalaxyCard> createState() => _GalaxyCardState();
}

class _GalaxyCardState extends State<GalaxyCard>
    with TickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _twinkleController;
  late List<_MiniStar> _miniStars;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _miniStars = _generateMiniStars();
  }

  List<_MiniStar> _generateMiniStars() {
    final rng = Random(widget.name.hashCode);
    return List.generate(18, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = 0.15 + rng.nextDouble() * 0.28;
      return _MiniStar(
        angle: angle,
        distFraction: dist,
        radius: 0.8 + rng.nextDouble() * 1.2,
        opacity: 0.4 + rng.nextDouble() * 0.6,
        twinkleOffset: rng.nextDouble() * pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_pulseController, _rotationController, _twinkleController]),
          builder: (context, _) {
            final pulse = _pulseController.value * 0.06;
            final scale = _hovered ? 1.07 + pulse : 1.0 + pulse * 0.5;

            return AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: LayoutBuilder(builder: (context, constraints) {
                final size = constraints.maxWidth.clamp(100.0, 200.0);
                return SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ── Outer glow halo ──────────────────────────────────
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: StarWarsRetroColors.primaryNeon.withValues(
                                  alpha: _hovered ? 0.35 : 0.12),
                              blurRadius: _hovered ? 32 : 18,
                              spreadRadius: _hovered ? 8 : 2,
                            ),
                            BoxShadow(
                              color: StarWarsRetroColors.accentPurple
                                  .withValues(alpha: _hovered ? 0.25 : 0.08),
                              blurRadius: _hovered ? 48 : 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      // ── Rotating nebula sweep ────────────────────────────
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                StarWarsRetroColors.accentPurple
                                    .withValues(alpha: 0.18),
                                StarWarsRetroColors.primaryNeon
                                    .withValues(alpha: 0.08),
                                Colors.transparent,
                                StarWarsRetroColors.accentPurple
                                    .withValues(alpha: 0.14),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Radial gradient core ─────────────────────────────
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              StarWarsRetroColors.accentPurple
                                  .withValues(alpha: _hovered ? 0.30 : 0.15),
                              StarWarsRetroColors.primaryNeon
                                  .withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // ── Mini star dots (custom painter) ─────────────────
                      SizedBox(
                        width: size,
                        height: size,
                        child: CustomPaint(
                          painter: _MiniStarPainter(
                            stars: _miniStars,
                            twinkle: _twinkleController.value,
                            color: StarWarsRetroColors.primaryNeon,
                          ),
                        ),
                      ),

                      // ── Inner ring border ────────────────────────────────
                      Container(
                        width: size * 0.88,
                        height: size * 0.88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StarWarsRetroColors.primaryNeon.withValues(
                                alpha: _hovered ? 0.75 : 0.30),
                            width: _hovered ? 2.0 : 1.5,
                          ),
                        ),
                      ),

                      // ── Outer dashed ring ────────────────────────────────
                      Container(
                        width: size * 0.96,
                        height: size * 0.96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StarWarsRetroColors.accentPurple
                                .withValues(alpha: _hovered ? 0.50 : 0.18),
                            width: 1.0,
                          ),
                        ),
                      ),

                      // ── Label text ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: StarWarsRetroColors.primaryNeon
                                    .withValues(
                                        alpha: _hovered ? 1.0 : 0.85),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: StarWarsRetroColors.primaryNeon
                                        .withValues(
                                            alpha: _hovered ? 0.9 : 0.4),
                                    blurRadius: _hovered ? 12 : 4,
                                  ),
                                  Shadow(
                                    color: StarWarsRetroColors.accentPurple
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _MiniStar {
  final double angle;
  final double distFraction;
  final double radius;
  final double opacity;
  final double twinkleOffset;

  _MiniStar({
    required this.angle,
    required this.distFraction,
    required this.radius,
    required this.opacity,
    required this.twinkleOffset,
  });
}

class _MiniStarPainter extends CustomPainter {
  final List<_MiniStar> stars;
  final double twinkle;
  final Color color;

  const _MiniStarPainter({
    required this.stars,
    required this.twinkle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxDist = size.width / 2 * 0.78;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final dist = star.distFraction * maxDist;
      final dx = cx + cos(star.angle) * dist;
      final dy = cy + sin(star.angle) * dist;
      final alpha =
          star.opacity * (0.5 + 0.5 * sin(twinkle * pi + star.twinkleOffset));
      paint.color = color.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(dx, dy), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniStarPainter old) =>
      old.twinkle != twinkle;
}
