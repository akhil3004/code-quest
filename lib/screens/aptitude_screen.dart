import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/aptitude_model.dart';
import '../services/xp_service.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

class AptitudeScreen extends StatefulWidget {
  const AptitudeScreen({super.key});
  @override
  State<AptitudeScreen> createState() => _AptitudeScreenState();
}

class _AptitudeScreenState extends State<AptitudeScreen> {
  List<AptitudeTopic> _topics = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final str = await rootBundle.loadString('assets/data/aptitude_questions.json');
    final data = jsonDecode(str) as List<dynamic>;
    setState(() {
      _topics = data.map((e) => AptitudeTopic.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> _completeTopic() async {
    await context.read<XPService>().addXP(20);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('+20 XP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_topics.isEmpty) {
      return const Scaffold(
        appBar: GameHudAppBar(
          showBack: true,
          subtitle: 'Aptitude Briefing',
        ),
        body: StarfieldBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Aptitude Briefing',
      ),
      body: StarfieldBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _topics.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = _topics[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: RetroTheme.primary.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  colors: [
                    RetroTheme.primary.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: RetroTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    t.topic,
                    style: RetroTheme.bodyMono.copyWith(
                      fontSize: 14,
                      color: RetroTheme.background,
                    ),
                  ),
                  children: [
                    ...t.questions.map(
                      (q) => ListTile(
                        title: Text(
                          q.question,
                          style: RetroTheme.bodyMono.copyWith(fontSize: 12),
                        ),
                        subtitle: Text(
                          q.answer,
                          style: RetroTheme.bodyMono.copyWith(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _completeTopic,
                          child: const Text('Mark Completed (+20 XP)'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
