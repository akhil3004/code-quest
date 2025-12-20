import 'package:flutter/material.dart';
import '../services/aptitude_progress_service.dart';

class AptitudeLevelsScreen extends StatefulWidget {
  final Map<String, String>? category;
  const AptitudeLevelsScreen({super.key, this.category});
  @override
  State<AptitudeLevelsScreen> createState() => _AptitudeLevelsScreenState();
}

class _AptitudeLevelsScreenState extends State<AptitudeLevelsScreen> {
  final _service = AptitudeProgressService();
  Map<int, bool> _status = {};
  late String _categoryId;
  late String _categoryName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    final cat = (arg is Map<String, String>) ? arg : widget.category;
    if (cat != null) {
      _categoryId = cat['id']!;
      _categoryName = cat['name']!;
      _load();
    }
  }

  Future<void> _load() async {
    final s = await _service.getStatus(_categoryId);
    setState(() => _status = s);
    if (!_status.containsKey(1)) {
      await _service.unlockNext(_categoryId, 0);
      final s2 = await _service.getStatus(_categoryId);
      setState(() => _status = s2);
    }
  }

  bool _isUnlocked(int level) {
    if (level == 1) return true;
    return (_status[level - 1] ?? false) || (_status[level] == false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$_categoryName Levels')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
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
                  ? () => Navigator.pushNamed(context, '/aptitudeQuestions', arguments: {'category': _categoryId, 'level': level})
                  : null,
              child: const Text('Open'),
            ),
          );
        },
      ),
    );
  }
}
