import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/progress_service.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

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
      appBar: GameHudAppBar(
        showBack: true,
        subtitle: '${subject.name} Levels',
      ),
      body: StarfieldBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final level = index + 1;
            final completed = _status[level] ?? false;
            final unlocked = _isUnlocked(level);
            return _LevelTile(
              level: level,
              completed: completed,
              unlocked: unlocked,
              onOpen: unlocked
                  ? () => Navigator.pushNamed(
                        context,
                        '/mcqQuestions',
                        arguments: {'subject': subject.id, 'level': level},
                      )
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final bool completed;
  final bool unlocked;
  final VoidCallback? onOpen;

  const _LevelTile({
    required this.level,
    required this.completed,
    required this.unlocked,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !unlocked;
    final statusText = completed
        ? 'Completed'
        : unlocked
            ? 'Unlocked'
            : 'Locked';

    Color borderColor;
    Color glowColor;
    IconData icon;

    if (locked) {
      borderColor = Colors.grey.withValues(alpha: 0.7);
      glowColor = Colors.black;
      icon = Icons.lock;
    } else if (completed) {
      borderColor = RetroTheme.gold;
      glowColor = RetroTheme.gold.withValues(alpha: 0.7);
      icon = Icons.check_circle;
    } else {
      borderColor = RetroTheme.primary;
      glowColor = RetroTheme.primary.withValues(alpha: 0.7);
      icon = Icons.play_arrow;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
        gradient: LinearGradient(
          colors: [
            borderColor.withValues(alpha: 0.25),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: locked ? 0.0 : 0.6),
            blurRadius: locked ? 0 : 16,
            spreadRadius: locked ? 0 : 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  value: completed ? 1 : (unlocked ? 0.5 : 0.0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completed
                        ? RetroTheme.gold
                        : unlocked
                            ? RetroTheme.primary
                            : Colors.grey,
                  ),
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                ),
              ),
              Text(
                level.toString().padLeft(2, '0'),
                style: RetroTheme.bodyMono.copyWith(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $level',
                  style: RetroTheme.bodyMono.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: RetroTheme.bodyMono.copyWith(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: borderColor),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onOpen,
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
