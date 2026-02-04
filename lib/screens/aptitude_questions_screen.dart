import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/mcq_model.dart';
import '../services/xp_service.dart';
import '../services/aptitude_progress_service.dart';
import '../services/achievement_service.dart';
import '../services/title_service.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_card.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../theme/star_wars_retro_theme.dart';

class AptitudeQuestionsScreen extends StatefulWidget {
  final String? category;
  final int? level;
  const AptitudeQuestionsScreen({super.key, this.category, this.level});
  @override
  State<AptitudeQuestionsScreen> createState() => _AptitudeQuestionsScreenState();
}

class _AptitudeQuestionsScreenState extends State<AptitudeQuestionsScreen> {
  List<MCQQuestion> _questions = [];
  int _index = 0;
  int? _selected;
  bool _answered = false;
  String? _feedback;
  final _service = AptitudeProgressService();
  final _achievements = AchievementService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final category = args?['category'] as String? ?? widget.category;
    final level = args?['level'] as int? ?? widget.level;
    if (category != null && level != null) {
      _load(category, level);
    }
  }

  Future<void> _load(String category, int level) async {
    try {
      final path = 'assets/data/aptitude/$category/level$level.json';
      final jsonStr = await rootBundle.loadString(path);
      final data = jsonDecode(jsonStr) as List<dynamic>;
      final list = data.map((e) {
        final m = e as Map<String, dynamic>;
        if (m.containsKey('answerIndex') && !m.containsKey('correctIndex')) {
          m['correctIndex'] = m['answerIndex'];
        }
        if (!m.containsKey('id')) {
          m['id'] = 'apt_${category}_l${level}_${_questions.length}';
        }
        return MCQQuestion.fromJson(m);
      }).toList();
      setState(() {
        _questions = list;
        _feedback = _questions.isEmpty ? 'No questions found.' : 'Loaded ${_questions.length} questions.';
      });
    } catch (e) {
      setState(() {
        _questions = [];
        _feedback = 'Failed to load: $e';
      });
    }
  }

  Future<void> _select(int i) async {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      final correct = _questions[_index].correctIndex;
      final isCorrect = i == correct;
      _feedback = isCorrect ? 'Correct! +10 XP' : 'Incorrect';
    });
    if (_selected == _questions[_index].correctIndex) {
      await context.read<XPService>().addXP(10);
      await _achievements.recordAptitudeQuestionCorrect();
      await AchievementService().recordXPUpdated();
    }
  }

  Future<void> _finishIfLast() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final category = args['category'] as String;
    final level = args['level'] as int;
    if (_index == _questions.length - 1) {
      await _service.markComplete(category, level);
      await _service.unlockNext(category, level);
      await _achievements.recordAptitudeLevelComplete(category, level);
      await AchievementService().recordXPUpdated();
      await TitleService().recalculateTitle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Level completed')));
        Navigator.pop(context);
      }
    }
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
        _feedback = null;
      });
    } else {
      _finishIfLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: const GameHudAppBar(
          showBack: true,
          subtitle: 'Aptitude Level',
        ),
        body: StarfieldBackground(
          child: Center(child: Text(_feedback ?? 'Loading...', style: const TextStyle(color: Colors.white))),
        ),
      );
    }
    final q = _questions[_index];
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Aptitude Level',
      ),
      body: StarfieldBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(children: [
              QuestionCard(
                question: q.question,
                options: List.generate(q.options.length, (i) {
                  final isSelected = _selected == i;
                  final isCorrect = i == q.correctIndex;
                  return OptionTile(
                    text: q.options[i],
                    selected: isSelected,
                    correct: isSelected ? isCorrect : false,
                    onTap: () => _select(i),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (_feedback != null)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: 1,
                  child: Text(
                    _feedback!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _feedback!.contains('Correct') ? StarWarsRetroColors.successGreen : StarWarsRetroColors.dangerRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_index + 1}/${_questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StarWarsRetroColors.textSoft),
                  ),
                  ElevatedButton(
                    onPressed: _answered ? _next : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StarWarsRetroColors.primaryNeon,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: Text(_index == _questions.length - 1 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }
}

