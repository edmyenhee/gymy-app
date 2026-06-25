import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/workout_repository.dart';
import '../active_workout.dart';
import '../widgets/edit_exercise_sheet.dart';
import '../workout_session_controller.dart';
import 'workout_phase_views.dart';

/// 訓練追蹤主場景的容器：依 ActiveWorkout.phase 切換畫面，並接上 controller。
///
/// 開始前持有一份可編輯的課表副本（_plan）；編輯套用到本次訓練。
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.title,
    required this.plan,
  });

  final String title;
  final List<PlannedSnapshot> plan;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late List<PlannedSnapshot> _plan = widget.plan;

  Future<void> _editExercise(int index) async {
    final p = _plan[index];
    final edited = await showEditExerciseSheet(
      context,
      name: p.name,
      sets: p.sets,
      reps: p.reps,
      restSeconds: p.restSeconds,
      weightKg: p.weightKg,
    );
    if (edited == null) return;
    setState(() {
      final updated = [..._plan];
      updated[index] = PlannedSnapshot(
        name: p.name,
        sets: edited.sets,
        reps: edited.reps,
        weightKg: edited.weightKg,
        restSeconds: edited.restSeconds,
      );
      _plan = updated;
    });
  }

  ActiveExercise _toActive(PlannedSnapshot p) => ActiveExercise(
        name: p.name,
        plannedSets: p.sets,
        plannedReps: p.reps,
        plannedWeightKg: p.weightKg,
        restSeconds: p.restSeconds,
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutSessionControllerProvider);
    final controller = ref.read(workoutSessionControllerProvider.notifier);

    // 尚未開始：用（可編輯的）課表組出預覽，顯示開始前畫面。
    if (state == null) {
      final preview = ActiveWorkout(
        title: widget.title,
        currentExerciseIndex: 0,
        phase: WorkoutPhase.preStart,
        exercises: _plan.map(_toActive).toList(),
      );
      return PreStartView(
        workout: preview,
        onBack: () => Navigator.of(context).pop(),
        onEditExercise: _editExercise,
        onStart: () => controller.start(title: widget.title, plan: _plan),
      );
    }

    switch (state.workout.phase) {
      case WorkoutPhase.recording:
        final ex = state.workout.currentExercise;
        return RecordSetView(
          exercise: ex,
          exerciseIndex: state.workout.currentExerciseIndex,
          exerciseCount: state.workout.exercises.length,
          setNumber: ex.nextSetNumber,
          elapsedSeconds: state.elapsedSeconds,
          weightKg: state.draftWeight,
          reps: state.draftReps,
          rpe: state.draftRpe,
          onWeightDelta: controller.weightDelta,
          onRepsDelta: controller.repsDelta,
          onRpe: controller.setRpe,
          onCompleteSet: controller.completeSet,
        );

      case WorkoutPhase.resting:
        // 休息只發生在同一動作的組之間，下一組就是目前動作的下一組。
        final ex = state.workout.currentExercise;
        return RestView(
          remainingSeconds: state.restRemaining,
          totalSeconds: state.restTotal,
          elapsedSeconds: state.elapsedSeconds,
          nextLabel: '${ex.name} 第 ${ex.nextSetNumber} 組',
          onSkip: controller.skipRest,
          onExtend: controller.extendRest,
        );

      case WorkoutPhase.overview:
        return OverviewView(
          workout: state.workout,
          elapsedSeconds: state.elapsedSeconds,
          onStartExercise: controller.startExercise,
          onFinish: controller.finishWorkout,
        );

      case WorkoutPhase.finished:
        return FinishedView(
          workout: state.workout,
          elapsedSeconds: state.elapsedSeconds,
          onDone: () {
            controller.exit();
            Navigator.of(context).pop();
          },
        );

      case WorkoutPhase.preStart:
        return const SizedBox.shrink();
    }
  }
}
