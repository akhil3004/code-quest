import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TitleService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final Map<String, int> _priority = {
    'Newbie': 1,
    'Rookie Coder': 2,
    'Logic Learner': 3,
    'Quiz Warrior': 4,
    'Aptitude Ace': 5,
    'Bug Hunter': 6,
    'Debug Master': 7,
    'Consistent Coder': 8,
    'XP Grinder': 9,
    'Elite Coder': 10,
    'Code Champion': 11,
    'Quest Master': 12,
  };

  Future<void> recalculateTitle() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await _db.collection('users').doc(uid).get();
    final xp = (userDoc.data()?['xp'] ?? 0) as int;
    final level = (userDoc.data()?['level'] ?? 0) as int;
    final streak = (userDoc.data()?['streak'] ?? 0) as int;
    final current = (userDoc.data()?['title'] ?? 'Newbie') as String;

    final stats = await _db.collection('users').doc(uid).collection('stats').doc('counters').get();
    final mcq = (stats.data()?['mcqSolved'] ?? 0) as int;
    final apt = (stats.data()?['aptitudeSolved'] ?? 0) as int;
    final dbg = (stats.data()?['debugSolved'] ?? 0) as int;

    final achCol = await _db.collection('users').doc(uid).collection('achievements').get();
    final achCount = achCol.size;

    String best = 'Newbie';
    if (level >= 10) best = 'Elite Coder';
    else if (xp >= 1000) best = 'Code Champion';
    else if (xp >= 500) best = 'XP Grinder';
    else if (streak >= 7) best = 'Consistent Coder';
    if (dbg >= 15) best = 'Debug Master';
    else if (dbg >= 5) best = 'Bug Hunter';
    if (apt >= 30) best = 'Aptitude Ace';
    if (mcq >= 50) best = 'Quiz Warrior';
    if (level >= 4) best = 'Logic Learner';
    if (level >= 2) best = 'Rookie Coder';
    if (achCount >= 20) best = 'Quest Master';

    final currentPri = _priority[current] ?? 1;
    final bestPri = _priority[best] ?? 1;
    if (bestPri > currentPri) {
      await _db.collection('users').doc(uid).set({'title': best}, SetOptions(merge: true));
    }
  }
}
