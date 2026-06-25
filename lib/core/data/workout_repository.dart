import 'package:drift/drift.dart';

import '../common/app_constants.dart';
import '../db/app_database.dart';
import '../db/enums.dart';

/// 課表動作的計畫快照（startSession 時寫入 LoggedExercise）。
class PlannedSnapshot {
  const PlannedSnapshot({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weightKg,
  });

  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final double? weightKg;
}

/// 一次訓練的完整內容（含每個動作的計畫與實際每組）。
class SessionDetail {
  const SessionDetail({required this.session, required this.exercises});

  final WorkoutSession session;
  final List<LoggedExerciseDetail> exercises;
}

/// 單一動作：計畫快照（exercise.plannedXxx）+ 實際每組（sets）。
class LoggedExerciseDetail {
  const LoggedExerciseDetail({required this.exercise, required this.sets});

  final LoggedExercise exercise;
  final List<LoggedSet> sets;
}

/// 訓練 session 的存取層。同時保存計畫與實際，供週期回顧分析。
class WorkoutRepository {
  WorkoutRepository(this._db, {this.userId = AppConstants.currentUserId});

  final AppDatabase _db;
  final String userId;

  /// 開始一次訓練：建立 session 並把課表動作以「計畫快照」寫入。
  Future<int> startSession({
    required String title,
    required List<PlannedSnapshot> exercises,
    int? planDayId,
  }) {
    return _db.transaction(() async {
      final sessionId = await _db.into(_db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              userId: userId,
              title: title,
              status: SessionStatus.inProgress,
              planDayId: Value.absentIfNull(planDayId),
            ),
          );

      for (var i = 0; i < exercises.length; i++) {
        final e = exercises[i];
        await _db.into(_db.loggedExercises).insert(
              LoggedExercisesCompanion.insert(
                sessionId: sessionId,
                orderIndex: i,
                name: e.name,
                plannedSets: e.sets,
                plannedReps: e.reps,
                plannedWeightKg: Value.absentIfNull(e.weightKg),
                restSeconds: e.restSeconds,
                status: ExerciseStatus.notStarted,
              ),
            );
      }
      return sessionId;
    });
  }

  /// 記錄某動作的實際一組（weight / reps / rpe；rpe 選填）。
  Future<void> logSet(
    int loggedExerciseId, {
    required int setIndex,
    double? weightKg,
    int? reps,
    int? rpe,
    bool isDone = true,
  }) async {
    await _db.into(_db.loggedSets).insert(
          LoggedSetsCompanion.insert(
            loggedExerciseId: loggedExerciseId,
            setIndex: setIndex,
            weightKg: Value.absentIfNull(weightKg),
            reps: Value.absentIfNull(reps),
            rpe: Value.absentIfNull(rpe),
            isDone: Value(isDone),
            completedAt: Value(isDone ? DateTime.now() : null),
          ),
        );
  }

  /// 標記訓練完成：狀態設為 completed、存完成時間與總時長。
  Future<void> completeSession(
    int sessionId, {
    required int elapsedSeconds,
  }) async {
    await (_db.update(_db.workoutSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(
      WorkoutSessionsCompanion(
        status: const Value(SessionStatus.completed),
        completedAt: Value(DateTime.now()),
        elapsedSeconds: Value(elapsedSeconds),
      ),
    );
  }

  /// 讀取整次訓練（session → 動作（依序）→ 每組（依序））。
  Future<SessionDetail> getSession(int sessionId) async {
    final session = await (_db.select(_db.workoutSessions)
          ..where((t) => t.id.equals(sessionId)))
        .getSingle();

    final exercises = await (_db.select(_db.loggedExercises)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();

    final details = <LoggedExerciseDetail>[];
    for (final ex in exercises) {
      final sets = await (_db.select(_db.loggedSets)
            ..where((t) => t.loggedExerciseId.equals(ex.id))
            ..orderBy([(t) => OrderingTerm(expression: t.setIndex)]))
          .get();
      details.add(LoggedExerciseDetail(exercise: ex, sets: sets));
    }

    return SessionDetail(session: session, exercises: details);
  }
}
