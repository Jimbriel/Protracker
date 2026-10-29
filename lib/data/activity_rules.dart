import '../models/cleaning_models.dart';

/// Lo que falta para poder cerrar una actividad; vacío si ya se puede.
List<String> missingToFinish(CleaningActivity a) {
  return [
    if (a.startedAt == null) 'Iniciar el cronómetro',
    if (a.photos.isEmpty) 'Agregar al menos una foto de evidencia',
    if (a.stepsDone.contains(false) && a.observations.trim().isEmpty)
      'Explicar en observaciones los pasos que no se realizaron',
    if (!a.signatures.containsKey('operario')) 'Firmar la actividad',
  ];
}

/// Formato mm:ss, o h:mm:ss si pasa de una hora.
String formatElapsed(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = two(d.inMinutes.remainder(60));
  final s = two(d.inSeconds.remainder(60));
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
