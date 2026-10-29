import '../models/cleaning_models.dart';

enum StatsPeriod { week, month }

extension StatsPeriodInfo on StatsPeriod {
  String get label => this == StatsPeriod.week ? 'Semana' : 'Mes';
  int get days => this == StatsPeriod.week ? 7 : 28;
}

class DayBucket {
  final String label;
  final int done;
  final int pending;
  const DayBucket(this.label, this.done, this.pending);
}

/// Cifras del dashboard para un periodo que termina hoy.
class DashboardStats {
  final List<CleaningActivity> activities;
  final int total;
  final int done;
  final int pending;
  final double? avgMinutes;
  final Map<CleaningType, int> doneByType;
  final Map<String, ({int done, int total})> byEquipment;
  final Map<String, double> avgMinutesByEquipment;
  final List<DayBucket> buckets;

  DashboardStats._({
    required this.activities,
    required this.total,
    required this.done,
    required this.pending,
    required this.avgMinutes,
    required this.doneByType,
    required this.byEquipment,
    required this.avgMinutesByEquipment,
    required this.buckets,
  });

  /// Porcentaje de actividades programadas que ya se completaron.
  int get compliancePercent => total == 0 ? 0 : (done * 100 / total).round();

  factory DashboardStats.compute(
    List<CleaningActivity> all,
    StatsPeriod period,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(Duration(days: period.days - 1));
    final inPeriod = [
      for (final a in all)
        if (!a.date.isBefore(from) && !a.date.isAfter(today)) a,
    ];
    final done = inPeriod.where((a) => a.isDone).toList();

    final durations = [
      for (final a in done)
        if (a.duration != null) a.duration!.inSeconds / 60,
    ];

    final doneByType = <CleaningType, int>{};
    for (final a in done) {
      doneByType[a.type] = (doneByType[a.type] ?? 0) + 1;
    }

    final byEquipment = <String, ({int done, int total})>{};
    final minutes = <String, List<double>>{};
    for (final a in inPeriod) {
      final prev = byEquipment[a.equipmentId] ?? (done: 0, total: 0);
      byEquipment[a.equipmentId] = (
        done: prev.done + (a.isDone ? 1 : 0),
        total: prev.total + 1,
      );
      if (a.isDone && a.duration != null) {
        (minutes[a.equipmentId] ??= []).add(a.duration!.inSeconds / 60);
      }
    }

    return DashboardStats._(
      activities: inPeriod,
      total: inPeriod.length,
      done: done.length,
      pending: inPeriod.length - done.length,
      avgMinutes: durations.isEmpty
          ? null
          : durations.reduce((a, b) => a + b) / durations.length,
      doneByType: doneByType,
      byEquipment: byEquipment,
      avgMinutesByEquipment: {
        for (final e in minutes.entries)
          e.key: e.value.reduce((a, b) => a + b) / e.value.length,
      },
      buckets: _buckets(inPeriod, period, today),
    );
  }

  static List<DayBucket> _buckets(
    List<CleaningActivity> items,
    StatsPeriod period,
    DateTime today,
  ) {
    const dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    if (period == StatsPeriod.week) {
      return [
        for (var i = 6; i >= 0; i--)
          () {
            final day = today.subtract(Duration(days: i));
            final of = items.where((a) => a.date == day);
            final d = of.where((a) => a.isDone).length;
            return DayBucket(dayNames[day.weekday - 1], d, of.length - d);
          }(),
      ];
    }
    return [
      for (var w = 3; w >= 0; w--)
        () {
          final end = today.subtract(Duration(days: w * 7));
          final start = end.subtract(const Duration(days: 6));
          final of = items.where(
            (a) => !a.date.isBefore(start) && !a.date.isAfter(end),
          );
          final d = of.where((a) => a.isDone).length;
          return DayBucket('S${4 - w}', d, of.length - d);
        }(),
    ];
  }
}
