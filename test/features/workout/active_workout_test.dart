import 'package:flutter_test/flutter_test.dart';
import 'package:gymy/features/workout/active_workout.dart';

void main() {
  // 臥推 2 組、肩推 1 組。
  ActiveWorkout build() => const ActiveWorkout(
        title: '推日',
        currentExerciseIndex: 0,
        phase: WorkoutPhase.recording,
        exercises: [
          ActiveExercise(
            name: '臥推',
            plannedSets: 2,
            plannedReps: 5,
            restSeconds: 90,
          ),
          ActiveExercise(
            name: '肩推',
            plannedSets: 1,
            plannedReps: 8,
            restSeconds: 75,
          ),
        ],
      );

  const set = ActiveSetEntry(weightKg: 60, reps: 5);

  test('recordSet：同動作還有組 → 進入休息', () {
    final w = build().recordSet(
      const ActiveSetEntry(weightKg: 60, reps: 5, rpe: 8),
    );

    expect(w.phase, WorkoutPhase.resting);
    expect(w.currentExercise.loggedSets.length, 1);
    expect(w.currentExercise.loggedSets.single.rpe, 8);
    expect(w.currentExercise.isComplete, isFalse);
    expect(w.currentExercise.nextSetNumber, 2);
  });

  test('continueAfterRest：休息結束回到同動作下一組', () {
    final w = build().recordSet(set).continueAfterRest();

    expect(w.phase, WorkoutPhase.recording);
    expect(w.currentExerciseIndex, 0);
    expect(w.currentExercise.nextSetNumber, 2);
  });

  test('recordSet：做完該動作最後一組 → 回總覽（不自動跳下一動作）', () {
    final w = build().recordSet(set).continueAfterRest().recordSet(set);

    expect(w.phase, WorkoutPhase.overview);
    expect(w.currentExercise.isComplete, isTrue);
    expect(w.isAllComplete, isFalse); // 肩推還沒做
  });

  test('startExercise：從總覽開始指定動作', () {
    final overview = build().recordSet(set).continueAfterRest().recordSet(set);
    final w = overview.startExercise(1);

    expect(w.phase, WorkoutPhase.recording);
    expect(w.currentExerciseIndex, 1);
    expect(w.currentExercise.name, '肩推');
    expect(w.currentExercise.nextSetNumber, 1);
  });

  test('全部動作完成 → isAllComplete 為真，finish 後 finished', () {
    final w = build()
        .recordSet(set)
        .continueAfterRest()
        .recordSet(set) // 臥推完成 → overview
        .startExercise(1)
        .recordSet(set); // 肩推 1 組完成 → overview

    expect(w.phase, WorkoutPhase.overview);
    expect(w.isAllComplete, isTrue);
    expect(w.finish().phase, WorkoutPhase.finished);
  });
}
