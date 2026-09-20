import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/dashboard/add_task_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/dashboard/home_screen.dart';
import '../features/focus/screens/focus_setup_screen.dart';
import '../features/focus/screens/focus_session_screen.dart';
import '../features/focus/screens/focus_summary_screen.dart';
import '../features/learning/screens/learning_hub_screen.dart';
import '../features/study/models/study_models.dart';

class LoopinApp extends StatelessWidget {
  const LoopinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOOPIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/profile': (_) => const ProfileSetupScreen(),
        '/home': (_) => const HomeScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/add-task': (_) => const AddTaskScreen(),
        '/focus': (_) => const FocusSetupScreen(),
        '/learning': (_) => const LearningHubScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/focus-session' &&
            settings.arguments is FocusSession) {
          return MaterialPageRoute(
            builder: (_) => FocusSessionScreen(
              session: settings.arguments! as FocusSession,
            ),
          );
        }
        if (settings.name == '/focus-summary' &&
            settings.arguments is FocusSession) {
          return MaterialPageRoute(
            builder: (_) => FocusSummaryScreen(
              session: settings.arguments! as FocusSession,
            ),
          );
        }
        return null;
      },
    );
  }
}
