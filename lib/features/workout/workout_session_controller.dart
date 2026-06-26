import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/workout_repository.dart';
import '../../core/notifications/rest_notification_service.dart';
import '../../core/providers.dart';
import 'active_workout.dart';
import 'rest_countdown.dart';

const Object _keep = Object();

/// 進行中訓練的 UI 狀態。elapsed / rest 剩餘皆由時間戳推算（背景安全）。
class WorkoutSessionState {
  const WorkoutSessionState({
    required this.workout,
    required this.sessionId,
    required this.loggedExerciseIds,
    required this.draftWeight,
    required this.draftReps,
    required this.draftRpe,
    required this.rest,
    required this.startedAt,
    required this.now,
  });

  final ActiveWorkout workout;
  final int sessionId;
  final List<int> loggedExerciseIds;
  final double draftWeight;
  final int draftReps;
  final int? draftRpe;
  final RestCountdown? rest;
  final DateTime startedAt;
  final DateTime now;

  int get elapsedSeconds {
    final s = now.difference(startedAt).inSeconds;
    return s < 0 ? 0 : s;
  }

  int get restRemaining => rest?.remainingSeconds(now) ?? 0;
  int get restTotal => rest?.totalSeconds ?? 0;

  WorkoutSessionState copyWith({
    ActiveWorkout? workout,
    double? draftWeight,
    int? draftReps,
    Object? draftRpe = _keep,
    Object? rest = _keep,
    DateTime? now,
  }) {
    return WorkoutSessionState(
      workout: workout ?? this.workout,
      sessionId: sessionId,
      loggedExerciseIds: loggedExerciseIds,
      draftWeight: draftWeight ?? this.draftWeight,
      draftReps: draftReps ?? this.draftReps,
      draftRpe: draftRpe == _keep ? this.draftRpe : draftRpe as int?,
      rest: rest == _keep ? this.rest : rest as RestCountdown?,
      startedAt: startedAt,
      now: now ?? this.now,
    );
  }
}

/// 訓練流程控制器：協調狀態機（ActiveWorkout）、資料層、休息計時與通知。
class WorkoutSessionController extends Notifier<WorkoutSessionState?> {
  Timer? _timer;
  static const int _restNotifId = 100;

  @override
  WorkoutSessionState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);
  RestNotificationService get _notif =>
      ref.read(restNotificationServiceProvider);

  /// 開始訓練：建立 session、寫入計畫快照、進入第一組記錄。
  Future<void> start({
    required String title,
    required List<PlannedSnapshot> plan,
  }) async {
    final sessionId = await _repo.startSession(title: title, exercises: plan);
    final detail = await _repo.getSession(sessionId);
    final loggedIds = detail.exercises.map((e) => e.exercise.id).toList();

    final exercises = plan
        .map((p) => ActiveExercise(
              name: p.name,
              plannedSets: p.sets,
              plannedReps: p.reps,
              plannedWeightKg: p.weightKg,
              restSeconds: p.restSeconds,
            ))
        .toList();
    final workout = ActiveWorkout(
      title: title,
      exercises: exercises,
      currentExerciseIndex: 0,
      phase: WorkoutPhase.recording,
    );
    final now = DateTime.now();
    state = WorkoutSessionState(
      workout: workout,
      sessionId: sessionId,
      loggedExerciseIds: loggedIds,
      draftWeight: exercises.first.plannedWeightKg ?? 20,
      draftReps: exercises.first.plannedReps,
      draftRpe: null,
      rest: null,
      startedAt: now,
      now: now,
    );
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void weightDelta(double d) {
    final s = state;
    if (s == null) return;
    var w = s.draftWeight + d;
    if (w < 0) w = 0;
    state = s.copyWith(draftWeight: w);
  }

  void repsDelta(int d) {
    final s = state;
    if (s == null) return;
    var r = s.draftReps + d;
    if (r < 1) r = 1;
    state = s.copyWith(draftReps: r);
  }

  void setWeight(double w) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(draftWeight: w < 0 ? 0 : w);
  }

  void setReps(int r) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(draftReps: r < 1 ? 1 : r);
  }

  void setRpe(int? v) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(draftRpe: v);
  }

  /// 完成這組：寫 DB → 記錄到狀態。
  /// 同動作還有組 → 進入休息並排通知；該動作做完 → 回總覽。
  Future<void> completeSet() async {
    final s = state;
    if (s == null) return;
    final exIndex = s.workout.currentExerciseIndex;
    final setNumber = s.workout.currentExercise.nextSetNumber;

    await _repo.logSet(
      s.loggedExerciseIds[exIndex],
      setIndex: setNumber,
      weightKg: s.draftWeight,
      reps: s.draftReps,
      rpe: s.draftRpe,
    );

    final entry = ActiveSetEntry(
      weightKg: s.draftWeight,
      reps: s.draftReps,
      rpe: s.draftRpe,
    );
    final workout = s.workout.recordSet(entry);

    if (workout.phase == WorkoutPhase.resting) {
      final rest = RestCountdown.start(
        totalSeconds: s.workout.currentExercise.restSeconds,
        now: DateTime.now(),
      );
      await _notif.scheduleRestEnd(id: _restNotifId, endsAt: rest.endsAt);
      state = s.copyWith(workout: workout, rest: rest, draftRpe: null);
    } else {
      // 動作做完 → 回總覽，不休息
      state = s.copyWith(workout: workout, rest: null, draftRpe: null);
    }
  }

  Future<void> skipRest() async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(rest: null);
    await _notif.cancel(_restNotifId);
    _continueAfterRest();
  }

  Future<void> extendRest() async {
    final s = state;
    if (s == null || s.rest == null) return;
    final rest = s.rest!.extend(30);
    await _notif.scheduleRestEnd(id: _restNotifId, endsAt: rest.endsAt);
    state = s.copyWith(rest: rest);
  }

  /// 從總覽開始（或繼續）某個動作。
  void startExercise(int index) {
    final s = state;
    if (s == null) return;
    final workout = s.workout.startExercise(index);
    final ex = workout.currentExercise;
    state = s.copyWith(
      workout: workout,
      rest: null,
      draftWeight: ex.plannedWeightKg ?? s.draftWeight,
      draftReps: ex.plannedReps,
      draftRpe: null,
    );
  }

  /// 結束訓練：標記 DB 完成、停止計時。
  Future<void> finishWorkout() async {
    final s = state;
    if (s == null) return;
    await _repo.completeSession(s.sessionId, elapsedSeconds: s.elapsedSeconds);
    _timer?.cancel();
    _timer = null;
    state = s.copyWith(workout: s.workout.finish(), rest: null);
  }

  void exit() {
    _timer?.cancel();
    _timer = null;
    state = null;
  }

  void _tick() {
    final s = state;
    if (s == null) return;
    final now = DateTime.now();
    if (s.rest != null && s.rest!.isDone(now)) {
      state = s.copyWith(rest: null, now: now); // 清 rest 防重入
      _continueAfterRest();
    } else {
      state = s.copyWith(now: now);
    }
  }

  /// 休息結束 / 跳過 → 回到目前動作的下一組。
  void _continueAfterRest() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(workout: s.workout.continueAfterRest(), rest: null);
  }
}

final workoutSessionControllerProvider =
    NotifierProvider<WorkoutSessionController, WorkoutSessionState?>(
  WorkoutSessionController.new,
);
