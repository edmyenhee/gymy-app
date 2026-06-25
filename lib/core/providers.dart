import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/profile_repository.dart';
import 'data/workout_repository.dart';
import 'db/app_database.dart';

/// 本地資料庫（單例）。
///
/// 這是資料存取的抽換接縫：未來要接雲端同步（如 Supabase），
/// 改這裡或覆寫 repository providers 即可，UI / 商業邏輯不動。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(appDatabaseProvider)),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(appDatabaseProvider)),
);
