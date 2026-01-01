import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/xp_service.dart';
import '../widgets/title_badge.dart';
import '../widgets/xp_progress_bar.dart';
import '../services/achievement_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<XPService>().load();
      AchievementService().recordXPUpdated();
    });
  }

  @override
  Widget build(BuildContext context) {
    final xpService = context.watch<XPService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Quest'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/leaderboard'), icon: const Icon(Icons.leaderboard)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person)),
          IconButton(onPressed: () => AuthService().signOut().then((_) => Navigator.pushReplacementNamed(context, '/login')), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleBadge(title: xpService.title),
            const SizedBox(height: 12),
            XPProgressBar(xp: xpService.xp),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () { AchievementService().recordScreenOpen(); Navigator.pushNamed(context, '/mcqSubjects'); }, child: const Text('MCQ Subjects')),
            ElevatedButton(onPressed: () { AchievementService().recordScreenOpen(); Navigator.pushNamed(context, '/interviewPdfs'); }, child: const Text('Interview PDFs')),
            ElevatedButton(onPressed: () { AchievementService().recordScreenOpen(); Navigator.pushNamed(context, '/aptitudeCategories'); }, child: const Text('Aptitude')),
            ElevatedButton(onPressed: () { AchievementService().recordScreenOpen(); Navigator.pushNamed(context, '/debug'); }, child: const Text('Debugging Challenges')),
            ElevatedButton(onPressed: () { Navigator.pushNamed(context, '/achievements'); }, child: const Text('Achievements')),
          ],
        ),
      ),
    );
  }
}
