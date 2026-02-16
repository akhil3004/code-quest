import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement_model.dart';
import 'dart:math';

class AchievementService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<AchievementModel> all() {
    return [
      AchievementModel(id: 'first_steps', title: 'First Steps', description: 'Earn your first XP', icon: 'star', unlocked: false),
      AchievementModel(id: 'welcome_coder', title: 'Welcome Coder', description: 'Complete first MCQ', icon: 'school', unlocked: false),
      AchievementModel(id: 'getting_started', title: 'Getting Started', description: 'Complete Level 1 of any subject', icon: 'flag', unlocked: false),
      AchievementModel(id: 'curious_mind', title: 'Curious Mind', description: 'Open 5 learning screens', icon: 'explore', unlocked: false),
      AchievementModel(id: 'os_explorer', title: 'OS Explorer', description: 'Complete OS Level 1', icon: 'memory', unlocked: false),
      AchievementModel(id: 'dbms_explorer', title: 'DBMS Explorer', description: 'Complete DBMS Level 1', icon: 'storage', unlocked: false),
      AchievementModel(id: 'cn_explorer', title: 'CN Explorer', description: 'Complete CN Level 1', icon: 'router', unlocked: false),
      AchievementModel(id: 'dsa_explorer', title: 'DSA Explorer', description: 'Complete DSA Level 1', icon: 'api', unlocked: false),
      AchievementModel(id: 'cd_explorer', title: 'Compiler Explorer', description: 'Complete CD Level 1', icon: 'build', unlocked: false),
      AchievementModel(id: 'mcq_warrior', title: 'MCQ Warrior', description: 'Complete 25 MCQs', icon: 'military_tech', unlocked: false),
      AchievementModel(id: 'mcq_master', title: 'MCQ Master', description: 'Complete 100 MCQs', icon: 'emoji_events', unlocked: false),
      AchievementModel(id: 'perfect_score', title: 'Perfect Score', description: '10/10 correct in one level', icon: 'star_outline', unlocked: false),
      AchievementModel(id: 'aptitude_starter', title: 'Aptitude Starter', description: 'Complete first aptitude level', icon: 'psychology', unlocked: false),
      AchievementModel(id: 'quant_champ', title: 'Quant Champ', description: 'Complete Quantitative Level 3', icon: 'calculate', unlocked: false),
      AchievementModel(id: 'logic_pro', title: 'Logic Pro', description: 'Complete Logical Level 3', icon: 'scatter_plot', unlocked: false),
      AchievementModel(id: 'verbal_ace', title: 'Verbal Ace', description: 'Complete Verbal Level 3', icon: 'text_fields', unlocked: false),
      AchievementModel(id: 'aptitude_grinder', title: 'Aptitude Grinder', description: 'Complete 50 aptitude questions', icon: 'fitness_center', unlocked: false),
      AchievementModel(id: 'debug_rookie', title: 'Debug Rookie', description: 'Solve first debug problem', icon: 'bug_report', unlocked: false),
      AchievementModel(id: 'bug_squasher', title: 'Bug Squasher', description: 'Solve 5 debug problems', icon: 'handyman', unlocked: false),
      AchievementModel(id: 'debugger', title: 'Debugger', description: 'Solve 10 debug problems', icon: 'code', unlocked: false),
      AchievementModel(id: 'flawless_code', title: 'Flawless Code', description: 'Correct output on first attempt', icon: 'verified', unlocked: false),
      AchievementModel(id: 'consistent_learner', title: 'Consistent Learner', description: '3-day streak', icon: 'schedule', unlocked: false),
      AchievementModel(id: 'weekly_warrior', title: 'Weekly Warrior', description: '7-day streak', icon: 'event', unlocked: false),
      AchievementModel(id: 'habit_builder', title: 'Habit Builder', description: '14-day streak', icon: 'calendar_month', unlocked: false),
      AchievementModel(id: 'unstoppable', title: 'Unstoppable', description: '30-day streak', icon: 'rocket', unlocked: false),
      AchievementModel(id: 'xp_beginner', title: 'XP Beginner', description: '100 XP', icon: 'bolt', unlocked: false),
      AchievementModel(id: 'xp_grinder', title: 'XP Grinder', description: '500 XP', icon: 'battery_charging_full', unlocked: false),
      AchievementModel(id: 'xp_beast', title: 'XP Beast', description: '1000 XP', icon: 'battery_alert', unlocked: false),
      AchievementModel(id: 'level_up', title: 'Level Up!', description: 'Reach Level 5', icon: 'trending_up', unlocked: false),
      AchievementModel(id: 'elite_coder', title: 'Elite Coder', description: 'Reach Level 10', icon: 'workspace_premium', unlocked: false),
    ];
  }

  Future<void> _incrementStat(String field, int by) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('stats').doc('counters');
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final current = (data[field] ?? 0) as int;
      tx.set(ref, {field: current + by}, SetOptions(merge: true));
    });
  }

  Future<bool> _isUnlocked(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).collection('achievements').doc(id).get();
    return (doc.data()?['unlocked'] ?? false) as bool;
  }

  Future<void> _unlock(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final already = await _isUnlocked(id);
    if (already) return;
    await _db.collection('users').doc(uid).collection('achievements').doc(id).set({
      'unlocked': true,
      'unlockedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> recordScreenOpen() async {
    await _incrementStat('screensOpened', 1);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('stats').doc('counters');
    final snap = await ref.get();
    final opened = (snap.data()?['screensOpened'] ?? 0) as int;
    if (opened >= 5) await _unlock('curious_mind');
  }

  Future<void> _updateStreakOnActivity() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final userRef = _db.collection('users').doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? {};
      final lastStr = data['lastActiveDate'] as String?;
      final currentStreak = (data['streak'] ?? 0) as int;
      final longestStreak = (data['longestStreak'] ?? 0) as int;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime? lastDate;
      if (lastStr != null) {
        try {
          lastDate = DateTime.parse(lastStr);
        } catch (_) {
          lastDate = null;
        }
      }
      int newStreak = currentStreak;
      if (lastDate == null) {
        newStreak = 1;
      } else {
        final diffDays = today.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
        if (diffDays == 0) {
          return;
        } else if (diffDays == 1) {
          newStreak = currentStreak + 1;
        } else {
          newStreak = 1;
        }
      }
      final newLongest = max(longestStreak, newStreak);
      tx.set(userRef, {
        'streak': newStreak,
        'longestStreak': newLongest,
        'lastActiveDate': today.toIso8601String(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> recordXPUpdated() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await _db.collection('users').doc(uid).get();
    final xp = (userDoc.data()?['xp'] ?? 0) as int;
    if (xp > 0) await _unlock('first_steps');
    if (xp >= 100) await _unlock('xp_beginner');
    if (xp >= 500) await _unlock('xp_grinder');
    if (xp >= 1000) await _unlock('xp_beast');
    final level = (userDoc.data()?['level'] ?? 0) as int;
    if (level >= 5) await _unlock('level_up');
    if (level >= 10) await _unlock('elite_coder');
    final streak = (userDoc.data()?['streak'] ?? 0) as int;
    if (streak >= 3) await _unlock('consistent_learner');
    if (streak >= 7) await _unlock('weekly_warrior');
    if (streak >= 14) await _unlock('habit_builder');
    if (streak >= 30) await _unlock('unstoppable');
  }

  Future<void> recordMcqCorrect() async {
    await _incrementStat('mcqSolved', 1);
    await _unlock('welcome_coder');
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('stats').doc('counters');
    final snap = await ref.get();
    final count = (snap.data()?['mcqSolved'] ?? 0) as int;
    if (count >= 25) await _unlock('mcq_warrior');
    if (count >= 100) await _unlock('mcq_master');
  }

  Future<void> recordMcqLevelComplete(String subject, int level, {required bool perfect}) async {
    await _updateStreakOnActivity();
    if (level == 1) {
      if (subject == 'os') await _unlock('os_explorer');
      if (subject == 'dbms') await _unlock('dbms_explorer');
      if (subject == 'cn') await _unlock('cn_explorer');
      if (subject == 'dsa') await _unlock('dsa_explorer');
      if (subject == 'cd') await _unlock('cd_explorer');
      await _unlock('getting_started');
    }
    if (perfect) await _unlock('perfect_score');
  }

  Future<void> recordAptitudeQuestionCorrect() async {
    await _incrementStat('aptitudeSolved', 1);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('stats').doc('counters');
    final snap = await ref.get();
    final count = (snap.data()?['aptitudeSolved'] ?? 0) as int;
    if (count >= 50) await _unlock('aptitude_grinder');
  }

  Future<void> recordAptitudeLevelComplete(String category, int level) async {
    await _updateStreakOnActivity();
    if (level == 1) await _unlock('aptitude_starter');
    if (category == 'quantitative' && level >= 3) await _unlock('quant_champ');
    if (category == 'logical' && level >= 3) await _unlock('logic_pro');
    if (category == 'verbal' && level >= 3) await _unlock('verbal_ace');
  }

  Future<void> recordDebugSolve({required bool firstAttempt}) async {
    await _updateStreakOnActivity();
    await _incrementStat('debugSolved', 1);
    await _unlock('debug_rookie');
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('stats').doc('counters');
    final snap = await ref.get();
    final count = (snap.data()?['debugSolved'] ?? 0) as int;
    if (count >= 5) await _unlock('bug_squasher');
    if (count >= 10) await _unlock('debugger');
    if (firstAttempt) await _unlock('flawless_code');
  }

  Future<List<AchievementModel>> userAchievements() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return all();
    final base = all();
    final col = await _db.collection('users').doc(uid).collection('achievements').get();
    final unlockedIds = {for (final d in col.docs) d.id};
    return base.map((a) => AchievementModel(id: a.id, title: a.title, description: a.description, icon: a.icon, unlocked: unlockedIds.contains(a.id))).toList();
  }
}
