import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/screens/splash_screen.dart';

class LoopinApp extends StatelessWidget {
  const LoopinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOOPIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
