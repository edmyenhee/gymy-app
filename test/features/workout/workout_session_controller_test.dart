import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymy/core/data/workout_repository.dart';
import 'package:gymy/core/db/app_database.dart';
import 'package:gymy/core/db/enums.dart';
import 'package:gymy/core/providers.dart';
import 'package:gymy/features/workout/active_workout.dart';
import 'package:gymy/features/workout/workout_session_controller.dart';

void main() {
  ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );

  test('start → completeSet：寫入 DB 並進入休息（含 RPE）', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final controller =
        container.read(workoutSessionControllerProvider.notifier);

    await controller.start(
      title: '推日',
      plan: const [
        PlannedSnapshot(
            name: '臥推', sets: 3, reps: 5, weightKg: 60, restSeconds: 90),
      ],
    );

    WorkoutSessionState? s = container.read(workoutSessionControllerProvider);
    expect(s, isNotNull);
    expect(s!.workout.phase, WorkoutPhase.recording);
    expect(s.draftWeight, 60);
    expect(s.draftReps, 5);

    controller.setRpe(8);
    await controller.completeSet();

    final WorkoutSessionState? after =
        container.read(workoutSessionControllerProvider);
    expect(after!.workout.phase, WorkoutPhase.resting);
    expect(after.workout.currentExercise.loggedSets.length, 1);
    expect(after.rest, isNotNull);

    final repo = container.read(workoutRepositoryProvider);
    final detail = await repo.getSession(after.sessionId);
    expect(detail.exercises.first.sets.length, 1);
    expect(detail.exercises.first.sets.single.rpe, 8);
    expect(detail.exercises.first.sets.single.weightKg, 60);
  });

  test('skipRest 推進到同動作下一組', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final controller =
        container.read(workoutSessionControllerProvider.notifier);

    await controller.start(
      title: '推日',
      plan: const [
        PlannedSnapshot(
            name: '臥推', sets: 3, reps: 5, weightKg: 60, restSeconds: 90),
      ],
    );
    await controller.completeSet();
    await controller.skipRest();

    final WorkoutSessionState? s =
        container.read(workoutSessionControllerProvider);
    expect(s!.workout.phase, WorkoutPhase.recording);
    expect(s.workout.currentExercise.nextSetNumber, 2);
  });

  test('completeSet 做完動作最後一組 → 回總覽、不休息', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final controller =
        container.read(workoutSessionControllerProvider.notifier);

    await controller.start(
      title: '推日',
      plan: const [
        PlannedSnapshot(
            name: '臥推', sets: 1, reps: 5, weightKg: 60, restSeconds: 90),
      ],
    );
    await controller.completeSet();

    final WorkoutSessionState? s =
        container.read(workoutSessionControllerProvider);
    expect(s!.workout.phase, WorkoutPhase.overview);
    expect(s.rest, isNull);
    expect(s.workout.isAllComplete, isTrue);
  });

  test('startExercise 從總覽開始另一動作；finishWorkout 標記 session 完成', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final controller =
        container.read(workoutSessionControllerProvider.notifier);

    await controller.start(
      title: '推日',
      plan: const [
        PlannedSnapshot(
            name: '臥推', sets: 1, reps: 5, weightKg: 60, restSeconds: 90),
        PlannedSnapshot(
            name: '肩推', sets: 1, reps: 8, weightKg: 30, restSeconds: 75),
      ],
    );
    await controller.completeSet(); // 臥推完成 → overview

    controller.startExercise(1);
    final WorkoutSessionState? mid =
        container.read(workoutSessionControllerProvider);
    expect(mid!.workout.phase, WorkoutPhase.recording);
    expect(mid.workout.currentExercise.name, '肩推');

    await controller.completeSet(); // 肩推完成 → 全部完成
    await controller.finishWorkout();

    final WorkoutSessionState? s =
        container.read(workoutSessionControllerProvider);
    expect(s!.workout.phase, WorkoutPhase.finished);

    final repo = container.read(workoutRepositoryProvider);
    final detail = await repo.getSession(s.sessionId);
    expect(detail.session.status, SessionStatus.completed);
  });
}
