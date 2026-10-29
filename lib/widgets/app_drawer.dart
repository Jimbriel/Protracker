import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/role_home.dart';
import '../screens/tasks_screen.dart';
import '../widgets/app_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    final user = store.currentUser;
    final isManager = user != null && user.role != UserRole.operario;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppLogo(size: 28),
                        if (user != null) ...[
                          const SizedBox(height: 16),
                          _UserCard(user: user),
                        ],
                      ],
                    ),
                  ),
                  if (user != null)
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      label: 'Inicio',
                      onTap: () => _goTo(context, homeFor(user)),
                    ),
                  if (isManager)
                    _DrawerItem(
                      icon: Icons.insights_outlined,
                      label: 'Dashboard',
                      onTap: () => _goTo(context, const DashboardScreen()),
                    ),
                  _DrawerItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Plan de Tareas',
                    onTap: () => _goTo(context, const TasksScreen()),
                  ),
                  const Divider(height: 24),
                  _DrawerItem(
                    icon: Icons.restart_alt_rounded,
                    label: 'Restablecer demo',
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      await store.reset();
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Demo restablecida')),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await store.signOut();
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'PRO tracker • Demo v0.1.0',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textHint),
              ),
            ),
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
    final role = user.shift == null
        ? user.role.label
        : '${user.role.label} · Turno ${user.shift}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              user.name[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
