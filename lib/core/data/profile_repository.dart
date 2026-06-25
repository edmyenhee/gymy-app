import 'package:drift/drift.dart';

import '../common/app_constants.dart';
import '../db/app_database.dart';
import '../db/enums.dart';

/// 使用者身體資料與訓練設定的存取層。
///
/// 包住 Drift，對外只暴露語意化方法；所有資料綁定固定 [userId]。
class ProfileRepository {
  ProfileRepository(this._db, {this.userId = AppConstants.currentUserId});

  final AppDatabase _db;
  final String userId;

  /// 新增或更新（upsert）目前使用者的 profile。
  Future<void> saveProfile({
    double? heightCm,
    int? age,
    Gender? gender,
    TrainingExperience? experience,
    TrainingGoal? goal,
    int? daysPerWeek,
    int? minutesPerSession,
  }) async {
    await _db.into(_db.userProfiles).insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            userId: userId,
            heightCm: Value.absentIfNull(heightCm),
            age: Value.absentIfNull(age),
            gender: Value.absentIfNull(gender),
            experience: Value.absentIfNull(experience),
            goal: Value.absentIfNull(goal),
            daysPerWeek: Value.absentIfNull(daysPerWeek),
            minutesPerSession: Value.absentIfNull(minutesPerSession),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// 讀取目前使用者的 profile，沒有則回 null。
  Future<UserProfile?> getProfile() {
    return (_db.select(_db.userProfiles)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }
}
