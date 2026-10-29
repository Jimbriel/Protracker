import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../data/activity_rules.dart';
import '../data/demo_store.dart';
import '../models/cleaning_models.dart';
import '../widgets/activity_tile.dart';
import '../widgets/signature_pad.dart';
import '../widgets/signature_view.dart';

/// Reporte de una actividad. El supervisor puede validarlo desde aquí.
class ReportScreen extends StatelessWidget {
  final String activityId;
  const ReportScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final a = store.activityById(activityId)!;
        final e = store.equipmentById(a.equipmentId);
        final chemical = store.chemicalById(e.chemicalId);
        final operator = store.userById(a.assignedToId);
        final chief = store.userById(a.assignedById);
        final canValidate = store.currentUser?.role == UserRole.supervisor &&
            a.status == ActivityStatus.completed;
        final day = DateFormat('dd/MM/yyyy');
        final hour = DateFormat('HH:mm');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Reporte de limpieza',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.name,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusChip(
                    label: a.status.label,
                    color: statusColor(a.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Card(children: [
                _Row('Fecha', day.format(a.date)),
                _Row('Hora de inicio',
                    a.startedAt == null ? '—' : hour.format(a.startedAt!)),
                _Row('Hora de finalización',
                    a.finishedAt == null ? '—' : hour.format(a.finishedAt!)),
                _Row('Duración',
                    a.duration == null ? '—' : formatElapsed(a.duration!)),
                _Row('Tipo de actividad', a.type.label),
                _Row('Área de trabajo', e.area),
                _Row(
                  'Frecuencia',
                  '${e.frequencies.where((f) => f != CleaningType.emergency).map((f) => f.label).join(' / ')}'
                  ' (${e.frequencyCodes.join(', ')})',
                ),
                _Row('Turno', a.shift),
                _Row('Realizó', operator?.name ?? '—'),
                _Row('Asignó', chief?.name ?? '—'),
              ]),
              _Card(title: 'Utensilios utilizados', children: [
                for (final u in e.utensils) _Bullet(u),
              ]),
              _Card(title: 'Productos químicos', children: [
                if (chemical == null)
                  const _Bullet('Ninguno')
                else
                  _Bullet(
                    '${chemical.name}'
                    '${chemical.concentration == null ? '' : ' · ${chemical.concentration}'}',
                  ),
              ]),
              _Card(title: 'Checklist del procedimiento', children: [
                for (var i = 0; i < e.steps.length; i++)
                  _Step(
                    text: '${i + 1}. ${e.steps[i]}',
                    done: i < a.stepsDone.length && a.stepsDone[i],
                  ),
              ]),
              _Card(title: 'Observaciones', children: [
                Text(
                  a.observations.trim().isEmpty ? 'Sin observaciones' : a.observations,
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ]),
              _Card(title: 'Evidencia fotográfica', children: [
                if (a.photos.isEmpty)
                  Text('Sin fotos',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textHint))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in a.photos)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(p),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
              ]),
              _Card(title: 'Firmas de validación', children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SignatureView(
                        label: 'Operario\n${operator?.name ?? ''}',
                        signature: a.signatures['operario'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SignatureView(
                        label: 'Jefatura\n${chief?.name ?? ''}',
                        signature: a.signatures['jefatura'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SignatureView(
                        label: 'Supervisor',
                        signature: a.signatures['supervisor'],
                      ),
                    ),
                  ],
                ),
              ]),
              if (canValidate)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FilledButton.icon(
                    key: const ValueKey('validate'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.secondary,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final signature = await showSignatureDialog(
                        context,
                        'Firma del supervisor',
                      );
                      if (signature == null) return;
                      await store.validate(a.id, signature);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Limpieza validada')),
                      );
                    },
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Validar y firmar'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _Card({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('• $text', style: GoogleFonts.inter(fontSize: 13)),
      );
}

class _Step extends StatelessWidget {
  final String text;
  final bool done;
  const _Step({required this.text, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: done ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
