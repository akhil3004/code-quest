import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/debug_question_model.dart';
import '../services/judge_api_service.dart';
import '../services/xp_service.dart';
import '../services/achievement_service.dart';
import '../services/title_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<DebugQuestion> _questions = [];
  int _index = 0;
  final _controller = TextEditingController();
  String? _result;
  bool _running = false;
  int _runs = 0;
  final _achievements = AchievementService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final str = await rootBundle.loadString('assets/data/debug_questions.json');
    final data = jsonDecode(str) as List<dynamic>;
    setState(() {
      _questions = data.map((e) => DebugQuestion.fromJson(e as Map<String, dynamic>)).toList();
      _controller.text = _questions.first.starterCode;
    });
  }

  Future<void> _run() async {
    final q = _questions[_index];
    setState(() {
      _running = true;
      _result = null;
      _runs++;
    });
    try {
      final res = await JudgeApiService.runCode(q.language, _controller.text);
      final output = (res['stdout'] ?? res['compile_output'] ?? res['stderr'] ?? '') as String;
      setState(() => _result = output.trim());
      if (_result == q.expectedOutput.trim()) {
        await context.read<XPService>().addXP(50);
        final firstAttempt = _runs == 1;
        await _achievements.recordDebugSolve(firstAttempt: firstAttempt);
        await AchievementService().recordXPUpdated();
        await TitleService().recalculateTitle();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success! +50 XP')));
      }
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Debugging')), 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.prompt, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Language: ${q.language.toUpperCase()}'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _running ? null : _run, child: _running ? const CircularProgressIndicator() : const Text('Run')),
            const SizedBox(height: 8),
            if (_result != null) Text('Output:\n$_result'),
          ],
        ),
      ),
    );
  }
}
