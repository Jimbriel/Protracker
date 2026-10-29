import 'package:flutter/widgets.dart';
import '../models/cleaning_models.dart';
import 'assign_screen.dart';
import 'my_tasks_screen.dart';
import 'validation_screen.dart';

/// Pantalla de inicio según el rol del usuario.
Widget homeFor(AppUser user) => switch (user.role) {
      UserRole.operario => const MyTasksScreen(),
      UserRole.jefatura => const AssignScreen(),
      UserRole.supervisor => const ValidationScreen(),
    };
