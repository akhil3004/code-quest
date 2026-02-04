import 'package:flutter/material.dart';

import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/floating_chat_button.dart';

import '../widgets/galaxy_card.dart';

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
        subtitle: 'Aptitude Galaxies',
      ),
      floatingActionButton: const FloatingChatButton(),
      body: StarfieldBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            children: categories
                .map(
                  (c) => GalaxyCard(
                    name: c['name']!,
                    id: c['id']!,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/aptitudeLevels',
                      arguments: c,
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
