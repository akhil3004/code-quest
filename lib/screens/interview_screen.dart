import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/interview_model.dart';
import '../services/xp_service.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  List<InterviewTopic> _topics = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final str = await rootBundle.loadString('assets/data/interview_material.json');
    final data = jsonDecode(str) as List<dynamic>;
    setState(() {
      _topics = data.map((e) => InterviewTopic.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> _completeTopic() async {
    await context.read<XPService>().addXP(50);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+50 XP')));
  }

  @override
  Widget build(BuildContext context) {
    if (_topics.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Q&A')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final t = _topics[index];
          return ExpansionTile(
            title: Text(t.topic),
            children: [
              ...t.items.map((qa) => ListTile(
                    title: Text(qa.question),
                    subtitle: Text(qa.answer),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: _completeTopic, child: const Text('Mark Completed (+50 XP)')),
              ),
            ],
          );
        },
      ),
    );
  }
}
