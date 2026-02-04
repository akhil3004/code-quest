import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';

class PlanetLevelTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: _getGradientColors(),
            center: const Alignment(-0.3, -0.3),
            radius: 0.8,
          ),
          boxShadow: [
            if (completed)
              BoxShadow(
                color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            if (unlocked && !completed)
              BoxShadow(
                color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$level',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: unlocked ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (completed) {
      return [
        StarWarsRetroColors.primaryNeon.withValues(alpha: 0.9),
        StarWarsRetroColors.primaryNeon.withValues(alpha: 0.4),
        Colors.black,
      ];
    }
    if (unlocked) {
      return [
        StarWarsRetroColors.accentPurple.withValues(alpha: 0.8),
        StarWarsRetroColors.accentPurple.withValues(alpha: 0.3),
        Colors.black,
      ];
    }
    return [
      Colors.grey.shade800,
      Colors.black,
    ];
  }

  Color _getBorderColor() {
    if (completed) return StarWarsRetroColors.primaryNeon;
    if (unlocked) return StarWarsRetroColors.accentPurple.withValues(alpha: 0.5);
    return Colors.grey.shade800;
  }
}
