import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  final _service = AchievementService();
  late Future<List<AchievementModel>> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _future = _service.userAchievements();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'star':
        return Icons.star;
      case 'school':
        return Icons.school;
      case 'flag':
        return Icons.flag;
      case 'explore':
        return Icons.explore;
      case 'memory':
        return Icons.memory;
      case 'storage':
        return Icons.storage;
      case 'router':
        return Icons.router;
      case 'api':
        return Icons.api;
      case 'build':
        return Icons.build;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'star_outline':
        return Icons.star_outline;
      case 'psychology':
        return Icons.psychology;
      case 'calculate':
        return Icons.calculate;
      case 'scatter_plot':
        return Icons.scatter_plot;
      case 'text_fields':
        return Icons.text_fields;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'bug_report':
        return Icons.bug_report;
      case 'handyman':
        return Icons.handyman;
      case 'code':
        return Icons.code;
      case 'verified':
        return Icons.verified;
      case 'schedule':
        return Icons.schedule;
      case 'event':
        return Icons.event;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'rocket':
        return Icons.rocket_launch;
      case 'bolt':
        return Icons.bolt;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'battery_alert':
        return Icons.battery_alert;
      case 'trending_up':
        return Icons.trending_up;
      case 'workspace_premium':
        return Icons.workspace_premium;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Achievements',
      ),
      body: StarfieldBackground(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: RetroTheme.accent.withValues(alpha: 0.9),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  colors: [
                    RetroTheme.accent.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: RetroTheme.accent.withValues(alpha: 0.3),
                ),
                labelStyle: RetroTheme.bodyMono.copyWith(
                  fontSize: 11,
                  color: RetroTheme.background,
                ),
                unselectedLabelStyle: RetroTheme.bodyMono.copyWith(fontSize: 11),
                labelColor: RetroTheme.background,
                unselectedLabelColor: RetroTheme.text,
                tabs: const [
                  Tab(text: 'MCQ'),
                  Tab(text: 'Aptitude'),
                  Tab(text: 'Debug'),
                  Tab(text: 'Streak'),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AchievementModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No achievements yet.\nComplete missions to unlock badges.',
                        textAlign: TextAlign.center,
                        style: RetroTheme.bodyMono.copyWith(
                          color: RetroTheme.text.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final a = items[index];
                      return _AchievementCard(
                        model: a,
                        icon: _iconFromName(a.icon),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel model;
  final IconData icon;

  const _AchievementCard({
    required this.model,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = model.unlocked;
    final borderColor = unlocked ? RetroTheme.gold : Colors.grey.withValues(alpha: 0.6);
    final glowColor =
        unlocked ? RetroTheme.gold.withValues(alpha: 0.7) : Colors.black;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
        gradient: LinearGradient(
          colors: unlocked
              ? [
                  RetroTheme.gold.withValues(alpha: 0.24),
                  RetroTheme.primary.withValues(alpha: 0.18),
                ]
              : [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.black.withValues(alpha: 0.4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: unlocked ? 18 : 4,
            spreadRadius: unlocked ? 1.5 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: unlocked ? RetroTheme.gold : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                if (!unlocked)
                  Icon(
                    Icons.lock,
                    color: Colors.grey.withValues(alpha: 0.8),
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              model.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RetroTheme.bodyMono.copyWith(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                model.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: RetroTheme.bodyMono.copyWith(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
