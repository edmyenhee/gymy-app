/// 休息倒數的純邏輯（不含 UI、不含平台通知）。
///
/// 背景/鎖屏安全的關鍵：剩餘秒數一律由「結束時間點 `endsAt` − now」算出，
/// 而非累加每秒 tick。app 被切到背景或鎖屏後回前景，直接用 wall-clock
/// 重算即可正確，不會因為 Dart Timer 被暫停而少算。
class RestCountdown {
  const RestCountdown({required this.totalSeconds, required this.endsAt});

  /// 從現在開始一段休息倒數。
  factory RestCountdown.start({
    required int totalSeconds,
    required DateTime now,
  }) =>
      RestCountdown(
        totalSeconds: totalSeconds,
        endsAt: now.add(Duration(seconds: totalSeconds)),
      );

  /// 這段休息的總長（秒），用於計算進度比例。
  final int totalSeconds;

  /// 結束的 wall-clock 時間點。
  final DateTime endsAt;

  /// 在 [now] 時的剩餘秒數，clamp 在 0 以上。
  int remainingSeconds(DateTime now) {
    final secs = endsAt.difference(now).inSeconds;
    return secs < 0 ? 0 : secs;
  }

  /// 是否已到（或過）結束時間點。
  bool isDone(DateTime now) => !now.isBefore(endsAt);

  /// 進度比例（剩餘 / 總），1.0 → 0.0，給計時環用。
  double progress(DateTime now) {
    if (totalSeconds <= 0) return 0;
    return remainingSeconds(now) / totalSeconds;
  }

  /// 延長休息（如 +30s）：結束時間點與總長同步增加。
  RestCountdown extend(int seconds) => RestCountdown(
        totalSeconds: totalSeconds + seconds,
        endsAt: endsAt.add(Duration(seconds: seconds)),
      );
}
