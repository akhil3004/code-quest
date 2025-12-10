import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/xp_service.dart';
import '../widgets/title_badge.dart';
import '../widgets/xp_progress_bar.dart';

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
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/mcqSubjects'), child: const Text('MCQ Subjects')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/interview'), child: const Text('Interview Q&A')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/interviewPdfs'), child: const Text('Interview PDFs')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/aptitude'), child: const Text('Aptitude')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/debug'), child: const Text('Debugging (Judge API)')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/debugCategories'), child: const Text('Debug Categories')),
          ],
        ),
      ),
    );
  }
}
