import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'data/demo_store.dart';
import 'screens/login_screen.dart';
import 'screens/role_home.dart';

class ProTrackerApp extends StatelessWidget {
  const ProTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DemoStore.instance.currentUser;
    return MaterialApp(
      title: 'PRO tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: user == null ? const LoginScreen() : homeFor(user),
    );
  }
}
