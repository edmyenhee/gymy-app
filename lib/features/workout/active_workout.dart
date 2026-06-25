/// 訓練流程的階段。
///
/// 動作「之內」：recording → resting → recording …（組間自動）。
/// 動作「之間」：做完一個動作 → overview（回總覽，由使用者挑下一個）。
enum WorkoutPhase { preStart, recording, resting, overview, finished }

/// 實際做的一組（記錄頁輸入；rpe 選填）。
class ActiveSetEntry {
  const ActiveSetEntry({this.weightKg, this.reps, this.rpe});

  final double? weightKg;
  final int? reps;
  final int? rpe;
}

/// 訓練中的單一動作：計畫快照 + 已記錄的實際組。
class ActiveExercise {
  const ActiveExercise({
    required this.name,
    required this.plannedSets,
    required this.plannedReps,
    required this.restSeconds,
    this.plannedWeightKg,
    this.loggedSets = const [],
  });

  final String name;
  final int plannedSets;
  final int plannedReps;
  final int restSeconds;
  final double? plannedWeightKg;
  final List<ActiveSetEntry> loggedSets;

  bool get isComplete => loggedSets.length >= plannedSets;
  bool get isStarted => loggedSets.isNotEmpty;
  int get nextSetNumber => loggedSets.length + 1;

  ActiveExercise addSet(ActiveSetEntry entry) => ActiveExercise(
        name: name,
        plannedSets: plannedSets,
        plannedReps: plannedReps,
        restSeconds: restSeconds,
        plannedWeightKg: plannedWeightKg,
        loggedSets: [...loggedSets, entry],
      );
}

/// 進行中的訓練狀態（不可變）。各轉換回傳新狀態。
class ActiveWorkout {
  const ActiveWorkout({
    required this.title,
    required this.exercises,
    required this.currentExerciseIndex,
    required this.phase,
  });

  final String title;
  final List<ActiveExercise> exercises;
  final int currentExerciseIndex;
  final WorkoutPhase phase;

  ActiveExercise get currentExercise => exercises[currentExerciseIndex];
  bool get isAllComplete => exercises.every((e) => e.isComplete);

  /// 記錄目前動作一組。
  /// 同動作還有組 → resting；該動作做完 → overview（回總覽）。
  ActiveWorkout recordSet(ActiveSetEntry entry) {
    final updated = [...exercises];
    final ex = currentExercise.addSet(entry);
    updated[currentExerciseIndex] = ex;
    return _copy(
      exercises: updated,
      phase: ex.isComplete ? WorkoutPhase.overview : WorkoutPhase.resting,
    );
  }

  /// 休息結束 → 回到目前動作的下一組記錄。
  ActiveWorkout continueAfterRest() => _copy(phase: WorkoutPhase.recording);

  /// 從總覽開始某個動作。
  ActiveWorkout startExercise(int index) =>
      _copy(currentExerciseIndex: index, phase: WorkoutPhase.recording);

  /// 結束整次訓練。
  ActiveWorkout finish() => _copy(phase: WorkoutPhase.finished);

  ActiveWorkout _copy({
    List<ActiveExercise>? exercises,
    int? currentExerciseIndex,
    WorkoutPhase? phase,
  }) =>
      ActiveWorkout(
        title: title,
        exercises: exercises ?? this.exercises,
        currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
        phase: phase ?? this.phase,
      );
}
