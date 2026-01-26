import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String userId;
  final String username;
  final String userTitle;
  final int userLevel;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.username,
    required this.userTitle,
    required this.userLevel,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userTitle: data['userTitle'] ?? 'Rookie',
      userLevel: (data['userLevel'] ?? 1) as int,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'username': username,
      'userTitle': userTitle,
      'userLevel': userLevel,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
