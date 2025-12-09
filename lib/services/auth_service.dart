import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'xp_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserModel?> currentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _db.collection('users').doc(user.uid).get();
    if (!snap.exists) return null;
    return UserModel.fromJson(snap.data()!);
  }

  Future<UserCredential> signUp(String email, String password, String username) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final level = XPService.calculateLevel(0);
    final title = XPService.titleForLevel(level);
    final userDoc = UserModel(
      uid: cred.user!.uid,
      username: username,
      xp: 0,
      level: level,
      title: title,
      streak: 0,
    );
    await _db.collection('users').doc(cred.user!.uid).set(userDoc.toJson());
    return cred;
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
