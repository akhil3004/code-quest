import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TitleService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Calculate title based ONLY on level
  static String calculateTitle(int level) {
    if (level <= 5) return "Rookie Coder";
    if (level <= 10) return "Logic Learner";
    if (level <= 20) return "Explorer";
    if (level <= 30) return "Galaxy Debugger";
    return "Code Master";
  }

  /// Recalculate and update user's title based on current level
  Future<void> recalculateTitle() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    final userDoc = await _db.collection('users').doc(uid).get();
    final level = (userDoc.data()?['level'] ?? 0) as int;
    final newTitle = calculateTitle(level);
    
    // Update ONLY the title field, no lists or arrays
    await _db.collection('users').doc(uid).update({
      'title': newTitle,
    });
  }
}
