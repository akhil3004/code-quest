import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';
import '../theme/star_wars_retro_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _future = _service.userAchievements();
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'star': return Icons.star;
      case 'school': return Icons.school;
      case 'flag': return Icons.flag;
      case 'explore': return Icons.explore;
      case 'memory': return Icons.memory;
      case 'storage': return Icons.storage;
      case 'router': return Icons.router;
      case 'api': return Icons.api;
      case 'build': return Icons.build;
      case 'military_tech': return Icons.military_tech;
      case 'emoji_events': return Icons.emoji_events;
      case 'star_outline': return Icons.star_outline;
      case 'psychology': return Icons.psychology;
      case 'calculate': return Icons.calculate;
      case 'scatter_plot': return Icons.scatter_plot;
      case 'text_fields': return Icons.text_fields;
      case 'fitness_center': return Icons.fitness_center;
      case 'bug_report': return Icons.bug_report;
      case 'handyman': return Icons.handyman;
      case 'code': return Icons.code;
      case 'verified': return Icons.verified;
      case 'schedule': return Icons.schedule;
      case 'event': return Icons.event;
      case 'calendar_month': return Icons.calendar_month;
      case 'rocket': return Icons.rocket_launch;
      case 'bolt': return Icons.bolt;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'battery_alert': return Icons.battery_alert;
      case 'trending_up': return Icons.trending_up;
      case 'workspace_premium': return Icons.workspace_premium;
      default: return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Relic Collection',
      ),
      body: StarfieldBackground(
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
                  'No relics discovered yet.\nExplore the galaxy to find them.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: StarWarsRetroColors.textSoft,
                  ),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final a = items[index];
                return _BadgeTile(
                  model: a,
                  icon: _iconFromName(a.icon),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AchievementModel model;
  final IconData icon;

  const _BadgeTile({
    required this.model,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = model.unlocked;
    final color = unlocked ? StarWarsRetroColors.gold : Colors.grey.shade700;
    
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: unlocked 
                  ? [color.withValues(alpha: 0.3), Colors.transparent] 
                  : [Colors.grey.shade900, Colors.black],
                stops: const [0.5, 1.0],
              ),
              border: Border.all(
                color: color.withValues(alpha: unlocked ? 1.0 : 0.5),
                width: unlocked ? 2 : 1,
              ),
              boxShadow: [
                if (unlocked)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: unlocked ? color : Colors.grey.shade600,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          model.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: unlocked ? StarWarsRetroColors.textBright : StarWarsRetroColors.textSoft,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
