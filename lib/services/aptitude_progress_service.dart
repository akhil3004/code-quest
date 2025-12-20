import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AptitudeProgressService {
  Future<Map<int, bool>> getStatus(String category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('aptitude').doc(category).get();
    final data = doc.data() ?? {};
    final result = <int, bool>{};
    for (final entry in data.entries) {
      final lvl = int.tryParse(entry.key);
      if (lvl != null) result[lvl] = (entry.value as bool?) ?? false;
    }
    return result;
  }

  Future<void> markComplete(String category, int level) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid).collection('aptitude').doc(category);
    await ref.set({level.toString(): true}, SetOptions(merge: true));
  }

  Future<void> unlockNext(String category, int level) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final next = level + 1;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid).collection('aptitude').doc(category);
    await ref.set({next.toString(): false}, SetOptions(merge: true));
  }
}
