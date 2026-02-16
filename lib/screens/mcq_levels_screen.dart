import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/progress_service.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/planet_level_tile.dart';
import '../widgets/fade_slide_transition.dart';

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
        subtitle: '${subject.name} Planets',
      ),
      body: StarfieldBackground(
        child: FadeSlideTransition(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            itemCount: 10,
            separatorBuilder: (_, __) => const SizedBox(height: 40),
            itemBuilder: (context, index) {
              final level = index + 1;
              final completed = _status[level] ?? false;
              final unlocked = _isUnlocked(level);

              // Orbital path simulation
              final double offset = (index % 2 == 0) ? -50.0 : 50.0;

              return Center(
                child: Transform.translate(
                  offset: Offset(offset, 0),
                  child: PlanetLevelTile(
                    level: level,
                    completed: completed,
                    unlocked: unlocked,
                    onTap: unlocked
                        ? () => Navigator.pushNamed(
                              context,
                              '/mcqQuestions',
                              arguments: {'subject': subject.id, 'level': level},
                            )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
