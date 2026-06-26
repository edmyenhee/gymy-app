import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymy/core/common/app_constants.dart';
import 'package:gymy/core/data/body_metrics_repository.dart';
import 'package:gymy/core/db/app_database.dart';

void main() {
  late AppDatabase db;
  late BodyMetricsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = BodyMetricsRepository(db);
  });
  tearDown(() => db.close());

  test('新增後依時間升序讀回，getLatest 取最新，綁定 userId', () async {
    final t1 = DateTime(2026, 1, 1);
    final t2 = DateTime(2026, 1, 8);
    final t3 = DateTime(2026, 1, 15);

    // 故意亂序插入
    await repo.addMetric(weightKg: 73, recordedAt: t1);
    await repo.addMetric(weightKg: 72, recordedAt: t3);
    await repo.addMetric(weightKg: 72.5, bodyFatPct: 18, recordedAt: t2);

    final all = await repo.getMetrics();
    expect(all.map((m) => m.weightKg).toList(), [73, 72.5, 72]); // 升序
    expect(all.every((m) => m.userId == AppConstants.currentUserId), isTrue);
    expect(all[1].bodyFatPct, 18);

    final latest = await repo.getLatest();
    expect(latest!.weightKg, 72); // t3 最新
  });

  test('沒有紀錄時 getLatest 為 null', () async {
    expect(await repo.getLatest(), isNull);
  });
}
