import 'package:flutter/material.dart';
import '../services/aptitude_progress_service.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

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
      appBar: GameHudAppBar(
        showBack: true,
        subtitle: '$_categoryName Levels',
      ),
      body: StarfieldBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final level = index + 1;
            final completed = _status[level] ?? false;
            final unlocked = _isUnlocked(level);
            return _AptitudeLevelTile(
              level: level,
              completed: completed,
              unlocked: unlocked,
              onOpen: unlocked
                  ? () => Navigator.pushNamed(
                        context,
                        '/aptitudeQuestions',
                        arguments: {'category': _categoryId, 'level': level},
                      )
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _AptitudeLevelTile extends StatelessWidget {
  final int level;
  final bool completed;
  final bool unlocked;
  final VoidCallback? onOpen;

  const _AptitudeLevelTile({
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
