import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

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
        subtitle: 'MCQ Sectors',
      ),
      body: StarfieldBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: subjects
                .map(
                  (s) => _SubjectCard(
                    subject: s,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/mcqLevels',
        arguments: subject,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: RetroTheme.primary.withValues(alpha: 0.8),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: [
              RetroTheme.primary.withValues(alpha: 0.22),
              RetroTheme.accent.withValues(alpha: 0.16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: RetroTheme.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            subject.name,
            textAlign: TextAlign.center,
            style: RetroTheme.bodyMono.copyWith(
              fontSize: 13,
              color: RetroTheme.background,
            ),
          ),
        ),
      ),
    );
  }
}
