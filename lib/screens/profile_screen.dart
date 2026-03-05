import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import '../theme/retro_theme.dart';
import '../theme/star_wars_retro_theme.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';
import '../widgets/xp_progress_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _changeAvatar(String uid) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final bytes = await picked.readAsBytes();
      final ref = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await uploadTask.ref.getDownloadURL();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(url);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'photoURL': url});
      }
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile image')),
      );
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return;
    }

    final currentController = TextEditingController();
    final newController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: RetroTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: RetroTheme.primary.withValues(alpha: 0.5),
            ),
          ),
          title: Text(
            'Change Password',
            style: RetroTheme.bodyMono.copyWith(
              fontSize: 14,
              color: RetroTheme.text,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('UPDATE'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    final currentPassword = currentController.text.trim();
    final newPassword = newController.text.trim();
    if (newPassword.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
        ),
      );
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Failed to update password';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please log in again and try changing password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password')),
      );
    }
  }

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
                final username = (d['username'] ?? '') as String;
                final xp = (d['xp'] ?? 0) as int;
                final level = (d['level'] ?? 0) as int;
                // Calculate title from level instead of reading stale Firestore value
                final title = _calculateTitle(level);
                final streak = (d['streak'] ?? 0) as int;
                final photoFromDoc = (d['photoURL'] ?? '') as String;
                final authUser = FirebaseAuth.instance.currentUser;
                final authPhoto = authUser?.photoURL ?? '';
                final photoUrl =
                    photoFromDoc.isNotEmpty ? photoFromDoc : authPhoto;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            _IdentityPanel(
                              username: username,
                              title: title,
                              xp: xp,
                              level: level,
                              streak: streak,
                              achievementsUnlocked: unlocked,
                              photoUrl: photoUrl,
                              onAvatarTap: () {
                                _changeAvatar(uid);
                              },
                            ),
                            const SizedBox(height: 24),
                            _MissionStatsSection(
                              uid: uid,
                              streak: streak,
                              achievementsUnlocked: unlocked,
                            ),
                            const SizedBox(height: 24),
                            _NextObjectivePanel(xp: xp),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _changePassword,
                                child: const Text('Change Password'),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _TopAchievementsSection(snapshot: achSnap.data),
                          ],
                        ),
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

  String _calculateTitle(int level) {
    if (level <= 5) return 'Rookie Coder';
    if (level <= 10) return 'Logic Learner';
    if (level <= 20) return 'Explorer';
    if (level <= 30) return 'Galaxy Debugger';
    return 'Code Master';
  }
}

class _IdentityPanel extends StatelessWidget {
  final String username;
  final String title;
  final int xp;
  final int level;
  final int streak;
  final int achievementsUnlocked;
  final String photoUrl;
  final VoidCallback onAvatarTap;

  const _IdentityPanel({
    required this.username,
    required this.title,
    required this.xp,
    required this.level,
    required this.streak,
    required this.achievementsUnlocked,
    required this.photoUrl,
    required this.onAvatarTap,
  });

  String _rankForXp(int value) {
    if (value < 500) return 'Cadet';
    if (value < 1500) return 'Explorer';
    if (value < 3000) return 'Commander';
    return 'Grand Strategist';
  }

  @override
  Widget build(BuildContext context) {
    final rank = _rankForXp(xp);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.6),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            StarWarsRetroColors.surfaceDark.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.2),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AvatarOrb(
                username: username,
                photoUrl: photoUrl,
                onTap: onAvatarTap,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.isEmpty ? 'Unknown Pilot' : username,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: StarWarsRetroColors.textBright,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title.isEmpty ? 'Rookie Coder' : title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: StarWarsRetroColors.textSoft,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _RankChip(label: rank),
                        const SizedBox(width: 8),
                        Text(
                          'LV $level · $xp XP',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: StarWarsRetroColors.textSoft),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          XPProgressBar(xp: xp),
        ],
      ),
    );
  }
}

class _AvatarOrb extends StatelessWidget {
  final String username;
  final String photoUrl;
  final VoidCallback onTap;

  const _AvatarOrb({
    required this.username,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StarWarsRetroColors.primaryNeon.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Avatar circle
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: StarWarsRetroColors.primaryNeon,
                  width: 2,
                ),
                gradient: LinearGradient(
                  colors: [
                    StarWarsRetroColors.surfaceDark,
                    Colors.black,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          initials,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: StarWarsRetroColors.textBright,
                              ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: StarWarsRetroColors.textBright,
                            ),
                      ),
                    ),
            ),
            // Camera badge — signals the avatar is tappable
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StarWarsRetroColors.surfaceDark,
                  border: Border.all(
                    color: StarWarsRetroColors.primaryNeon,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: StarWarsRetroColors.primaryNeon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  final String label;

  const _RankChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: StarWarsRetroColors.gold.withValues(alpha: 0.8),
          width: 1.2,
        ),
        gradient: LinearGradient(
          colors: [
            StarWarsRetroColors.gold.withValues(alpha: 0.25),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: StarWarsRetroColors.gold,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}

class _MissionStatsSection extends StatelessWidget {
  final String uid;
  final int streak;
  final int achievementsUnlocked;

  const _MissionStatsSection({
    required this.uid,
    required this.streak,
    required this.achievementsUnlocked,
  });

  Future<_MissionStats> _loadStats() async {
    final db = FirebaseFirestore.instance;
    final statsRef =
        db.collection('users').doc(uid).collection('stats').doc('counters');
    final statsSnap = await statsRef.get();
    final stats = statsSnap.data() ?? {};
    final mcq = (stats['mcqSolved'] ?? 0) as int;
    final apt = (stats['aptitudeSolved'] ?? 0) as int;
    final dbg = (stats['debugSolved'] ?? 0) as int;
    final totalQuestions = mcq + apt + dbg;

    int planetsConquered = 0;
    final progressCol =
        await db.collection('users').doc(uid).collection('progress').get();
    for (final doc in progressCol.docs) {
      final data = doc.data();
      for (final entry in data.entries) {
        if (entry.value == true) {
          planetsConquered++;
        }
      }
    }
    final aptitudeCol =
        await db.collection('users').doc(uid).collection('aptitude').get();
    for (final doc in aptitudeCol.docs) {
      final data = doc.data();
      for (final entry in data.entries) {
        if (entry.value == true) {
          planetsConquered++;
        }
      }
    }

    return _MissionStats(
      planetsConquered: planetsConquered,
      totalQuestionsSolved: totalQuestions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MissionStats>(
      future: _loadStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final planets = stats?.planetsConquered ?? 0;
        final totalQuestions = stats?.totalQuestionsSolved ?? 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _MissionStatTile(
                label: 'Planets Conquered',
                icon: Icons.public,
                value: planets,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MissionStatTile(
                label: 'Questions Solved',
                icon: Icons.help_center,
                value: totalQuestions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MissionStatTile(
                label: 'Current Streak',
                icon: Icons.local_fire_department,
                value: streak,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MissionStatTile(
                label: 'Achievements Unlocked',
                icon: Icons.emoji_events,
                value: achievementsUnlocked,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MissionStatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _MissionStatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.6),
          width: 1.2,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.black.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: StarWarsRetroColors.accentPurple,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: StarWarsRetroColors.textBright,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: StarWarsRetroColors.textSoft,
                ),
          ),
        ],
      ),
    );
  }
}

class _NextObjectivePanel extends StatelessWidget {
  final int xp;

  const _NextObjectivePanel({required this.xp});

  String _rankForXp(int value) {
    if (value < 500) return 'Cadet';
    if (value < 1500) return 'Explorer';
    if (value < 3000) return 'Commander';
    return 'Grand Strategist';
  }

  int _nextRankThreshold(int value) {
    if (value < 500) return 500;
    if (value < 1500) return 1500;
    if (value < 3000) return 3000;
    return 3000;
  }

  @override
  Widget build(BuildContext context) {
    final currentRank = _rankForXp(xp);
    final nextThreshold = _nextRankThreshold(xp);
    final remaining = nextThreshold - xp;

    String message;
    if (remaining <= 0 && currentRank == 'Grand Strategist') {
      message = 'You have reached the highest rank. Maintain your legacy.';
    } else {
      final planetsNeeded = (remaining / 100).ceil();
      message =
          'Next mission: complete $planetsNeeded more planets to reach $currentRank rank.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.5),
        ),
        gradient: LinearGradient(
          colors: [
            StarWarsRetroColors.surfaceDark.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Objective',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: StarWarsRetroColors.textBright,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: StarWarsRetroColors.textSoft,
                ),
          ),
        ],
      ),
    );
  }
}

class _TopAchievementsSection extends StatelessWidget {
  final QuerySnapshot<Map<String, dynamic>>? snapshot;

  const _TopAchievementsSection({required this.snapshot});

  // Same icon lookup table as achievements_screen.dart
  static IconData _iconFromName(String name) {
    const map = <String, IconData>{
      'star': Icons.star,
      'school': Icons.school,
      'flag': Icons.flag,
      'explore': Icons.explore,
      'memory': Icons.memory,
      'storage': Icons.storage,
      'router': Icons.router,
      'api': Icons.api,
      'build': Icons.build,
      'military_tech': Icons.military_tech,
      'emoji_events': Icons.emoji_events,
      'star_outline': Icons.star_outline,
      'psychology': Icons.psychology,
      'calculate': Icons.calculate,
      'scatter_plot': Icons.scatter_plot,
      'text_fields': Icons.text_fields,
      'fitness_center': Icons.fitness_center,
      'bug_report': Icons.bug_report,
      'handyman': Icons.handyman,
      'code': Icons.code,
      'verified': Icons.verified,
      'schedule': Icons.schedule,
      'event': Icons.event,
      'calendar_month': Icons.calendar_month,
      'rocket': Icons.rocket_launch,
      'bolt': Icons.bolt,
      'battery_charging_full': Icons.battery_charging_full,
      'battery_alert': Icons.battery_alert,
      'trending_up': Icons.trending_up,
      'workspace_premium': Icons.workspace_premium,
    };
    return map[name] ?? Icons.emoji_events;
  }

  @override
  Widget build(BuildContext context) {
    // Build a lookup map: achievement id → AchievementModel
    final allMap = <String, AchievementModel>{
      for (final a in AchievementService().all()) a.id: a,
    };

    if (snapshot == null || snapshot!.docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: RetroTheme.accent.withValues(alpha: 0.3),
          ),
          color: RetroTheme.cardBg.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline,
                color: RetroTheme.accent.withValues(alpha: 0.5), size: 20),
            const SizedBox(width: 12),
            Text(
              'Unlock achievements to display them here.',
              style: RetroTheme.bodyMono.copyWith(
                fontSize: 12,
                color: RetroTheme.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Take up to 3 unlocked achievements and look up their model data
    final achievementItems = snapshot!.docs
        .take(3)
        .map((d) => allMap[d.id])
        .whereType<AchievementModel>()
        .toList();

    if (achievementItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.emoji_events,
              color: RetroTheme.gold,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Top Achievements',
              style: RetroTheme.hudLabel.copyWith(
                color: RetroTheme.gold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: achievementItems.map((model) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RetroTheme.gold.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      RetroTheme.gold.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RetroTheme.gold.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconFromName(model.icon),
                      color: RetroTheme.gold,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      model.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: RetroTheme.bodyMono.copyWith(
                        fontSize: 10,
                        color: RetroTheme.text,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MissionStats {
  final int planetsConquered;
  final int totalQuestionsSolved;

  _MissionStats({
    required this.planetsConquered,
    required this.totalQuestionsSolved,
  });
}
