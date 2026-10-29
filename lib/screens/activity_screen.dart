import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../data/activity_rules.dart';
import '../data/demo_store.dart';
import '../data/photo_source.dart';
import '../models/cleaning_models.dart';
import '../widgets/activity_tile.dart';
import '../widgets/signature_pad.dart';
import '../widgets/signature_view.dart';
import 'report_screen.dart';

/// Ejecución de una limpieza: cronómetro, checklist, fotos y firma.
class ActivityScreen extends StatefulWidget {
  final String activityId;
  const ActivityScreen({super.key, required this.activityId});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _store = DemoStore.instance;
  final _notes = TextEditingController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _notes.text = _activity.observations;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _activity.status == ActivityStatus.inProgress) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notes.dispose();
    super.dispose();
  }

  CleaningActivity get _activity => _store.activityById(widget.activityId)!;

  Duration _elapsed(CleaningActivity a) {
    if (a.startedAt == null) return Duration.zero;
    return (a.finishedAt ?? DateTime.now()).difference(a.startedAt!);
  }

  Future<void> _addPhoto() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              key: const ValueKey('sample-photo'),
              leading: const Icon(Icons.image_outlined),
              title: const Text('Usar foto de muestra'),
              subtitle: const Text('Para equipos sin cámara'),
              onTap: () => Navigator.pop(ctx, 'sample'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final a = _activity;
    final photo = switch (choice) {
      'camera' => await pickPhoto(ImageSource.camera),
      'gallery' => await pickPhoto(ImageSource.gallery),
      _ => await samplePhoto(_store.equipmentById(a.equipmentId).name),
    };
    if (photo == null) return;
    await _store.update(a.copyWith(photos: [...a.photos, photo]));
  }

  Future<void> _sign() async {
    final signature = await showSignatureDialog(context, 'Firma del operario');
    if (signature == null) return;
    final a = _activity;
    await _store.update(
      a.copyWith(signatures: {...a.signatures, 'operario': signature}),
    );
  }

  Future<void> _finish() async {
    final navigator = Navigator.of(context);
    final missing = await _store.finish(widget.activityId);
    if (!mounted) return;
    if (missing.isEmpty) {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportScreen(activityId: widget.activityId),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Falta completar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final m in missing) Text('• $m')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final a = _activity;
        final equipment = _store.equipmentById(a.equipmentId);
        final chemical = _store.chemicalById(equipment.chemicalId);
        final active = a.status == ActivityStatus.inProgress;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              equipment.name,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  StatusChip(
                    label: a.status.label,
                    color: statusColor(a.status),
                  ),
                  StatusChip(label: a.type.label, color: AppColors.primary),
                  StatusChip(
                    label: 'Turno ${a.shift}',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TimerCard(
                activity: a,
                elapsed: _elapsed(a),
                onStart: () => _store.start(a.id),
                onReport: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportScreen(activityId: a.id),
                  ),
                ),
              ),
              _Section(
                title: 'Productos y utensilios',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chemical != null)
                      _Line(
                        Icons.science_outlined,
                        '${chemical.name}'
                        '${chemical.concentration == null ? '' : ' · ${chemical.concentration}'}',
                      ),
                    for (final u in equipment.utensils)
                      _Line(Icons.cleaning_services_outlined, u),
                    if (equipment.ppe.isNotEmpty)
                      _Line(Icons.health_and_safety_outlined,
                          'EPI: ${equipment.ppe.join(', ')}'),
                  ],
                ),
              ),
              if (equipment.attentionPoints.isNotEmpty)
                _Section(
                  title: 'Puntos de atención',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final p in equipment.attentionPoints)
                        _Line(Icons.warning_amber_rounded, p,
                            color: AppColors.warning),
                    ],
                  ),
                ),
              _Section(
                title: 'Checklist del procedimiento',
                child: Column(
                  children: [
                    for (var i = 0; i < equipment.steps.length; i++)
                      CheckboxListTile(
                        key: ValueKey('step-$i'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: i < a.stepsDone.length && a.stepsDone[i],
                        onChanged: active
                            ? (v) {
                                final steps = [...a.stepsDone];
                                steps[i] = v ?? false;
                                _store.update(a.copyWith(stepsDone: steps));
                              }
                            : null,
                        title: Text(
                          '${i + 1}. ${equipment.steps[i]}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              _Section(
                title: 'Observaciones',
                child: TextField(
                  key: const ValueKey('observations'),
                  controller: _notes,
                  enabled: active,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (v) => _store.update(a.copyWith(observations: v)),
                  decoration: const InputDecoration(
                    hintText: 'Obligatorio si algún paso no se realizó',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              _Section(
                title: 'Evidencia fotográfica',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (a.photos.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in a.photos)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(p),
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    if (active)
                      OutlinedButton.icon(
                        key: const ValueKey('add-photo'),
                        onPressed: _addPhoto,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Agregar foto'),
                      ),
                    if (!active && a.photos.isEmpty)
                      const Text('Sin fotos',
                          style: TextStyle(color: AppColors.textHint)),
                  ],
                ),
              ),
              _Section(
                title: 'Firma del operario',
                child: Column(
                  children: [
                    SignatureView(
                      label: _store.userById(a.assignedToId)?.name ?? '',
                      signature: a.signatures['operario'],
                    ),
                    if (active)
                      TextButton.icon(
                        key: const ValueKey('sign'),
                        onPressed: _sign,
                        icon: const Icon(Icons.draw_outlined),
                        label: Text(
                          a.signatures.containsKey('operario')
                              ? 'Volver a firmar'
                              : 'Firmar',
                        ),
                      ),
                  ],
                ),
              ),
              if (active)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton.icon(
                    key: const ValueKey('finish'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.secondary,
                    ),
                    onPressed: _finish,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Finalizar actividad'),
                  ),
                ),
              if (a.status == ActivityStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Inicie el cronómetro para registrar el checklist, las fotos y la firma.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerCard extends StatelessWidget {
  final CleaningActivity activity;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onReport;

  const _TimerCard({
    required this.activity,
    required this.elapsed,
    required this.onStart,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final status = activity.status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            formatElapsed(elapsed),
            key: const ValueKey('timer'),
            style: GoogleFonts.inter(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            switch (status) {
              ActivityStatus.pending => 'Cronómetro detenido',
              ActivityStatus.inProgress => 'Limpieza en curso',
              _ => 'Tiempo total de la limpieza',
            },
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          if (status == ActivityStatus.pending)
            FilledButton.icon(
              key: const ValueKey('start'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar'),
            ),
          if (activity.isDone)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: onReport,
              icon: const Icon(Icons.description_outlined),
              label: const Text('Ver reporte'),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Line(this.icon, this.text, {this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
