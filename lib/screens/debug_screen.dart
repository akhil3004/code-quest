import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/debug_question_model.dart';
import '../services/judge0_service.dart';
import '../services/xp_service.dart';
import '../services/achievement_service.dart';
import '../services/title_service.dart';
import '../theme/retro_theme.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/debug_console.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<DebugQuestion> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final str = await rootBundle.loadString('assets/data/debug_questions.json');
      final data = jsonDecode(str) as List<dynamic>;
      setState(() {
        _questions = data.map((e) => DebugQuestion.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Debug Console',
      ),
      body: StarfieldBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: RetroTheme.primary.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          RetroTheme.primary.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RetroTheme.primary.withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        q.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Language: ${q.language.toUpperCase()}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Difficulty: ${q.difficulty}/5',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'XP: ${q.xp}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: RetroTheme.primary),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: RetroTheme.primary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DebugEditorScreen(question: q),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class DebugEditorScreen extends StatefulWidget {
  final DebugQuestion question;
  const DebugEditorScreen({super.key, required this.question});

  @override
  State<DebugEditorScreen> createState() => _DebugEditorScreenState();
}

class _DebugEditorScreenState extends State<DebugEditorScreen> {
  late TextEditingController _controller;
  final _judgeService = Judge0Service();
  final _achievements = AchievementService();
  
  bool _isRunning = false;
  int _runs = 0;
  String? _stdout;
  String? _stderr;
  String? _status;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question.starterCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _isRunning = true;
      _runs++;
      _stdout = null;
      _stderr = null;
      _status = 'Running...';
    });

    try {
      bool allPassed = true;
      String outputLog = '';

      for (var testCase in widget.question.testCases) {
        final result = await _judgeService.submitCode(
          language: widget.question.language,
          sourceCode: _controller.text,
          stdin: testCase.input,
          expectedOutput: testCase.output,
        );

        final stdout = result['stdout'] as String? ?? '';
        final stderr = result['stderr'] as String? ?? '';
        final statusDesc = result['status']['description'] as String? ?? 'Unknown';

        // outputLog += 'Input: ${testCase.input}\nOutput: $stdout\nExpected: ${testCase.output}\n';

        if (statusDesc != 'Accepted' || stdout.trim() != testCase.output.trim()) {
          allPassed = false;
          _stderr = 'Test Failed:\nInput: ${testCase.input}\nExpected: ${testCase.output}\nGot: $stdout\nError: $stderr';
          break;
        } else {
           outputLog += 'Test Passed: Input "${testCase.input}" -> Output "$stdout"\n';
        }
      }

      if (allPassed) {
        _stdout = 'All Test Cases Passed!\n\n$outputLog';
        _status = 'Success';
        await _handleSuccess();
      } else {
        _status = 'Failed';
      }
    } catch (e) {
      _stderr = 'Error: $e';
      _status = 'Error';
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _handleSuccess() async {
    await context.read<XPService>().addXP(widget.question.xp);
    await _achievements.recordDebugSolve(firstAttempt: _runs == 1);
    await AchievementService().recordXPUpdated();
    await TitleService().recalculateTitle();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge Solved! +XP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameHudAppBar(
        showBack: true,
        subtitle: widget.question.title,
      ),
      body: StarfieldBackground(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question.problem,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: CodeEditorWidget(
                        controller: _controller,
                        language: widget.question.language,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DebugConsole(
              stdout: _stdout,
              stderr: _stderr,
              status: _status,
              isRunning: _isRunning,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRunning ? null : _run,
                  child: _isRunning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('RUN CODE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
