import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';

class PlanetLevelTile extends StatefulWidget {
  final int level;
  final bool completed;
  final bool unlocked;
  final VoidCallback? onTap;

  const PlanetLevelTile({
    super.key,
    required this.level,
    required this.completed,
    required this.unlocked,
    required this.onTap,
  });

  @override
  State<PlanetLevelTile> createState() => _PlanetLevelTileState();
}

class _PlanetLevelTileState extends State<PlanetLevelTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered && widget.unlocked ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Halo for Unlocked
              if (widget.unlocked && !widget.completed)
                RotationTransition(
                  turns: _controller,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
                          StarWarsRetroColors.accentPurple.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

              // Completed Glow Ring
              if (widget.completed)
                 Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: StarWarsRetroColors.primaryNeon.withValues(alpha: _hovered ? 0.6 : 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                 ),

              // Main Planet Body
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _getGradientColors(),
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.8,
                  ),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: widget.completed ? 2 : 1,
                  ),
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Noise for Locked
                      if (!widget.unlocked)
                        CustomPaint(
                          painter: _NoisePainter(),
                          size: const Size(80, 80),
                        ),
                      
                      // Shimmer for Completed
                      if (widget.completed)
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    _controller.value - 0.2,
                                    _controller.value,
                                    _controller.value + 0.2,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      Center(
                        child: Text(
                          '${widget.level}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: widget.unlocked ? Colors.white : Colors.white38,
                                fontWeight: FontWeight.bold,
                                shadows: widget.unlocked ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  )
                                ] : null,
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
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (widget.completed) {
      return [
        StarWarsRetroColors.primaryNeon.withValues(alpha: 0.8),
        StarWarsRetroColors.primaryNeon.withValues(alpha: 0.3),
        Colors.black,
      ];
    }
    if (widget.unlocked) {
      return [
        StarWarsRetroColors.accentPurple.withValues(alpha: 0.7),
        StarWarsRetroColors.accentPurple.withValues(alpha: 0.2),
        Colors.black,
      ];
    }
    return [
      Colors.grey.shade800,
      Colors.black,
    ];
  }

  Color _getBorderColor() {
    if (widget.completed) return StarWarsRetroColors.primaryNeon;
    if (widget.unlocked) return StarWarsRetroColors.accentPurple.withValues(alpha: 0.5);
    return Colors.grey.shade800;
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.1);
    final random = Random(42);
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
