import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mcq_screen.dart';
import 'screens/interview_screen.dart';
import 'screens/debug_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/xp_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CodeQuestApp());
}

class CodeQuestApp extends StatelessWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => XPService()),
        Provider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Code Quest',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/mcq': (_) => const McqScreen(),
          '/interview': (_) => const InterviewScreen(),
          '/debug': (_) => const DebugScreen(),
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
