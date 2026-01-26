import 'package:flutter/material.dart';

import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/floating_chat_button.dart';

class AptitudeCategoriesScreen extends StatelessWidget {
  const AptitudeCategoriesScreen({super.key});

  List<Map<String, String>> get categories => const [
        {'id': 'quantitative', 'name': 'Quantitative Aptitude'},
        {'id': 'logical', 'name': 'Logical Reasoning'},
        {'id': 'verbal', 'name': 'Verbal Ability'},
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Aptitude Zones',
      ),
      floatingActionButton: const FloatingChatButton(),
      body: StarfieldBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: categories
                .map(
                  (c) => _AptitudeCategoryTile(category: c),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _AptitudeCategoryTile extends StatefulWidget {
  final Map<String, String> category;

  const _AptitudeCategoryTile({required this.category});

  @override
  State<_AptitudeCategoryTile> createState() => _AptitudeCategoryTileState();
}

class _AptitudeCategoryTileState extends State<_AptitudeCategoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/aptitudeLevels',
            arguments: widget.category,
          ),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: RetroTheme.accent.withValues(alpha: _hovered ? 0.9 : 0.6),
                width: 1.3,
              ),
              gradient: LinearGradient(
                colors: [
                  RetroTheme.accent.withValues(alpha: _hovered ? 0.24 : 0.16),
                  RetroTheme.primary.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: RetroTheme.accent.withValues(alpha: _hovered ? 0.35 : 0.2),
                  blurRadius: _hovered ? 14 : 8,
                  spreadRadius: 0.8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.category['name']!,
                textAlign: TextAlign.center,
                style: RetroTheme.bodyMono.copyWith(
                  fontSize: 12,
                  color: RetroTheme.background,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
