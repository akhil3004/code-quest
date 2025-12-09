import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class LeaderboardService {
  final _db = FirebaseFirestore.instance;

  Stream<List<UserModel>> topUsers({int limit = 100}) {
    return _db
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => UserModel.fromJson(d.data())).toList());
  }
}
