import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/floating_chat_button.dart';

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
      floatingActionButton: const FloatingChatButton(),
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

class _SubjectCard extends StatefulWidget {
  final SubjectModel subject;

  const _SubjectCard({required this.subject});

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
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
            '/mcqLevels',
            arguments: widget.subject,
          ),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: RetroTheme.primary.withValues(alpha: _hovered ? 0.9 : 0.6),
                width: 1.3,
              ),
              gradient: LinearGradient(
                colors: [
                  RetroTheme.primary.withValues(alpha: _hovered ? 0.24 : 0.16),
                  RetroTheme.accent.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: RetroTheme.primary.withValues(alpha: _hovered ? 0.35 : 0.2),
                  blurRadius: _hovered ? 14 : 8,
                  spreadRadius: 0.8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.subject.name,
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
