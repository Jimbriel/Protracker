import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import 'report_screen.dart';

/// Inicio del supervisor: limpiezas por validar y ya validadas.
class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Text(
            'Validación',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: const [AppBarActions()],
          backgroundColor: AppColors.background,
          elevation: 0,
          bottom: const TabBar(
            tabs: [Tab(text: 'Por validar'), Tab(text: 'Validadas')],
          ),
        ),
        drawer: const AppDrawer(),
        body: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            List<CleaningActivity> byStatus(ActivityStatus s) => [
                  for (final a in store.activities)
                    if (a.status == s) a,
                ]..sort((a, b) =>
                    (b.finishedAt ?? b.date).compareTo(a.finishedAt ?? a.date));

            Widget list(List<CleaningActivity> items, String empty) {
              if (items.isEmpty) return EmptyState(label: empty);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final a in items.take(60))
                    ActivityTile(
                      activity: a,
                      showDate: true,
                      showAssignee: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportScreen(activityId: a.id),
                        ),
                      ),
                    ),
                ],
              );
            }

            return TabBarView(
              children: [
                list(byStatus(ActivityStatus.completed),
                    'No hay limpiezas por validar'),
                list(byStatus(ActivityStatus.validated),
                    'Aún no hay limpiezas validadas'),
              ],
            );
          },
        ),
      ),
    );
  }
}
