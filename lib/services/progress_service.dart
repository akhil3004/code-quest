import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<int, bool>> getCompletionStatus(String subject) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};
    final doc = await _db.collection('users').doc(uid).collection('progress').doc(subject).get();
    final data = doc.data() ?? {};
    final result = <int, bool>{};
    for (final entry in data.entries) {
      final lvl = int.tryParse(entry.key);
      if (lvl != null) result[lvl] = (entry.value as bool?) ?? false;
    }
    return result;
  }

  Future<void> markLevelComplete(String subject, int level) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('progress').doc(subject);
    await ref.set({level.toString(): true}, SetOptions(merge: true));
  }

  Future<void> unlockNextLevel(String subject, int level) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final next = level + 1;
    final ref = _db.collection('users').doc(uid).collection('progress').doc(subject);
    await ref.set({next.toString(): false}, SetOptions(merge: true));
  }
}
