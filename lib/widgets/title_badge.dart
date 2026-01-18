import 'package:flutter/material.dart';

import '../theme/retro_theme.dart';

class TitleBadge extends StatelessWidget {
  final String title;
  const TitleBadge({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RetroTheme.accent.withValues(alpha: 0.9),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            RetroTheme.accent.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: RetroTheme.accent.withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        title.toUpperCase(),
        style: RetroTheme.hudLabel.copyWith(
          letterSpacing: 2,
        ),
      ),
    );
  }
}
