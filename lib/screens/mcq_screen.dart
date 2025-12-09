import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/mcq_model.dart';
import '../services/xp_service.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_card.dart';

class McqScreen extends StatefulWidget {
  const McqScreen({super.key});

  @override
  State<McqScreen> createState() => _McqScreenState();
}

class _McqScreenState extends State<McqScreen> {
  List<MCQQuestion> _questions = [];
  int _index = 0;
  int? _selected;
  bool _answered = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final jsonStr = await rootBundle.loadString('assets/data/mcq_data.json');
    final data = jsonDecode(jsonStr) as List<dynamic>;
    setState(() {
      _questions = data.map((e) => MCQQuestion.fromJson(e as Map<String, dynamic>)).toList();
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('MCQ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          if (_feedback != null) Text(_feedback!),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_index + 1}/${_questions.length}')
              ,
              ElevatedButton(onPressed: _answered ? _next : null, child: const Text('Next')),
            ],
          ),
        ]),
      ),
    );
  }
}
