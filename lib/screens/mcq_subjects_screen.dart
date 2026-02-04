import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/floating_chat_button.dart';
import '../widgets/galaxy_card.dart';

class McqSubjectsScreen extends StatelessWidget {
  const McqSubjectsScreen({super.key});

  List<SubjectModel> get subjects => const [
        SubjectModel(id: 'os', name: 'Operating Systems'),
        SubjectModel(id: 'dbms', name: 'DBMS'),
        SubjectModel(id: 'cn', name: 'Computer Networks'),
        SubjectModel(id: 'oop', name: 'OOP/Java'),
        SubjectModel(id: 'dsa', name: 'DSA'),
        SubjectModel(id: 'cd', name: 'Compiler Design'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'MCQ Galaxies',
      ),
      floatingActionButton: const FloatingChatButton(),
      body: StarfieldBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            children: subjects
                .map(
                  (s) => GalaxyCard(
                    name: s.name,
                    id: s.id,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/mcqLevels',
                      arguments: s,
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
