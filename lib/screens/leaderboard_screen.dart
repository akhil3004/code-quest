import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../models/user_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LeaderboardService();
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<List<UserModel>>(
        stream: service.topUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error loading leaderboard: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text('No users found on the leaderboard.'));
          }
          final users = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(u.username),
                subtitle: Text('Level ${u.level} • ${u.title}'),
                trailing: Text('${u.xp} XP'),
              );
            },
          );
        },
      ),
    );
  }
}
