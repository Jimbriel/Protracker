import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/fracttal_logo.dart';
import '../screens/dashboard_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/work_orders_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _catalogosExpanded = true;
  bool _tareasExpanded = true;

  @override
  Widget build(BuildContext context) {
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
                  _buildLogoSection(),
                  _buildQuickActions(context),
                  const SizedBox(height: 8),
                  _buildSection(
                    label: 'Catálogos',
                    expanded: _catalogosExpanded,
                    onTap: () => setState(
                      () => _catalogosExpanded = !_catalogosExpanded,
                    ),
                    children: [
                      _DrawerItem(
                        icon: Icons.layers_outlined,
                        label: 'Activos',
                        onTap: () => Navigator.pop(context),
                      ),
                      _DrawerItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Recursos Humanos',
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  _buildSection(
                    label: 'Tareas',
                    expanded: _tareasExpanded,
                    onTap: () => setState(
                      () => _tareasExpanded = !_tareasExpanded,
                    ),
                    children: [
                      _DrawerItem(
                        icon: Icons.assignment_outlined,
                        label: 'Plan de Tareas',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TasksScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.content_paste_outlined,
                        label: 'Órdenes de Trabajo',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkOrdersScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.shield_outlined,
                        label: 'Compliance y seguridad',
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Ayuda',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBuildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const FracttalLogo(size: 28),
           const SizedBox(height: 6),
           Padding(
             padding: const EdgeInsets.only(left: 4),
             child: Text(
               'PRO tracker • Versión: 5.5.04',
               style: GoogleFonts.inter(
                 fontSize: 12,
                 color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.qr_code_scanner_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _QuickAction(
            icon: Icons.home_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
          _QuickAction(
            icon: Icons.cloud_off_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required bool expanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            margin: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.divider, width: 2),
              ),
            ),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _buildBuildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Commit: de803fa',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
          Text(
            'BuiltTime: 2026-05-05 14:05',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.iconBg,
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
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
