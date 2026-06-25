import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    BodyMetrics,
    WorkoutPlans,
    PlanDays,
    PlannedExercises,
    WorkoutSessions,
    LoggedExercises,
    LoggedSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// 預設開啟本地檔案；測試可傳入 `NativeDatabase.memory()`。
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'gymy.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
