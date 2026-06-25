import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymy/core/data/workout_repository.dart';
import 'package:gymy/core/db/app_database.dart';
import 'package:gymy/core/db/enums.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WorkoutRepository(db);
  });
  tearDown(() => db.close());

  test('開始訓練會建立 session 與帶計畫快照的動作，尚無實際組', () async {
    final id = await repo.startSession(
      title: '推日 · 胸肩三頭',
      exercises: const [
        PlannedSnapshot(name: '臥推', sets: 3, reps: 5, weightKg: 60, restSeconds: 90),
        PlannedSnapshot(name: '肩推', sets: 3, reps: 8, weightKg: 30, restSeconds: 75),
      ],
    );

    final detail = await repo.getSession(id);
    expect(detail.session.title, '推日 · 胸肩三頭');
    expect(detail.session.status, SessionStatus.inProgress);
    expect(detail.exercises.length, 2);

    final bench = detail.exercises.first;
    expect(bench.exercise.name, '臥推');
    expect(bench.exercise.plannedWeightKg, 60);
    expect(bench.exercise.plannedSets, 3);
    expect(bench.exercise.status, ExerciseStatus.notStarted);
    expect(bench.sets, isEmpty);
  });

  test('記錄實際組會同時保留計畫與實際，含 RPE', () async {
    final id = await repo.startSession(
      title: '推日',
      exercises: const [
        PlannedSnapshot(name: '臥推', sets: 3, reps: 5, weightKg: 60, restSeconds: 90),
      ],
    );
    final benchId = (await repo.getSession(id)).exercises.first.exercise.id;

    // 計畫 60×5，實際只做 55×5、RPE 8
    await repo.logSet(benchId, setIndex: 1, weightKg: 55, reps: 5, rpe: 8);

    final bench = (await repo.getSession(id)).exercises.first;
    expect(bench.exercise.plannedWeightKg, 60); // 計畫保留
    expect(bench.sets.single.weightKg, 55); // 實際
    expect(bench.sets.single.reps, 5);
    expect(bench.sets.single.rpe, 8); // RPE 有存
    expect(bench.sets.single.isDone, isTrue);
  });

  test('RPE 為選填，可不帶', () async {
    final id = await repo.startSession(
      title: '推日',
      exercises: const [
        PlannedSnapshot(name: '臥推', sets: 3, reps: 5, weightKg: 60, restSeconds: 90),
      ],
    );
    final benchId = (await repo.getSession(id)).exercises.first.exercise.id;

    await repo.logSet(benchId, setIndex: 1, weightKg: 60, reps: 5);

    final set = (await repo.getSession(id)).exercises.first.sets.single;
    expect(set.rpe, isNull);
    expect(set.weightKg, 60);
  });
}
