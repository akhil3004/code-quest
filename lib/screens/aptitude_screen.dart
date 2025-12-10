import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/aptitude_model.dart';
import '../services/xp_service.dart';

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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+20 XP')));
  }

  @override
  Widget build(BuildContext context) {
    if (_topics.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Aptitude')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final t = _topics[index];
          return ExpansionTile(
            title: Text(t.topic),
            children: [
              ...t.questions.map((q) => ListTile(title: Text(q.question), subtitle: Text(q.answer))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: _completeTopic, child: const Text('Mark Completed (+20 XP)')),
              ),
            ],
          );
        },
      ),
    );
  }
}
