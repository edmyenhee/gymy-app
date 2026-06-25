import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'rest_notification_service.dart';

/// flutter_local_notifications 實作的休息通知服務。
///
/// 設計重點：休息開始即排一則「結束時間點」的本地通知，UI 倒數只是裝飾；
/// 這樣 app 切背景 / 鎖屏，時間到一樣會響 + 震動（健身房吵，靠震動）。
class LocalRestNotificationService implements RestNotificationService {
  LocalRestNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'rest_timer';
  static const String _channelName = '休息計時';
  static const String _channelDesc = '休息倒數結束提示';

  bool _timeZoneReady = false;

  @override
  Future<void> init() async {
    if (!_timeZoneReady) {
      tz_data.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      _timeZoneReady = true;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );

    // Android 須先建 channel（以震動為主）。
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        enableVibration: true,
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<void> scheduleRestEnd({
    required int id,
    required DateTime endsAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      '休息結束',
      '開始下一組 💪',
      tz.TZDateTime.from(endsAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);
}
