import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/xp_service.dart';
import '../widgets/title_badge.dart';
import '../widgets/xp_progress_bar.dart';
import '../services/achievement_service.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<XPService>().load();
      AchievementService().recordXPUpdated();
    });
  }

  @override
  Widget build(BuildContext context) {
    final xpService = context.watch<XPService>();
    return Scaffold(
      appBar: const GameHudAppBar(),
      body: StarfieldBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleBadge(title: xpService.title),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 14),
                    XPProgressBar(xp: xpService.xp),
                    const SizedBox(height: 32),
                    Expanded(
                      child: _HomeMenu(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMenu extends StatefulWidget {
  @override
  State<_HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<_HomeMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItemData(
        label: 'MCQ Subjects',
        icon: Icons.quiz,
        onTap: () {
          AchievementService().recordScreenOpen();
          Navigator.pushNamed(context, '/mcqSubjects');
        },
      ),
      _MenuItemData(
        label: 'Debug Console',
        icon: Icons.terminal,
        onTap: () {
          AchievementService().recordScreenOpen();
          Navigator.pushNamed(context, '/debug');
        },
      ),
      _MenuItemData(
        label: 'Aptitude',
        icon: Icons.auto_graph,
        onTap: () {
          AchievementService().recordScreenOpen();
          Navigator.pushNamed(context, '/aptitudeCategories');
        },
      ),
      _MenuItemData(
        label: 'Interview PDFs',
        icon: Icons.menu_book,
        onTap: () {
          AchievementService().recordScreenOpen();
          Navigator.pushNamed(context, '/interviewPdfs');
        },
      ),
      _MenuItemData(
        label: 'Achievements',
        icon: Icons.emoji_events,
        onTap: () {
          Navigator.pushNamed(context, '/achievements');
        },
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MISSIONS',
          style: RetroTheme.hudLabel.copyWith(
            color: RetroTheme.accent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(items.length, (index) {
          final item = items[index];
          final startInterval = 0.1 * index;
          final endInterval = startInterval + 0.5;
          final curved = CurvedAnimation(
            parent: _controller,
            curve: Interval(startInterval, endInterval.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
          );
          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final value = curved.value;
              final offset = 40 * (1 - value);
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(-offset, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: child,
                  ),
                ),
              );
            },
            child: _HomeMenuButton(
              label: item.label,
              icon: item.icon,
              onTap: item.onTap,
            ),
          );
        }),
      ],
    );
  }
}

class _MenuItemData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _MenuItemData({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _HomeMenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeMenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HomeMenuButton> createState() => _HomeMenuButtonState();
}

class _HomeMenuButtonState extends State<_HomeMenuButton> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHover(bool value) {
    if (!mounted) return;
    setState(() {
      _hovered = value;
    });
  }

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : (_hovered ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: RetroTheme.primary.withValues(alpha: 0.9),
                width: 2,
              ),
              gradient: LinearGradient(
                colors: [
                  RetroTheme.primary.withValues(alpha: 0.3),
                  RetroTheme.accent.withValues(alpha: 0.15),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: RetroTheme.primary.withValues(alpha: _hovered ? 0.7 : 0.35),
                  blurRadius: _hovered ? 20 : 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(widget.icon, color: RetroTheme.background, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: RetroTheme.bodyMono.copyWith(
                      fontSize: 13,
                      color: RetroTheme.background,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
