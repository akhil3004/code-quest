import 'package:flutter/material.dart';

import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

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
      body: StarfieldBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: categories
                .map(
                  (c) => InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/aptitudeLevels',
                      arguments: c,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: RetroTheme.accent.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            RetroTheme.accent.withValues(alpha: 0.22),
                            RetroTheme.primary.withValues(alpha: 0.16),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: RetroTheme.accent.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          c['name']!,
                          textAlign: TextAlign.center,
                          style: RetroTheme.bodyMono.copyWith(
                            fontSize: 13,
                            color: RetroTheme.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
