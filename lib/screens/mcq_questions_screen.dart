import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/mcq_model.dart';
import '../services/xp_service.dart';
import '../services/progress_service.dart';
import '../services/achievement_service.dart';
import '../services/title_service.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_card.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../theme/star_wars_retro_theme.dart';

class McqQuestionsScreen extends StatefulWidget {
  final String? subject;
  final int? level;
  const McqQuestionsScreen({super.key, this.subject, this.level});
  @override
  State<McqQuestionsScreen> createState() => _McqQuestionsScreenState();
}

class _McqQuestionsScreenState extends State<McqQuestionsScreen> {
  List<MCQQuestion> _questions = [];
  int _index = 0;
  int? _selected;
  bool _answered = false;
  String? _feedback;
  int _correctCount = 0;
  final _progress = ProgressService();
  final _achievements = AchievementService();
  final Set<String> _awardedQuestions = {};
  String? _subjectId;
  int? _levelNumber;
  bool _levelAlreadyCompleted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final subject = args?['subject'] as String? ?? widget.subject;
    final level = args?['level'] as int? ?? widget.level;
    if (subject != null && level != null) {
      _load(subject, level);
    }
  }

  Future<void> _load(String subject, int level) async {
    try {
      _subjectId = subject;
      _levelNumber = level;
      final path = 'assets/data/mcq/$subject/level$level.json';
      final jsonStr = await rootBundle.loadString(path);
      final data = jsonDecode(jsonStr) as List<dynamic>;
      final list = data.map((e) => MCQQuestion.fromJson(e as Map<String, dynamic>)).toList();
      final status = await _progress.getCompletionStatus(subject);
      _levelAlreadyCompleted = (status[level] ?? false) == true;
      setState(() {
        _questions = list;
        if (_questions.isEmpty) {
          _feedback = 'No questions found for this level.';
        } else {
          _feedback = 'Loaded ${_questions.length} questions.';
        }
      });
    } catch (e) {
      setState(() {
        _questions = [];
        _feedback = 'Failed to load questions: $e';
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
      final qid = _questions[_index].id;
      if (_levelAlreadyCompleted) {
        return;
      }
      if (_awardedQuestions.contains(qid)) {
        return;
      }
      _awardedQuestions.add(qid);
      await context.read<XPService>().addXP(10);
      _correctCount++;
      await _achievements.recordMcqCorrect();
      await AchievementService().recordXPUpdated();
    }
  }

  Future<void> _finishIfLast() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final subject = args['subject'] as String;
    final level = args['level'] as int;
    if (_index == _questions.length - 1) {
      await _progress.markLevelComplete(subject, level);
      await _progress.unlockNextLevel(subject, level);
      final perfect = _correctCount == _questions.length && _questions.isNotEmpty;
      await _achievements.recordMcqLevelComplete(subject, level, perfect: perfect);
      await AchievementService().recordXPUpdated();
      await TitleService().recalculateTitle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Level completed! Next level unlocked.')));
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
          subtitle: 'MCQ Level',
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
        subtitle: 'MCQ Level',
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
