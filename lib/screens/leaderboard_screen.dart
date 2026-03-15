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
                child: Text('Error: ${snapshot.error}',
                    style: RetroTheme.bodyMono),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No warriors yet — be the first!',
                    style: RetroTheme.bodyMono
                        .copyWith(color: RetroTheme.text.withValues(alpha: 0.6))),
              );
            }

            final users = snapshot.data!;

            return CustomScrollView(
              slivers: [
                // ── Podium (top 3) ─────────────────────────────────────────
                if (users.length >= 3)
                  SliverToBoxAdapter(
                    child: _Podium(users: users.take(3).toList()),
                  ),

                // ── Divider + label ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: Colors.white.withValues(alpha: 0.12))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ALL WARRIORS',
                            style: RetroTheme.hudLabel.copyWith(
                              fontSize: 11,
                              letterSpacing: 2,
                              color:
                                  RetroTheme.text.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: Colors.white.withValues(alpha: 0.12))),
                      ],
                    ),
                  ),
                ),

                // ── Full ranked list ───────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final u    = users[index];
                        final rank = index + 1;
                        return _RankRow(user: u, rank: rank);
                      },
                      childCount: users.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Podium widget (top 3 shown as gold/silver/bronze platforms)
// ─────────────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<UserModel> users; // exactly 3

  const _Podium({required this.users});

  @override
  Widget build(BuildContext context) {
    // Reorder: 2nd | 1st | 3rd  (classic podium layout)
    final ordered = [users[1], users[0], users[2]];
    final heights = [90.0, 120.0, 70.0];
    final ranks   = [2, 1, 3];
    final medals  = ['🥈', '🥇', '🥉'];
    final colors  = [
      const Color(0xFFC0C0C0), // silver
      RetroTheme.gold,          // gold
      const Color(0xFFCD7F32), // bronze
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          return Expanded(
            child: _PodiumSlot(
              user:   ordered[i],
              rank:   ranks[i],
              medal:  medals[i],
              color:  colors[i],
              height: heights[i],
            ),
          );
        }),
      ),
    );
  }
}

class _PodiumSlot extends StatefulWidget {
  final UserModel user;
  final int       rank;
  final String    medal;
  final Color     color;
  final double    height;

  const _PodiumSlot({
    required this.user,
    required this.rank,
    required this.medal,
    required this.color,
    required this.height,
  });

  @override
  State<_PodiumSlot> createState() => _PodiumSlotState();
}

class _PodiumSlotState extends State<_PodiumSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1600 + widget.rank * 200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final glow = 0.3 + _pulse.value * 0.4;
        return Column(
          children: [
            // Medal emoji
            Text(widget.medal, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            // Avatar circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: widget.color.withValues(alpha: 0.9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: glow),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
                color: widget.color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  widget.user.username.isNotEmpty
                      ? widget.user.username[0].toUpperCase()
                      : '?',
                  style: RetroTheme.bodyMono.copyWith(
                      fontSize: 20, color: widget.color),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Username
            Text(
              widget.user.username,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: RetroTheme.bodyMono.copyWith(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9)),
            ),
            // XP
            Text(
              '${widget.user.xp} XP',
              style: RetroTheme.bodyMono
                  .copyWith(fontSize: 10, color: widget.color),
            ),
            const SizedBox(height: 6),
            // Platform block
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [
                    widget.color.withValues(alpha: 0.35),
                    widget.color.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '#${widget.rank}',
                  style: RetroTheme.hudLabel.copyWith(
                    color: widget.color,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rank row (4th place onwards)
// ─────────────────────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  final UserModel user;
  final int       rank;

  const _RankRow({required this.user, required this.rank});

  Color _rankColor() {
    if (rank == 1) return RetroTheme.gold;
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.white.withValues(alpha: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    final color = _rankColor();
    final isTop3 = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: isTop3 ? 1.5 : 1.0),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isTop3 ? 0.20 : 0.08),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end:   Alignment.centerRight,
        ),
        boxShadow: isTop3
            ? [BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 12)]
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
              color: color.withValues(alpha: isTop3 ? 0.15 : 0.08),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: RetroTheme.bodyMono.copyWith(
                  fontSize: 13,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar initial
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(
                  color: color.withValues(alpha: 0.4), width: 1),
            ),
            child: Center(
              child: Text(
                user.username.isNotEmpty
                    ? user.username[0].toUpperCase()
                    : '?',
                style: RetroTheme.bodyMono
                    .copyWith(fontSize: 13, color: color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: RetroTheme.bodyMono.copyWith(
                    fontSize: 14,
                    color: Colors.white.withValues(
                        alpha: isTop3 ? 1.0 : 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lvl ${user.level} · ${_title(user.level)}',
                  style: RetroTheme.bodyMono.copyWith(
                    fontSize: 10,
                    color: RetroTheme.text.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          // XP
          Text(
            '${user.xp} XP',
            style: RetroTheme.bodyMono.copyWith(
              fontSize: 13,
              color: color,
              shadows: isTop3
                  ? [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _title(int level) {
    if (level <= 5)  return 'Rookie Coder';
    if (level <= 10) return 'Logic Learner';
    if (level <= 20) return 'Explorer';
    if (level <= 30) return 'Galaxy Debugger';
    return 'Code Master';
  }
}
