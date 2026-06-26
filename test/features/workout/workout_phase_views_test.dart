import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymy/features/workout/active_workout.dart';
import 'package:gymy/features/workout/screens/workout_phase_views.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(Widget child) => MaterialApp(home: child);

  testWidgets('RecordSetView 顯示目標與完成鈕，RPE/完成回呼可觸發', (tester) async {
    var completed = false;
    int? pickedRpe = -1;

    await tester.pumpWidget(host(RecordSetView(
      exercise: const ActiveExercise(
        name: '臥推',
        plannedSets: 3,
        plannedReps: 5,
        restSeconds: 90,
        plannedWeightKg: 60,
      ),
      exerciseIndex: 0,
      exerciseCount: 2,
      setNumber: 1,
      elapsedSeconds: 65,
      weightKg: 60,
      reps: 5,
      rpe: null,
      onWeightDelta: (_) {},
      onRepsDelta: (_) {},
      onWeightSet: (_) {},
      onRepsSet: (_) {},
      onRpe: (v) => pickedRpe = v,
      onCompleteSet: () => completed = true,
    )));

    expect(find.text('臥推'), findsOneWidget);
    expect(find.textContaining('目標 3×5'), findsOneWidget);
    expect(find.text('SET '), findsOneWidget);
    expect(find.text(' / 3'), findsOneWidget);
    expect(find.text('完成這組'), findsOneWidget);

    await tester.tap(find.text('8')); // 點 RPE pill
    expect(pickedRpe, 8);

    await tester.tap(find.text('完成這組'));
    expect(completed, isTrue);
  });

  testWidgets('FinishedView 顯示計畫 vs 實際', (tester) async {
    const workout = ActiveWorkout(
      title: '推日',
      currentExerciseIndex: 0,
      phase: WorkoutPhase.finished,
      exercises: [
        ActiveExercise(
          name: '臥推',
          plannedSets: 1,
          plannedReps: 5,
          restSeconds: 90,
          plannedWeightKg: 60,
          loggedSets: [ActiveSetEntry(weightKg: 55, reps: 5, rpe: 8)],
        ),
      ],
    );

    await tester.pumpWidget(host(
      FinishedView(workout: workout, elapsedSeconds: 1850, onDone: () {}),
    ));

    expect(find.text('訓練完成！'), findsOneWidget);
    expect(find.textContaining('計畫 1 組 × 5 下 · 60kg'), findsOneWidget);
    expect(find.textContaining('實際 55×5@8'), findsOneWidget);
  });

  testWidgets('PreStartView 點「改」會帶正確 index 觸發 onEditExercise', (tester) async {
    int? editedIndex;
    const workout = ActiveWorkout(
      title: '推日',
      currentExerciseIndex: 0,
      phase: WorkoutPhase.preStart,
      exercises: [
        ActiveExercise(
            name: '臥推',
            plannedSets: 3,
            plannedReps: 5,
            restSeconds: 90,
            plannedWeightKg: 60),
        ActiveExercise(
            name: '肩推',
            plannedSets: 3,
            plannedReps: 8,
            restSeconds: 75,
            plannedWeightKg: 30),
      ],
    );

    await tester.pumpWidget(host(PreStartView(
      workout: workout,
      onStart: () {},
      onEditExercise: (i) => editedIndex = i,
    )));

    expect(find.text('改'), findsNWidgets(2));
    await tester.tap(find.text('改').last);
    expect(editedIndex, 1);
  });
}
