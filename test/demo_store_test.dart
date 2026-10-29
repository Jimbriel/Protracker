import 'package:flutter_test/flutter_test.dart';
import 'package:protracker/data/catalog.dart';
import 'package:protracker/data/demo_store.dart';
import 'package:protracker/data/seed_history.dart';
import 'package:protracker/models/cleaning_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Miércoles: toca diaria y la semanal de los equipos con índice 2.
  final now = DateTime(2026, 10, 28, 9);
  final today = DateTime(2026, 10, 28);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('catálogo', () {
    test('cada equipo de un turno existe y está en un solo turno', () {
      final ids = kEquipment.map((e) => e.id).toSet();
      final seen = <String>{};
      for (final s in kShifts) {
        for (final id in s.equipmentIds) {
          expect(ids, contains(id));
          expect(seen.add(id), isTrue, reason: '$id repetido en turnos');
        }
      }
      expect(seen, ids, reason: 'todos los equipos tienen turno');
    });

    test('químicos referenciados existen', () {
      final chems = kChemicals.map((c) => c.id).toSet();
      for (final e in kEquipment) {
        if (e.chemicalId != null) expect(chems, contains(e.chemicalId));
      }
    });

    test('cada operario tiene un turno que existe', () {
      final letters = kShifts.map((s) => s.letter).toSet();
      for (final u in kUsers.where((u) => u.role == UserRole.operario)) {
        expect(letters, contains(u.shift));
      }
    });
  });

  group('historial de ejemplo', () {
    test('es determinista', () {
      final a = buildSeedHistory(now).map((e) => e.toJson().toString());
      final b = buildSeedHistory(now).map((e) => e.toJson().toString());
      expect(a.toList(), b.toList());
    });

    test('los ids son únicos y hoy todo está pendiente', () {
      final all = buildSeedHistory(now);
      expect(all.map((a) => a.id).toSet().length, all.length);
      final hoy = all.where((a) => a.date == today);
      expect(hoy, isNotEmpty);
      expect(hoy.every((a) => a.status == ActivityStatus.pending), isTrue);
    });

    test('hay actividades en todos los estados', () {
      final all = buildSeedHistory(now);
      for (final s in [
        ActivityStatus.pending,
        ActivityStatus.completed,
        ActivityStatus.validated,
      ]) {
        expect(all.any((a) => a.status == s), isTrue, reason: 'falta $s');
      }
      expect(all.any((a) => a.isOverdue(now)), isTrue);
    });
  });

  group('DemoStore', () {
    test('tasksFor devuelve solo las tareas del operario en su turno', () async {
      final store = DemoStore.instance;
      await store.init(now: now);
      final carlos = store.userById('u-carlos')!;
      final tasks = store.tasksFor(carlos, today);
      for (final t in tasks) {
        expect(t.assignedToId, carlos.id);
        expect(t.shift, 'H');
      }
    });

    test('los cambios se guardan y se recuperan', () async {
      final store = DemoStore.instance;
      await store.init(now: now);
      final first = store.activitiesOn(today).first;
      await store.update(first.copyWith(status: ActivityStatus.inProgress));

      await store.init(now: now); // simula reabrir la app
      expect(
        store.activities.firstWhere((a) => a.id == first.id).status,
        ActivityStatus.inProgress,
      );
    });

    test('reset restaura el historial y cierra la sesión', () async {
      final store = DemoStore.instance;
      await store.init(now: now);
      await store.signIn(store.userById('u-ana')!);
      final first = store.activitiesOn(today).first;
      await store.update(first.copyWith(status: ActivityStatus.validated));

      await store.reset(now: now);
      expect(store.currentUser, isNull);
      expect(
        store.activities.firstWhere((a) => a.id == first.id).status,
        ActivityStatus.pending,
      );
    });

    test('si lo guardado no llega a hoy, se regenera', () async {
      final store = DemoStore.instance;
      await store.init(now: now);
      final tomorrow = today.add(const Duration(days: 1));
      await store.init(now: tomorrow);
      expect(store.activitiesOn(tomorrow), isNotEmpty);
    });

    test('JSON de una actividad es reversible', () {
      final a = buildSeedHistory(now).firstWhere(
        (a) => a.status == ActivityStatus.validated,
      );
      final b = CleaningActivity.fromJson(a.toJson());
      expect(b.toJson(), a.toJson());
    });
  });
}
