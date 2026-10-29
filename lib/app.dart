import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/login_screen.dart';

class ProTrackerApp extends StatelessWidget {
  const ProTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRO tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
