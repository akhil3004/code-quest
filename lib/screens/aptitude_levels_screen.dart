import 'package:flutter/material.dart';
import '../services/aptitude_progress_service.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/floating_chat_button.dart';
import '../widgets/planet_level_tile.dart';
import '../widgets/fade_slide_transition.dart';

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
        subtitle: '$_categoryName Planets',
      ),
      floatingActionButton: const FloatingChatButton(),
      body: StarfieldBackground(
        child: FadeSlideTransition(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            itemCount: 5,
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
                              '/aptitudeQuestions',
                              arguments: {'category': _categoryId, 'level': level},
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
