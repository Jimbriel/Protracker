import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/login_screen.dart';

class FracttalApp extends StatelessWidget {
  const FracttalApp({super.key});

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
