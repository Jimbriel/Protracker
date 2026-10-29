import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/catalog.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import 'report_screen.dart';

/// Inicio de la jefatura: tareas de hoy por turno, reasignación y emergencias.
class AssignScreen extends StatelessWidget {
  const AssignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final now = DateTime.now();
        final today = store.activitiesOn(now);
        final done = today.where((a) => a.isDone).length;

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
              'Asignación',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            actions: const [AppBarActions()],
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          drawer: const AppDrawer(),
          floatingActionButton: FloatingActionButton.extended(
            key: const ValueKey('new-emergency'),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            onPressed: () => _newEmergency(context),
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Emergencia'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(
                '${DateFormat('dd/MM/yyyy').format(now)} · '
                '$done de ${today.length} completadas',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (today.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: EmptyState(label: 'No hay tareas para hoy'),
                ),
              for (final shift in kShifts)
                ..._shiftSection(context, store, shift, today),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _shiftSection(
    BuildContext context,
    DemoStore store,
    Shift shift,
    List<CleaningActivity> today,
  ) {
    final items = today.where((a) => a.shift == shift.letter).toList();
    if (items.isEmpty) return const [];
    return [
      SectionTitle(shift.name.toUpperCase()),
      for (final a in items)
        ActivityTile(
          activity: a,
          showAssignee: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportScreen(activityId: a.id)),
          ),
          trailing: a.status == ActivityStatus.pending
              ? _ReassignButton(activity: a)
              : null,
        ),
    ];
  }

  Future<void> _newEmergency(BuildContext context) async {
    final store = DemoStore.instance;
    final messenger = ScaffoldMessenger.of(context);
    final user = store.currentUser!;
    String equipmentId = kEquipment.first.id;
    String operatorId = kUsers.firstWhere((u) => u.shift != null).id;
    final operators = kUsers.where((u) => u.role == UserRole.operario).toList();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Limpieza de emergencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                key: const ValueKey('emergency-equipment'),
                initialValue: equipmentId,
                decoration: const InputDecoration(labelText: 'Equipo'),
                items: [
                  for (final e in kEquipment)
                    DropdownMenuItem(value: e.id, child: Text(e.name)),
                ],
                onChanged: (v) => setState(() => equipmentId = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const ValueKey('emergency-operator'),
                initialValue: operatorId,
                decoration: const InputDecoration(labelText: 'Asignar a'),
                items: [
                  for (final u in operators)
                    DropdownMenuItem(
                      value: u.id,
                      child: Text('${u.name} (${u.shift})'),
                    ),
                ],
                onChanged: (v) => setState(() => operatorId = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const ValueKey('emergency-create'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await store.addEmergency(
      equipmentId: equipmentId,
      operatorId: operatorId,
      assignedBy: user,
    );
    messenger.showSnackBar(
      const SnackBar(content: Text('Limpieza de emergencia asignada')),
    );
  }
}

class _ReassignButton extends StatelessWidget {
  final CleaningActivity activity;
  const _ReassignButton({required this.activity});

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    final candidates = kUsers
        .where((u) => u.role == UserRole.operario && u.shift == activity.shift)
        .toList();
    return PopupMenuButton<String>(
      tooltip: 'Reasignar',
      icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
      onSelected: (id) => store.reassign(activity.id, id),
      itemBuilder: (_) => [
        for (final u in candidates)
          CheckedPopupMenuItem(
            value: u.id,
            checked: u.id == activity.assignedToId,
            child: Text(u.name),
          ),
      ],
    );
  }
}
