import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class GlobalChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Stream<List<ChatMessage>> getMessages() {
    return _firestore
        .collection('global_chat')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final UserModel? user = await _authService.currentUserProfile();
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('global_chat').add({
      'text': text.trim(),
      'userId': user.uid,
      'username': user.username,
      'userTitle': user.title,
      'userLevel': user.level,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
