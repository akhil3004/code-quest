import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/xp_service.dart';
import '../theme/retro_theme.dart';

class GameHudAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? subtitle;

  const GameHudAppBar({
    super.key,
    this.showBack = false,
    this.subtitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final xpService = context.watch<XPService>();

    return AppBar(
      automaticallyImplyLeading: showBack,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CODE QUEST',
                style: Theme.of(context).textTheme.displaySmall ??
                    RetroTheme.titlePixel,
              ),
              const SizedBox(height: 6),
              Container(
                height: 3,
                width: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      RetroTheme.primary,
                      RetroTheme.accent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RetroTheme.primary.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: RetroTheme.hudLabel,
                ),
              ],
            ],
          ),
          const Spacer(),
          _HudIconButton(
            icon: Icons.leaderboard,
            onTap: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          const SizedBox(width: 12),
          _HudIconButton(
            icon: Icons.person,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 16),
          _XPBadge(
            level: xpService.level,
            xp: xpService.xp,
            onLogoutTap: () =>
                AuthService().signOut().then((_) => Navigator.pushReplacementNamed(context, '/login')),
          ),
        ],
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HudIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: RetroTheme.primary.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: RetroTheme.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              RetroTheme.primary.withValues(alpha: 0.18),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: RetroTheme.primary,
        ),
      ),
    );
  }
}

class _XPBadge extends StatelessWidget {
  final int level;
  final int xp;
  final VoidCallback onLogoutTap;

  const _XPBadge({
    required this.level,
    required this.xp,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final current = xp % 100;
    final progress = current / 100.0;

    return InkWell(
      onTap: onLogoutTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: RetroTheme.gold.withValues(alpha: 0.9),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: [
              RetroTheme.gold.withValues(alpha: 0.25),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: RetroTheme.gold.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 18,
              color: RetroTheme.gold,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LV $level',
                  style: RetroTheme.hudLabel.copyWith(
                    color: RetroTheme.gold,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.6),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        RetroTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

