import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cleaning_models.dart';
import 'catalog.dart';
import 'seed_history.dart';

/// Datos de la demo. El catálogo (equipos, turnos, usuarios) viene del código;
/// solo las actividades y el usuario activo se guardan en el dispositivo.
class DemoStore extends ChangeNotifier {
  DemoStore._();

  static final DemoStore instance = DemoStore._();

  static const _activitiesKey = 'demo.activities.v1';
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
