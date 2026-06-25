import 'package:drift/drift.dart';

import 'enums.dart';

/// 使用者身體資料與訓練設定。
///
/// 單一使用者階段，`userId` 為固定值（見 `AppConstants.currentUserId`），
/// 同時當主鍵。體重等會變動的數值放 [BodyMetrics] 以保留歷史。
class UserProfiles extends Table {
  TextColumn get userId => text()();
  RealColumn get heightCm => real().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => textEnum<Gender>().nullable()();
  TextColumn get experience => textEnum<TrainingExperience>().nullable()();
  TextColumn get goal => textEnum<TrainingGoal>().nullable()();
  IntColumn get daysPerWeek => integer().nullable()();
  IntColumn get minutesPerSession => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

/// 體組成歷史（體重 / 體脂 / 肌肉量），含 InBody 匯入。
class BodyMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  RealColumn get muscleMassKg => real().nullable()();
  TextColumn get source => textEnum<MetricSource>()();
  TextColumn get note => text().nullable()();
}

/// AI 生成的課表（一份課表綁定一個使用者；之後第二圈再綁定 Gym）。
class WorkoutPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 課表中的一天（推日 / 拉日 / 腿日 / 休息日…）。
class PlanDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(WorkoutPlans, #id)();
  IntColumn get dayIndex => integer()(); // 一週中的順序
  TextColumn get name => text()(); // 例：推日
  TextColumn get subtitle => text().nullable()(); // 例：胸肩三頭
  BoolColumn get isRest => boolean().withDefault(const Constant(false))();
}

/// 課表某一天的計畫動作。
class PlannedExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planDayId => integer().references(PlanDays, #id)();
  IntColumn get orderIndex => integer()();
  TextColumn get name => text()();
  IntColumn get targetSets => integer()();
  IntColumn get targetReps => integer()();
  RealColumn get targetWeightKg => real().nullable()();
  IntColumn get restSeconds => integer()(); // 建議休息秒數
}

/// 一次訓練。對應到課表的哪一天（planDayId），同時保存計畫與實際。
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get planDayId =>
      integer().nullable().references(PlanDays, #id)();
  TextColumn get title => text()(); // 動作日名稱快照，例：推日 · 胸肩三頭
  TextColumn get status => textEnum<SessionStatus>()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get elapsedSeconds => integer().withDefault(const Constant(0))();
}

/// 訓練中的單一動作。帶「計畫快照」（plannedXxx），實際每組在 [LoggedSets]。
class LoggedExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id)();
  IntColumn get orderIndex => integer()();
  TextColumn get name => text()();
  // 計畫快照（來自課表，存當下值，之後課表改了不影響歷史）
  IntColumn get plannedSets => integer()();
  IntColumn get plannedReps => integer()();
  RealColumn get plannedWeightKg => real().nullable()();
  IntColumn get restSeconds => integer()();
  TextColumn get status => textEnum<ExerciseStatus>()();
}

/// 實際做的每一組。weight / reps / rpe 為實際值；rpe 選填（每組）。
class LoggedSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get loggedExerciseId =>
      integer().references(LoggedExercises, #id)();
  IntColumn get setIndex => integer()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get rpe => integer().nullable()(); // 1–10，選填
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}
