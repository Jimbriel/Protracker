import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cleaning_models.dart';
import 'activity_rules.dart';
import 'catalog.dart';
import 'seed_history.dart';

/// Datos de la demo. El catálogo (equipos, turnos, usuarios) viene del código;
/// solo las actividades y el usuario activo se guardan en el dispositivo.
class DemoStore extends ChangeNotifier {
  DemoStore._();

  static final DemoStore instance = DemoStore._();

  static const _activitiesKey = 'demo.activities.v3';
  static const _userKey = 'demo.currentUser.v1';

  SharedPreferences? _prefs;
  List<CleaningActivity> _activities = [];
  AppUser? _currentUser;

  List<CleaningActivity> get activities => List.unmodifiable(_activities);
  AppUser? get currentUser => _currentUser;

  Future<void> init({DateTime? now}) async {
    _prefs = await SharedPreferences.getInstance();
    final today = now ?? DateTime.now();
    final saved = _load();
    // Si los datos guardados no llegan a hoy, la demo se regenera.
    final stale = saved == null || !saved.any((a) => _sameDay(a.date, today));
    _activities = stale ? buildSeedHistory(today) : saved;
    final userId = _prefs!.getString(_userKey);
    _currentUser = userId == null ? null : userById(userId);
    await _save();
    notifyListeners();
  }

  /// Vuelve al estado inicial de la demo (historial y sesión).
  Future<void> reset({DateTime? now}) async {
    _activities = buildSeedHistory(now ?? DateTime.now());
    _currentUser = null;
    await _prefs?.remove(_userKey);
    await _save();
    notifyListeners();
  }

  Future<void> signIn(AppUser user) async {
    _currentUser = user;
    await _prefs?.setString(_userKey, user.id);
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _prefs?.remove(_userKey);
    notifyListeners();
  }

  // Catálogo

  AppUser? userById(String id) {
    for (final u in kUsers) {
      if (u.id == id) return u;
    }
    return null;
  }

  Equipment equipmentById(String id) =>
      kEquipment.firstWhere((e) => e.id == id);

  Chemical? chemicalById(String? id) {
    for (final c in kChemicals) {
      if (c.id == id) return c;
    }
    return null;
  }

  // Consultas

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<CleaningActivity> activitiesOn(DateTime day, {String? shift}) => [
        for (final a in _activities)
          if (_sameDay(a.date, day) && (shift == null || a.shift == shift)) a,
      ];

  /// Tareas del día de un operario: las de su turno asignadas a él.
  List<CleaningActivity> tasksFor(AppUser user, DateTime day) => [
        for (final a in activitiesOn(day, shift: user.shift))
          if (a.assignedToId == user.id) a,
      ];

  int countByStatus(ActivityStatus status) =>
      _activities.where((a) => a.status == status).length;

  int overdueCount(DateTime now) =>
      _activities.where((a) => a.isOverdue(now)).length;

  // Cambios

  Future<void> update(CleaningActivity activity) async {
    final i = _activities.indexWhere((a) => a.id == activity.id);
    if (i < 0) return;
    _activities[i] = activity;
    await _save();
    notifyListeners();
  }

  CleaningActivity? activityById(String id) {
    for (final a in _activities) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Operario: inicia el cronómetro de la actividad.
  Future<void> start(String id, {DateTime? now}) async {
    final a = activityById(id);
    if (a == null || a.status != ActivityStatus.pending) return;
    await update(a.copyWith(
      status: ActivityStatus.inProgress,
      startedAt: now ?? DateTime.now(),
    ));
  }

  /// Operario: cierra la actividad. Devuelve lo que falta; vacío si se cerró.
  Future<List<String>> finish(String id, {DateTime? now}) async {
    final a = activityById(id);
    if (a == null) return ['La actividad ya no existe'];
    final missing = missingToFinish(a);
    if (missing.isNotEmpty) return missing;
    await update(a.copyWith(
      status: ActivityStatus.completed,
      finishedAt: now ?? DateTime.now(),
    ));
    return const [];
  }

  /// Supervisor: valida y firma una actividad terminada.
  Future<void> validate(String id, String signature) async {
    final a = activityById(id);
    if (a == null || a.status != ActivityStatus.completed) return;
    await update(a.copyWith(
      status: ActivityStatus.validated,
      signatures: {...a.signatures, 'supervisor': signature},
    ));
  }

  /// Jefatura: cambia a quién está asignada una actividad no iniciada.
  Future<void> reassign(String id, String operatorId) async {
    final a = activityById(id);
    if (a == null || a.status != ActivityStatus.pending) return;
    await update(a.copyWith(assignedToId: operatorId));
  }

  /// Jefatura: crea una limpieza de emergencia para hoy.
  Future<CleaningActivity> addEmergency({
    required String equipmentId,
    required String operatorId,
    required AppUser assignedBy,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final operator = userById(operatorId)!;
    final equipment = equipmentById(equipmentId);
    final activity = CleaningActivity(
      id: 'em-${at.millisecondsSinceEpoch}-$equipmentId',
      equipmentId: equipmentId,
      date: DateTime(at.year, at.month, at.day),
      type: CleaningType.emergency,
      shift: operator.shift ?? '',
      assignedToId: operatorId,
      assignedById: assignedBy.id,
      stepsDone: List.filled(equipment.steps.length, false),
      signatures: {
        'jefatura': '$kTextSignaturePrefix${assignedBy.name}',
      },
    );
    _activities.add(activity);
    await _save();
    notifyListeners();
    return activity;
  }

  // Persistencia

  List<CleaningActivity>? _load() {
    final raw = _prefs?.getString(_activitiesKey);
    if (raw == null) return null;
    try {
      return [
        for (final j in jsonDecode(raw) as List)
          CleaningActivity.fromJson(j as Map<String, dynamic>),
      ];
    } catch (_) {
      return null; // datos corruptos o de una versión anterior: se regeneran
    }
  }

  Future<void> _save() async {
    await _prefs?.setString(
      _activitiesKey,
      jsonEncode([for (final a in _activities) a.toJson()]),
    );
  }
}
