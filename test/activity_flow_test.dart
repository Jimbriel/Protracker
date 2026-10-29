import 'package:flutter_test/flutter_test.dart';
import 'package:protracker/data/activity_rules.dart';
import 'package:protracker/data/catalog.dart';
import 'package:protracker/data/demo_store.dart';
import 'package:protracker/models/cleaning_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 10, 28, 9);
  late DemoStore store;
  late CleaningActivity task;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = DemoStore.instance;
    await store.init(now: now);
    final carlos = store.userById('u-carlos')!;
    task = store.tasksFor(carlos, now).first;
  });

  Future<void> fillEverything() async {
    final a = store.activityById(task.id)!;
    await store.update(a.copyWith(
      stepsDone: List.filled(a.stepsDone.length, true),
      photos: ['foto'],
      signatures: {...a.signatures, 'operario': 'firma'},
    ));
  }

  test('formatElapsed', () {
    expect(formatElapsed(const Duration(seconds: 65)), '01:05');
    expect(formatElapsed(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03');
  });

  test('no se puede cerrar sin iniciar, foto ni firma', () async {
    final missing = await store.finish(task.id, now: now);
    expect(missing, contains('Iniciar el cronómetro'));
    expect(missing, contains('Agregar al menos una foto de evidencia'));
    expect(missing, contains('Firmar la actividad'));
    expect(store.activityById(task.id)!.status, ActivityStatus.pending);
  });

  test('pasos sin hacer exigen observación', () async {
    await store.start(task.id, now: now);
    await fillEverything();
    final a = store.activityById(task.id)!;
    final steps = [...a.stepsDone]..[0] = false;
    await store.update(a.copyWith(stepsDone: steps));
    expect(await store.finish(task.id, now: now),
        contains('Explicar en observaciones los pasos que no se realizaron'));

    await store.update(
        store.activityById(task.id)!.copyWith(observations: 'Sin tiempo'));
    expect(await store.finish(task.id, now: now), isEmpty);
  });

  test('flujo completo: iniciar, cerrar y validar', () async {
    await store.start(task.id, now: now);
    expect(store.activityById(task.id)!.status, ActivityStatus.inProgress);
    expect(store.activityById(task.id)!.startedAt, now);

    await fillEverything();
    final end = now.add(const Duration(minutes: 20));
    expect(await store.finish(task.id, now: end), isEmpty);
    final done = store.activityById(task.id)!;
    expect(done.status, ActivityStatus.completed);
    expect(done.duration, const Duration(minutes: 20));

    await store.validate(task.id, 'firma-supervisor');
    final validated = store.activityById(task.id)!;
    expect(validated.status, ActivityStatus.validated);
    expect(validated.signatures.keys,
        containsAll(['operario', 'jefatura', 'supervisor']));
  });

  test('validar solo aplica a actividades terminadas', () async {
    await store.validate(task.id, 'firma');
    expect(store.activityById(task.id)!.status, ActivityStatus.pending);
  });

  test('reasignar solo entre pendientes', () async {
    await store.reassign(task.id, 'u-marta');
    expect(store.activityById(task.id)!.assignedToId, 'u-marta');
    await store.start(task.id, now: now);
    await store.reassign(task.id, 'u-carlos');
    expect(store.activityById(task.id)!.assignedToId, 'u-marta');
  });

  test('emergencia aparece en las tareas del operario con firma de jefatura',
      () async {
    final jefa = store.userById(kJefaturaId)!;
    final created = await store.addEmergency(
      equipmentId: 'bachas',
      operatorId: 'u-luis',
      assignedBy: jefa,
      now: now,
    );
    expect(created.type, CleaningType.emergency);
    expect(created.shift, 'B');
    expect(created.signatures['jefatura'], contains(jefa.name));
    final luis = store.userById('u-luis')!;
    expect(store.tasksFor(luis, now).map((a) => a.id), contains(created.id));
  });

  test('el historial validado trae las tres firmas', () {
    final validated = store.activities
        .where((a) => a.status == ActivityStatus.validated)
        .first;
    expect(validated.signatures.keys,
        containsAll(['operario', 'jefatura', 'supervisor']));
  });
}
