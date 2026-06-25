import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/local_rest_notification_service.dart';
import 'core/notifications/rest_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notifications = LocalRestNotificationService();
  try {
    await notifications.init();
  } catch (e, st) {
    debugPrint('通知初始化失敗（不影響 app 啟動）: $e\n$st');
  }

  runApp(
    ProviderScope(
      overrides: [
        restNotificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const GymyApp(),
    ),
  );
}
