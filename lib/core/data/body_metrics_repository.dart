import 'package:drift/drift.dart';

import '../common/app_constants.dart';
import '../db/app_database.dart';
import '../db/enums.dart';

/// 體組成（體重 / 體脂 / 肌肉量）歷史的存取層。資料綁定固定 [userId]。
class BodyMetricsRepository {
  BodyMetricsRepository(this._db, {this.userId = AppConstants.currentUserId});

  final AppDatabase _db;
  final String userId;

  /// 新增一筆紀錄；未給時間則用現在。回傳新列 id。
  Future<int> addMetric({
    double? weightKg,
    double? bodyFatPct,
    double? muscleMassKg,
    DateTime? recordedAt,
    MetricSource source = MetricSource.manual,
  }) {
    return _db.into(_db.bodyMetrics).insert(
          BodyMetricsCompanion.insert(
            userId: userId,
            recordedAt: recordedAt ?? DateTime.now(),
            source: source,
            weightKg: Value.absentIfNull(weightKg),
            bodyFatPct: Value.absentIfNull(bodyFatPct),
            muscleMassKg: Value.absentIfNull(muscleMassKg),
          ),
        );
  }

  /// 全部紀錄，依時間升序（舊 → 新，給趨勢圖用）。
  Future<List<BodyMetric>> getMetrics() => _query().get();

  /// 監看全部紀錄（時間升序），DB 變動自動發新值。
  Stream<List<BodyMetric>> watchMetrics() => _query().watch();

  /// 最新一筆，沒有則 null。
  Future<BodyMetric?> getLatest() {
    return (_db.select(_db.bodyMetrics)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.recordedAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  SimpleSelectStatement<$BodyMetricsTable, BodyMetric> _query() {
    return _db.select(_db.bodyMetrics)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm(expression: t.recordedAt)]);
  }
}
