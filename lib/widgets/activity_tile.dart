import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';

Color statusColor(ActivityStatus s) => switch (s) {
      ActivityStatus.pending => AppColors.textSecondary,
      ActivityStatus.inProgress => AppColors.accent,
      ActivityStatus.completed => const Color(0xFF3B82F6),
      ActivityStatus.validated => AppColors.success,
    };

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Fila de una actividad en las listas de cada rol.
class ActivityTile extends StatelessWidget {
  final CleaningActivity activity;
  final VoidCallback onTap;
  final bool showAssignee;
  final bool showDate;
  final Widget? trailing;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
    this.showAssignee = false,
    this.showDate = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    final equipment = store.equipmentById(activity.equipmentId);
    final overdue = activity.isOverdue(DateTime.now());
    final color = statusColor(activity.status);
    final details = [
      activity.type.label,
      if (showDate) DateFormat('dd/MM').format(activity.date),
      'Turno ${activity.shift}',
      if (showAssignee) store.userById(activity.assignedToId)?.name ?? '',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: overdue ? AppColors.error : color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  StatusChip(
                    label: overdue ? 'Atrasada' : activity.status.label,
                    color: overdue ? AppColors.error : color,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado simple para secciones de una lista.
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
