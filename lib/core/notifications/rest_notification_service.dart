import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 休息倒數的通知服務抽象。
///
/// 介面預留：底層今天是 flutter_local_notifications，未來要換或加防呆只改實作。
/// UI / 狀態只依賴此介面。
abstract interface class RestNotificationService {
  /// 初始化（時區、channel、plugin）。app 啟動時呼叫一次。
  Future<void> init();

  /// 請求通知權限，回傳是否取得。
  Future<bool> requestPermission();

  /// 在 [endsAt] 排一則「休息結束」通知（背景 / 鎖屏也會響 + 震動）。
  Future<void> scheduleRestEnd({required int id, required DateTime endsAt});

  /// 取消指定通知（如使用者按「跳過」）。
  Future<void> cancel(int id);
}

/// 測試 / 不支援平台用的空實作。
class NoopRestNotificationService implements RestNotificationService {
  const NoopRestNotificationService();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleRestEnd({
    required int id,
    required DateTime endsAt,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

/// 預設 Noop；`main()` 啟動時以真正的本地通知實作 override。
final restNotificationServiceProvider = Provider<RestNotificationService>(
  (ref) => const NoopRestNotificationService(),
);
