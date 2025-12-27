import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    final doc = FirebaseFirestore.instance.collection('users').doc(uid);
    final achCol = FirebaseFirestore.instance.collection('users').doc(uid).collection('achievements');
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!.data() ?? {};
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: achCol.snapshots(),
            builder: (context, achSnap) {
              final unlocked = achSnap.hasData ? achSnap.data!.size : 0;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Username: ${d['username'] ?? ''}'),
                    const SizedBox(height: 8),
                    Text('XP: ${d['xp'] ?? 0}'),
                    const SizedBox(height: 8),
                    Text('Level: ${d['level'] ?? 0}'),
                    const SizedBox(height: 8),
                    Text('Title: ${d['title'] ?? ''}'),
                    const SizedBox(height: 8),
                    Text('Achievements unlocked: $unlocked'),
                    const SizedBox(height: 8),
                    Text('Current streak: ${d['streak'] ?? 0}'),
                    const SizedBox(height: 8),
                    Text('Longest streak: ${d['streak'] ?? 0}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
