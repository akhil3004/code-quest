import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/xp_service.dart';
import '../theme/retro_theme.dart';
import '../theme/star_wars_retro_theme.dart';
import 'floating_chat_button.dart';

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
      toolbarHeight: 60,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // ── Brand ────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CODE QUEST',
                  style: RetroTheme.titlePixel.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RetroTheme.primary, RetroTheme.accent],
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
                  const SizedBox(height: 3),
                  Text(subtitle!, style: RetroTheme.hudLabel),
                ],
              ],
            ),

            const Spacer(),

            // ── Nav Dock Pill ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: StarWarsRetroColors.surfaceDark.withValues(alpha: 0.9),
                border: Border.all(
                  color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.15),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Board',
                    onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                  ),
                  _NavDivider(),
                  _NavItem(
                    icon: Icons.public_outlined,
                    label: 'Global',
                    onTap: () => Navigator.pushNamed(context, '/globalChat'),
                  ),
                  _NavDivider(),
                  _NavItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'AI',
                    color: StarWarsRetroColors.accentPurple,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (sheetContext) =>
                            const AiAssistantPanel(screen: 'header'),
                      );
                    },
                  ),
                  _NavDivider(),
                  _NavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── XP Badge ─────────────────────────────────────────────
            _XPBadge(level: xpService.level, xp: xpService.xp),

            const SizedBox(width: 8),

            // ── Logout ───────────────────────────────────────────────
            Tooltip(
              message: 'Logout',
              child: _LogoutButton(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav Item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? StarWarsRetroColors.primaryNeon;
    final iconColor = _hovered
        ? activeColor
        : StarWarsRetroColors.textSoft.withValues(alpha: 0.75);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: _hovered
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  widget.icon,
                  key: ValueKey(_hovered),
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  letterSpacing: 0.8,
                  color: iconColor,
                  fontWeight:
                      _hovered ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Thin divider between nav items ───────────────────────────────────────────
class _NavDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            StarWarsRetroColors.primaryNeon.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final navigator = Navigator.of(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
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
            ),
          );
          if (confirm == true) {
            await AuthService().signOut();
            navigator.pushReplacementNamed('/login');
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? StarWarsRetroColors.dangerRed.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: Icon(
            Icons.logout_rounded,
            size: 20,
            color: _hovered
                ? StarWarsRetroColors.dangerRed
                : StarWarsRetroColors.textSoft.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ── XP Badge ─────────────────────────────────────────────────────────────────
class _XPBadge extends StatelessWidget {
  final int level;
  final int xp;

  const _XPBadge({required this.level, required this.xp});

  @override
  Widget build(BuildContext context) {
    final current = xp % 100;
    final progress = current / 100.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            color: RetroTheme.gold.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: RetroTheme.gold),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LV $level',
                style: RetroTheme.hudLabel.copyWith(color: RetroTheme.gold),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 60,
                height: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
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
