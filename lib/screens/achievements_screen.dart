import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';
import '../theme/star_wars_retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/fade_slide_transition.dart';

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
            return FadeSlideTransition(
              child: GridView.builder(
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
              ),
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
    
    return Tooltip(
      message: unlocked ? model.description : "Locked Relic",
      waitDuration: const Duration(milliseconds: 500),
      textStyle: GoogleFonts.spaceMono(fontSize: 12, color: StarWarsRetroColors.background),
      decoration: BoxDecoration(
        color: StarWarsRetroColors.gold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: StarWarsRetroColors.background.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked ? color : Colors.grey.shade700,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (unlocked ? color : Colors.black).withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: unlocked ? color : Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text(
                    model.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: unlocked ? StarWarsRetroColors.gold : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    model.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (!unlocked)
                    Text(
                      "LOCKED RELIC",
                      style: GoogleFonts.pressStart2p(
                        color: Colors.red.shade400,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      child: Column(
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
                boxShadow: unlocked ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
              child: Center(
                child: Icon(
                  icon, 
                  size: 48, 
                  color: unlocked ? color : Colors.grey.shade800
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            model.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: unlocked ? StarWarsRetroColors.textBright : Colors.grey.shade600,
              fontSize: 11,
              fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ));
  }
}
