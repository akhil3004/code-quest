import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/progress_service.dart';

class McqLevelsScreen extends StatefulWidget {
  final SubjectModel? subject;
  const McqLevelsScreen({super.key, this.subject});
  @override
  State<McqLevelsScreen> createState() => _McqLevelsScreenState();
}

class _McqLevelsScreenState extends State<McqLevelsScreen> {
  final _progress = ProgressService();
  Map<int, bool> _status = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    final subject = (arg is SubjectModel) ? arg : widget.subject;
    if (subject != null) {
      _load(subject.id);
    }
  }

  Future<void> _load(String subjectId) async {
    final s = await _progress.getCompletionStatus(subjectId);
    setState(() => _status = s);
    if (!_status.containsKey(1)) {
      await _progress.unlockNextLevel(subjectId, 0);
      final s2 = await _progress.getCompletionStatus(subjectId);
      setState(() => _status = s2);
    }
  }

  bool _isUnlocked(int level) {
    if (level == 1) return true;
    return (_status[level - 1] ?? false) || (_status[level] == false);
  }

  @override
  Widget build(BuildContext context) {
    final subject = ModalRoute.of(context)!.settings.arguments as SubjectModel;
    return Scaffold(
      appBar: AppBar(title: Text('${subject.name} Levels')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final level = index + 1;
          final completed = _status[level] ?? false;
          final unlocked = _isUnlocked(level);
          return ListTile(
            title: Text('Level $level'),
            subtitle: Text(completed ? 'Completed' : unlocked ? 'Unlocked' : 'Locked'),
            trailing: ElevatedButton(
              onPressed: unlocked
                  ? () => Navigator.pushNamed(context, '/mcqQuestions', arguments: {'subject': subject.id, 'level': level})
                  : null,
              child: const Text('Open'),
            ),
          );
        },
      ),
    );
  }
}
