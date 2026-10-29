import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/catalog.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';
import '../widgets/app_logo.dart';
import 'role_home.dart';

/// Simula el inicio de sesión: la demo entra como cualquiera de los usuarios.
class UserPickerScreen extends StatelessWidget {
  const UserPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            const Center(child: AppLogo(size: 30)),
            const SizedBox(height: 24),
            Text(
              '¿Con qué usuario desea entrar?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Demo: cada rol ve una parte distinta del flujo.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            for (final role in UserRole.values) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text(
                  role.label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              for (final user in kUsers.where((u) => u.role == role))
                _UserCard(user: user),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final subtitle = user.shift == null
        ? _roleDescription(user.role)
        : 'Turno ${user.shift}';
    return Card(
      key: ValueKey('user-${user.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.iconBg,
          child: Text(
            user.name[0],
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final navigator = Navigator.of(context);
          await DemoStore.instance.signIn(user);
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => homeFor(user)),
            (_) => false,
          );
        },
      ),
    );
  }

  String _roleDescription(UserRole role) => switch (role) {
        UserRole.jefatura => 'Asigna tareas y revisa avances',
        UserRole.supervisor => 'Valida y aprueba las limpiezas',
        UserRole.operario => '',
      };
}
