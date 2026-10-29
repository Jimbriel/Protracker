import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import 'activity_screen.dart';

/// Inicio del operario: sus tareas de hoy y las que quedaron atrasadas.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser!;
        final now = DateTime.now();
        final today = store.tasksFor(user, now);
        final overdue = [
          for (final a in store.activities)
            if (a.assignedToId == user.id && a.isOverdue(now)) a,
        ]..sort((a, b) => b.date.compareTo(a.date));
        final done = today.where((a) => a.isDone).length;

        void open(CleaningActivity a) => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ActivityScreen(activityId: a.id)),
            );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: Text(
              'Mis tareas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: const [AppBarActions()],
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          drawer: const AppDrawer(),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(
                name: user.name,
                shift: user.shift ?? '',
                date: now,
                done: done,
                total: today.length,
              ),
              if (today.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: EmptyState(label: 'No tiene tareas asignadas hoy'),
                ),
              ...[
                for (final a in today)
                  ActivityTile(activity: a, onTap: () => open(a)),
              ],
              if (overdue.isNotEmpty) ...[
                SectionTitle('ATRASADAS (${overdue.length})'),
                for (final a in overdue)
                  ActivityTile(
                    activity: a,
                    showDate: true,
                    onTap: () => open(a),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String shift;
  final DateTime date;
  final int done;
  final int total;

  const _Header({
    required this.name,
    required this.shift,
    required this.date,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, ${name.split(' ').first}',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Turno $shift · ${DateFormat('dd/MM/yyyy').format(date)}',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$done de $total completadas',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
