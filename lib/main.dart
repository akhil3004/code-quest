import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mcq_screen.dart';
import 'screens/interview_screen.dart';
import 'screens/debug_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/global_chat_screen.dart';
import 'screens/mcq_subjects_screen.dart';
import 'screens/mcq_levels_screen.dart';
import 'screens/mcq_questions_screen.dart';
import 'screens/interview_pdfs_screen.dart';
import 'screens/aptitude_screen.dart';
import 'screens/aptitude_categories_screen.dart';
import 'screens/aptitude_levels_screen.dart';
import 'screens/aptitude_questions_screen.dart';
import 'screens/achievements_screen.dart';
import 'services/achievement_service.dart';
import 'services/title_service.dart';
import 'services/auth_service.dart';
import 'services/xp_service.dart';
import 'theme/retro_theme.dart';

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
        Provider(create: (_) => AchievementService()),
        Provider(create: (_) => TitleService()),
      ],
      child: MaterialApp(
        title: 'Code Quest',
        theme: RetroTheme.theme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/mcq': (_) => const McqScreen(),
          '/mcqSubjects': (_) => const McqSubjectsScreen(),
          '/mcqLevels': (_) => const McqLevelsScreen(),
          '/mcqQuestions': (_) => const McqQuestionsScreen(),
          '/interview': (_) => const InterviewScreen(),
          '/interviewPdfs': (_) => const InterviewPdfsScreen(),
          '/aptitude': (_) => const AptitudeScreen(),
          '/aptitudeCategories': (_) => const AptitudeCategoriesScreen(),
          '/aptitudeLevels': (_) => const AptitudeLevelsScreen(),
          '/aptitudeQuestions': (_) => const AptitudeQuestionsScreen(),
          '/debug': (_) => const DebugScreen(),
          '/achievements': (_) => const AchievementsScreen(),
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/globalChat': (_) => const GlobalChatScreen(),
        },
      ),
    );
  }
}
