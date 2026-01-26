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
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final xpService = context.watch<XPService>();

    return AppBar(
      automaticallyImplyLeading: showBack,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 56,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CODE QUEST',
                style: RetroTheme.titlePixel.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      RetroTheme.primary,
                      RetroTheme.accent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RetroTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
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
          const SizedBox(width: 10),
          _HudIconButton(
            icon: Icons.person,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 10),
          _XPBadge(
            level: xpService.level,
            xp: xpService.xp,
          ),
          const SizedBox(width: 6),
          _HudIconButton(
            icon: Icons.logout,
            onTap: () async {
              final navigator = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    backgroundColor: RetroTheme.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: RetroTheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    title: Text(
                      'Log out?',
                      style: RetroTheme.bodyMono.copyWith(
                        fontSize: 14,
                        color: RetroTheme.text,
                      ),
                    ),
                    content: Text(
                      'Your progress is saved. Exit the mission?',
                      style: RetroTheme.bodyMono.copyWith(
                        fontSize: 12,
                        color: RetroTheme.text.withValues(alpha: 0.8),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => navigator.pop(false),
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        onPressed: () => navigator.pop(true),
                        child: const Text('LOGOUT'),
                      ),
                    ],
                  );
                },
              );
              if (confirm == true) {
                await AuthService().signOut();
                navigator.pushReplacementNamed('/login');
              }
            },
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

  const _XPBadge({
    required this.level,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final current = xp % 100;
    final progress = current / 100.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RetroTheme.gold.withValues(alpha: 0.8),
          width: 1.3,
        ),
        gradient: LinearGradient(
          colors: [
            RetroTheme.gold.withValues(alpha: 0.22),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: RetroTheme.gold.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 0.5,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      RetroTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
