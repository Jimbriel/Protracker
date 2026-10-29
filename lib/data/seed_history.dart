import 'dart:math';

import '../models/cleaning_models.dart';
import 'catalog.dart';

const kHistoryDays = 28;

/// Qué tipos de limpieza toca hacer de un equipo en una fecha.
///
/// Supuesto de la demo: la diaria es todos los días, la semanal cae en un día
/// fijo por equipo (lunes a viernes) y la profunda los sábados.
List<CleaningType> scheduledTypes(Equipment e, DateTime date, int index) {
  return [
    for (final f in e.frequencies)
      if (switch (f) {
        CleaningType.daily => true,
        CleaningType.weekly => date.weekday == 1 + index % 5,
        CleaningType.deep => date.weekday == DateTime.saturday,
        CleaningType.emergency => false,
      })
        f,
  ];
}

/// Historial de ejemplo: [kHistoryDays] días hacia atrás más el día de hoy.
/// Es determinista: la misma fecha produce siempre los mismos datos.
List<CleaningActivity> buildSeedHistory(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final rng = Random(42);
  final operatorsByShift = <String, List<AppUser>>{
    for (final s in kShifts)
      s.letter: kUsers.where((u) => u.shift == s.letter).toList(),
  };
  final activities = <CleaningActivity>[];

  for (var back = kHistoryDays; back >= 0; back--) {
    final date = today.subtract(Duration(days: back));
    for (final shift in kShifts) {
      final operators = operatorsByShift[shift.letter]!;
      for (final eqId in shift.equipmentIds) {
        final index = kEquipment.indexWhere((e) => e.id == eqId);
        final equipment = kEquipment[index];
        for (final type in scheduledTypes(equipment, date, index)) {
          final operator = operators[(date.day + index) % operators.length];
          final id = '${_ymd(date)}-$eqId-${type.name}';
          final base = CleaningActivity(
            id: id,
            equipmentId: eqId,
            date: date,
            type: type,
            shift: shift.letter,
            assignedToId: operator.id,
            assignedById: kJefaturaId,
            stepsDone: List.filled(equipment.steps.length, false),
            signatures: {'jefatura': _textSignature(kJefaturaId)},
          );
          activities.add(
            back == 0 ? base : _completePast(base, equipment, shift, rng, back),
          );
        }
      }
    }
  }
  return activities;
}

CleaningActivity _completePast(
  CleaningActivity base,
  Equipment equipment,
  Shift shift,
  Random rng,
  int daysBack,
) {
  final roll = rng.nextDouble();
  // ~10% de las limpiezas pasadas quedaron sin hacer (atrasadas).
  if (roll >= 0.90) return base;

  final minutes = max(5, equipment.typicalMinutes + rng.nextInt(11) - 5);
  final start = base.date.add(
    Duration(hours: shift.startHour, minutes: rng.nextInt(120)),
  );
  final end = start.add(Duration(minutes: minutes));
  final steps = [
    for (var i = 0; i < equipment.steps.length; i++) rng.nextDouble() > 0.04,
  ];
  // Lo más reciente puede seguir esperando validación del supervisor.
  final awaiting = daysBack <= 2 && roll >= 0.60;
  return base.copyWith(
    signatures: {
      ...base.signatures,
      'operario': _textSignature(base.assignedToId),
      if (!awaiting) 'supervisor': _textSignature(kSupervisorId),
    },
    status: awaiting ? ActivityStatus.completed : ActivityStatus.validated,
    startedAt: start,
    finishedAt: end,
    stepsDone: steps,
    observations: steps.contains(false) ? 'Paso omitido por falta de tiempo.' : '',
  );
}

String _textSignature(String userId) =>
    '$kTextSignaturePrefix${kUsers.firstWhere((u) => u.id == userId).name}';

String _ymd(DateTime d) =>
    '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
