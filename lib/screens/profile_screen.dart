import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        appBar: GameHudAppBar(
          showBack: true,
          subtitle: 'Profile',
        ),
        body: StarfieldBackground(
          child: Center(child: Text('Not logged in')),
        ),
      );
    }
    final doc = FirebaseFirestore.instance.collection('users').doc(uid);
    final achCol = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('achievements');
    return Scaffold(
      appBar: const GameHudAppBar(
        showBack: true,
        subtitle: 'Pilot Profile',
      ),
      body: StarfieldBackground(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: doc.snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            if (!snap.hasData || !snap.data!.exists) {
              return const Center(
                child: Text('No profile data yet. Play some games!'),
              );
            }
            final d = snap.data!.data() ?? {};
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: achCol.snapshots(),
              builder: (context, achSnap) {
                final unlocked = achSnap.hasData ? achSnap.data!.size : 0;
                final username = d['username'] ?? '';
                final xp = d['xp'] ?? 0;
                final level = d['level'] ?? 0;
                final title = d['title'] ?? '';
                final streak = d['streak'] ?? 0;
                final longest = d['streak'] ?? 0;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          _AvatarWithGlow(
                            username: username.toString(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title.toString().toUpperCase(),
                            style: RetroTheme.hudLabel.copyWith(
                              fontSize: 16,
                              letterSpacing: 3,
                              color: RetroTheme.gold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'LV $level • $xp XP',
                            style: RetroTheme.bodyMono.copyWith(
                              color: RetroTheme.text.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatPill(
                                label: 'Streak',
                                value: streak.toString(),
                                icon: Icons.local_fire_department,
                              ),
                              _StatPill(
                                label: 'Longest',
                                value: longest.toString(),
                                icon: Icons.timeline,
                              ),
                              _StatPill(
                                label: 'Badges',
                                value: unlocked.toString(),
                                icon: Icons.emoji_events,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Top Achievements',
                              style: RetroTheme.hudLabel.copyWith(
                                color: RetroTheme.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TopAchievementsRow(
                            snapshot: achSnap.data,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AvatarWithGlow extends StatelessWidget {
  final String username;

  const _AvatarWithGlow({required this.username});

  @override
  Widget build(BuildContext context) {
    final initials =
        username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RetroTheme.primary.withValues(alpha: 0.9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: RetroTheme.primary.withValues(alpha: 0.7),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            RetroTheme.primary.withValues(alpha: 0.3),
            RetroTheme.accent.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: RetroTheme.bodyMono.copyWith(
            fontSize: 32,
            color: RetroTheme.background,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RetroTheme.primary.withValues(alpha: 0.85),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            RetroTheme.primary.withValues(alpha: 0.2),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RetroTheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: RetroTheme.hudLabel.copyWith(
                  fontSize: 10,
                  color: RetroTheme.text.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: RetroTheme.bodyMono.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopAchievementsRow extends StatelessWidget {
  final QuerySnapshot<Map<String, dynamic>>? snapshot;

  const _TopAchievementsRow({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (snapshot == null || snapshot!.docs.isEmpty) {
      return Text(
        'Unlock achievements to display them here.',
        style: RetroTheme.bodyMono.copyWith(
          fontSize: 12,
          color: RetroTheme.text.withValues(alpha: 0.7),
        ),
      );
    }

    final docs = snapshot!.docs.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: docs
          .map(
            (d) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: RetroTheme.gold.withValues(alpha: 0.85),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      RetroTheme.gold.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    (d.data()['title'] ?? '') as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RetroTheme.bodyMono.copyWith(
                      fontSize: 11,
                      color: RetroTheme.background,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
