import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _service = AchievementService();
  late Future<List<AchievementModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.userAchievements();
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
      appBar: AppBar(title: const Text('Achievements')),
      body: FutureBuilder<List<AchievementModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final a = items[index];
              final color = a.unlocked ? Colors.green : Colors.grey;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_iconFromName(a.icon), color: color),
                      const SizedBox(height: 8),
                      Text(a.title, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(a.description, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
