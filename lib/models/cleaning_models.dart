enum UserRole { operario, jefatura, supervisor }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.operario => 'Operario',
        UserRole.jefatura => 'Jefatura',
        UserRole.supervisor => 'Supervisor',
      };
}

enum CleaningType { daily, weekly, deep, emergency }

extension CleaningTypeLabel on CleaningType {
  String get label => switch (this) {
        CleaningType.daily => 'Diaria',
        CleaningType.weekly => 'Semanal',
        CleaningType.deep => 'Profunda',
        CleaningType.emergency => 'Emergencia',
      };
}

enum ActivityStatus { pending, inProgress, completed, validated }

extension ActivityStatusLabel on ActivityStatus {
  String get label => switch (this) {
        ActivityStatus.pending => 'Pendiente',
        ActivityStatus.inProgress => 'En proceso',
        ActivityStatus.completed => 'Por validar',
        ActivityStatus.validated => 'Validada',
      };
}

class AppUser {
  final String id;
  final String name;
  final UserRole role;

  /// Letra del turno asignado; solo aplica a operarios.
  final String? shift;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.shift,
  });
}

class Chemical {
  final String id;
  final String name;

  /// Texto listo para mostrar, por ejemplo "15 ml/litro".
  final String? concentration;

  const Chemical({required this.id, required this.name, this.concentration});
}

class Equipment {
  final String id;
  final String name;
  final String area;
  final List<String> steps;
  final List<String> utensils;
  final List<String> ppe;
  final String? chemicalId;
  final List<String> attentionPoints;

  /// Códigos tal como vienen en el documento (DT, S1, ML...).
  final List<String> frequencyCodes;
  final List<CleaningType> frequencies;

  /// Duración típica en minutos; se usa para generar el historial de ejemplo.
  final int typicalMinutes;

  const Equipment({
    required this.id,
    required this.name,
    required this.area,
    required this.steps,
    required this.utensils,
    required this.ppe,
    required this.chemicalId,
    required this.attentionPoints,
    required this.frequencyCodes,
    required this.frequencies,
    required this.typicalMinutes,
  });
}

class Shift {
  final String letter;
  final String name;
  final int startHour;
  final List<String> equipmentIds;

  const Shift({
    required this.letter,
    required this.name,
    required this.startHour,
    required this.equipmentIds,
  });
}

/// Una limpieza concreta de un equipo en una fecha.
class CleaningActivity {
  final String id;
  final String equipmentId;
  final DateTime date;
  final CleaningType type;
  final String shift;
  final String assignedToId;
  final String assignedById;
  final ActivityStatus status;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  /// Una entrada por paso del equipo: true si se realizó.
  final List<bool> stepsDone;
  final String observations;
  final List<String> photoPaths;

  /// Firmas en base64, por clave: operario, jefatura, supervisor.
  final Map<String, String> signatures;

  const CleaningActivity({
    required this.id,
    required this.equipmentId,
    required this.date,
    required this.type,
    required this.shift,
    required this.assignedToId,
    required this.assignedById,
    this.status = ActivityStatus.pending,
    this.startedAt,
    this.finishedAt,
    this.stepsDone = const [],
    this.observations = '',
    this.photoPaths = const [],
    this.signatures = const {},
  });

  Duration? get duration => (startedAt != null && finishedAt != null)
      ? finishedAt!.difference(startedAt!)
      : null;

  bool get isDone =>
      status == ActivityStatus.completed || status == ActivityStatus.validated;

  bool isOverdue(DateTime today) {
    final day = DateTime(today.year, today.month, today.day);
    return !isDone && date.isBefore(day);
  }

  CleaningActivity copyWith({
    ActivityStatus? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    List<bool>? stepsDone,
    String? observations,
    List<String>? photoPaths,
    Map<String, String>? signatures,
    String? assignedToId,
  }) {
    return CleaningActivity(
      id: id,
      equipmentId: equipmentId,
      date: date,
      type: type,
      shift: shift,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedById: assignedById,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      stepsDone: stepsDone ?? this.stepsDone,
      observations: observations ?? this.observations,
      photoPaths: photoPaths ?? this.photoPaths,
      signatures: signatures ?? this.signatures,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'equipmentId': equipmentId,
        'date': date.toIso8601String(),
        'type': type.name,
        'shift': shift,
        'assignedToId': assignedToId,
        'assignedById': assignedById,
        'status': status.name,
        'startedAt': startedAt?.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'stepsDone': stepsDone,
        'observations': observations,
        'photoPaths': photoPaths,
        'signatures': signatures,
      };

  factory CleaningActivity.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String);
    return CleaningActivity(
      id: j['id'] as String,
      equipmentId: j['equipmentId'] as String,
      date: DateTime.parse(j['date'] as String),
      type: CleaningType.values.byName(j['type'] as String),
      shift: j['shift'] as String,
      assignedToId: j['assignedToId'] as String,
      assignedById: j['assignedById'] as String,
      status: ActivityStatus.values.byName(j['status'] as String),
      startedAt: parse(j['startedAt']),
      finishedAt: parse(j['finishedAt']),
      stepsDone: (j['stepsDone'] as List).cast<bool>(),
      observations: j['observations'] as String? ?? '',
      photoPaths: (j['photoPaths'] as List).cast<String>(),
      signatures: (j['signatures'] as Map).cast<String, String>(),
    );
  }
}
