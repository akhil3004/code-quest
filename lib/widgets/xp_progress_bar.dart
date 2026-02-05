import 'package:flutter/material.dart';

import '../theme/star_wars_retro_theme.dart';

class XPProgressBar extends StatelessWidget {
  final int xp;
  const XPProgressBar({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    final current = xp % 100;
    final progress = current / 100.0;
    final level = xp ~/ 100;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.7),
              width: 1.4,
            ),
            gradient: LinearGradient(
              colors: [
                StarWarsRetroColors.primaryNeon.withValues(alpha: 0.16),
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.28),
                blurRadius: 12,
                spreadRadius: 0.8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL $level',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: StarWarsRetroColors.gold,
                    ),
                  ),
                  Text(
                    '$xp XP',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: StarWarsRetroColors.textSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: animatedProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                StarWarsRetroColors.primaryNeon,
                                StarWarsRetroColors.accentPurple,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${100 - current} XP to next level',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: StarWarsRetroColors.textSoft.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
