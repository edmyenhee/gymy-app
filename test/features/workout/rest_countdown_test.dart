import 'package:flutter_test/flutter_test.dart';
import 'package:gymy/features/workout/rest_countdown.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 10, 0, 0);

  test('剩餘秒數由「結束時間點 − now」算出（背景 / 鎖屏安全）', () {
    final c = RestCountdown.start(totalSeconds: 90, now: t0);

    expect(c.remainingSeconds(t0), 90);
    expect(c.remainingSeconds(t0.add(const Duration(seconds: 30))), 60);
    // 模擬：app 被切到背景很久才回前景 → 直接用 wall-clock 重算，不靠累加 tick
    expect(c.remainingSeconds(t0.add(const Duration(seconds: 80))), 10);
  });

  test('剩餘不為負，歸零後維持 0', () {
    final c = RestCountdown.start(totalSeconds: 90, now: t0);
    expect(c.remainingSeconds(t0.add(const Duration(seconds: 95))), 0);
  });

  test('isDone 在到達結束時間點後為真', () {
    final c = RestCountdown.start(totalSeconds: 90, now: t0);
    expect(c.isDone(t0.add(const Duration(seconds: 89))), isFalse);
    expect(c.isDone(t0.add(const Duration(seconds: 90))), isTrue);
    expect(c.isDone(t0.add(const Duration(seconds: 120))), isTrue);
  });

  test('progress 為剩餘 / 總，從 1 遞減到 0', () {
    final c = RestCountdown.start(totalSeconds: 100, now: t0);
    expect(c.progress(t0), 1.0);
    expect(c.progress(t0.add(const Duration(seconds: 25))), 0.75);
    expect(c.progress(t0.add(const Duration(seconds: 100))), 0.0);
  });

  test('+30s 延長：結束點與總長同步加 30，progress 仍 ≤ 1', () {
    final c = RestCountdown.start(totalSeconds: 90, now: t0).extend(30);

    expect(c.totalSeconds, 120);
    expect(c.remainingSeconds(t0), 120);
    expect(c.progress(t0), 1.0);
  });
}
