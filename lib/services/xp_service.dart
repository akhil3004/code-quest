import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class XPService extends ChangeNotifier {

  int _xp = 0;
  int get xp => _xp;
  int get level => calculateLevel(_xp);
  String get title => titleForLevel(level);

  Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    _xp = (snap.data()?['xp'] ?? 0) as int;
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final currentXP = (snap.data()?['xp'] ?? 0) as int;
      final newXP = currentXP + amount;
      final newLevel = calculateLevel(newXP);
      final newTitle = titleForLevel(newLevel);
      tx.update(docRef, {
        'xp': newXP,
        'level': newLevel,
        'title': newTitle,
      });
      _xp = newXP;
    });
    notifyListeners();
  }

  static int calculateLevel(int xp) => xp ~/ 100;

  static String titleForLevel(int level) {
    if (level <= 5) return 'Rookie Coder';
    if (level <= 10) return 'Logic Learner';
    if (level <= 20) return 'Quiz Champion';
    return 'Quiz Champion';
  }
}
