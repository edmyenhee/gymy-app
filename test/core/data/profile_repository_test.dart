import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymy/core/common/app_constants.dart';
import 'package:gymy/core/data/profile_repository.dart';
import 'package:gymy/core/db/app_database.dart';
import 'package:gymy/core/db/enums.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ProfileRepository(db);
  });
  tearDown(() => db.close());

  test('儲存後可讀回 profile，綁定固定 userId', () async {
    await repo.saveProfile(
      heightCm: 175,
      age: 30,
      gender: Gender.male,
      experience: TrainingExperience.intermediate,
      goal: TrainingGoal.gain,
      daysPerWeek: 4,
      minutesPerSession: 60,
    );

    final profile = await repo.getProfile();

    expect(profile, isNotNull);
    expect(profile!.userId, AppConstants.currentUserId);
    expect(profile.heightCm, 175);
    expect(profile.age, 30);
    expect(profile.goal, TrainingGoal.gain);
    expect(profile.daysPerWeek, 4);
  });

  test('再次儲存會更新同一筆而非新增', () async {
    await repo.saveProfile(heightCm: 170, goal: TrainingGoal.maintain);
    await repo.saveProfile(heightCm: 180, goal: TrainingGoal.cut);

    final rows = await db.select(db.userProfiles).get();
    expect(rows.length, 1);

    final profile = await repo.getProfile();
    expect(profile!.heightCm, 180);
    expect(profile.goal, TrainingGoal.cut);
  });
}
