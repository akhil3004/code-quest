import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../models/user_model.dart';
import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LeaderboardService();
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Galaxy Leaderboard',
      ),
      body: StarfieldBackground(
        child: StreamBuilder<List<UserModel>>(
          stream: service.topUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading leaderboard: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No users found on the leaderboard.'),
              );
            }
            final users = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final u = users[index];
                final rank = index + 1;
                final isTop3 = rank <= 3;
                Color borderColor;
                if (rank == 1) {
                  borderColor = RetroTheme.gold;
                } else if (rank == 2) {
                  borderColor = RetroTheme.accent;
                } else if (rank == 3) {
                  borderColor = RetroTheme.primary;
                } else {
                  borderColor = Colors.white.withValues(alpha: 0.4);
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 1.5),
                    gradient: LinearGradient(
                      colors: [
                        borderColor.withValues(alpha: isTop3 ? 0.24 : 0.12),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 1.5),
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: RetroTheme.bodyMono.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.username,
                              style: RetroTheme.bodyMono.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${u.level} • ${_calculateTitle(u.level)}',
                              style: RetroTheme.bodyMono.copyWith(
                                fontSize: 11,
                                color: RetroTheme.text.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${u.xp} XP',
                        style: RetroTheme.bodyMono.copyWith(
                          fontSize: 12,
                          color: RetroTheme.gold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _calculateTitle(int level) {
    if (level <= 5) return 'Rookie Coder';
    if (level <= 10) return 'Logic Learner';
    if (level <= 20) return 'Explorer';
    if (level <= 30) return 'Galaxy Debugger';
    return 'Code Master';
  }
}
