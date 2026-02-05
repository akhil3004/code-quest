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

class _GalaxyCardState extends State<GalaxyCard> with TickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
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
          animation: Listenable.merge([_pulseController, _rotationController]),
          builder: (context, child) {
            final pulse = _pulseController.value * 0.1;
            final scale = _hovered ? 1.05 + pulse : 1.0 + pulse;
            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Rotating Nebula
                   RotationTransition(
                     turns: _rotationController,
                     child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            StarWarsRetroColors.accentPurple.withValues(alpha: 0.1),
                            StarWarsRetroColors.primaryNeon.withValues(alpha: 0.05),
                            Colors.transparent,
                            StarWarsRetroColors.accentPurple.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                     ),
                   ),
                   // Main Pulse Container
                   Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          StarWarsRetroColors.accentPurple.withValues(alpha: 0.2),
                          StarWarsRetroColors.primaryNeon.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.2, 0.6, 1.0],
                      ),
                      boxShadow: [
                        if (_hovered)
                          BoxShadow(
                            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StarWarsRetroColors.primaryNeon.withValues(alpha: _hovered ? 0.8 : 0.2),
                            width: 1.5,
                          ),
                          color: StarWarsRetroColors.background.withValues(alpha: 0.5),
                        ),
                        width: 140,
                        height: 140,
                        child: Center(
                          child: Text(
                            widget.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: StarWarsRetroColors.primaryNeon.withValues(alpha: _hovered ? 1.0 : 0.8),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    if (_hovered)
                                      Shadow(
                                        color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.6),
                                        blurRadius: 4,
                                      ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
