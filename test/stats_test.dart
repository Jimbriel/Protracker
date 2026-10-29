import 'package:flutter_test/flutter_test.dart';
import 'package:protracker/data/catalog.dart';
import 'package:protracker/data/schedule.dart';
import 'package:protracker/data/seed_history.dart';
import 'package:protracker/data/stats.dart';
import 'package:protracker/models/cleaning_models.dart';

void main() {
  final now = DateTime(2026, 10, 29, 9);
  final all = buildSeedHistory(now);

  test('hoy cada turno y cada operario tiene tareas', () {
    final today = all.where((a) => a.date == DateTime(2026, 10, 29));
    for (final s in kShifts) {
      expect(today.where((a) => a.shift == s.letter), isNotEmpty);
    }
    for (final u in kUsers.where((u) => u.role == UserRole.operario)) {
      expect(today.where((a) => a.assignedToId == u.id), isNotEmpty,
          reason: u.name);
    }
  });

  group('DashboardStats', () {
    test('las cifras cuadran y los cubos suman el total', () {
      for (final p in StatsPeriod.values) {
        final s = DashboardStats.compute(all, p, now);
        expect(s.done + s.pending, s.total);
        expect(s.compliancePercent, inInclusiveRange(0, 100));
        expect(s.buckets.length, p == StatsPeriod.week ? 7 : 4);
        expect(s.buckets.fold<int>(0, (n, b) => n + b.done + b.pending),
            s.total);
        expect(s.doneByType.values.fold<int>(0, (n, v) => n + v), s.done);
        expect(s.avgMinutes, isNotNull);
      }
    });

    test('el mes incluye más actividades que la semana', () {
      final w = DashboardStats.compute(all, StatsPeriod.week, now);
      final m = DashboardStats.compute(all, StatsPeriod.month, now);
      expect(m.total, greaterThan(w.total));
    });

    test('sin datos no falla', () {
      final s = DashboardStats.compute([], StatsPeriod.week, now);
      expect(s.total, 0);
      expect(s.compliancePercent, 0);
      expect(s.avgMinutes, isNull);
    });
  });

  test('horario: cada operario libra un día a la semana', () {
    final u = kUsers.firstWhere((u) => u.role == UserRole.operario);
    final week = [
      for (var i = 0; i < 7; i++) scheduledShift(u, DateTime(2026, 10, 26 + i)),
    ];
    expect(week.where((s) => s == 'L').length, 1);
    expect(week.where((s) => s == u.shift).length, 6);
  });
}
