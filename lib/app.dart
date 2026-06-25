import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/rest_notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_dimens.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/workout/rest_countdown.dart';
import 'features/workout/sample_plan.dart';
import 'features/workout/screens/workout_session_screen.dart';

class GymyApp extends StatelessWidget {
  const GymyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _FoundationPlaceholder(),
    );
  }
}

/// 暫時的佔位首頁：確認設計 token / 主題，並提供 debug 用的休息通知測試。
/// 之後會被真正的導覽骨架取代。
class _FoundationPlaceholder extends ConsumerWidget {
  const _FoundationPlaceholder();

  Future<void> _testRestNotification(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(restNotificationServiceProvider);
    final granted = await service.requestPermission();
    final rest = RestCountdown.start(totalSeconds: 5, now: DateTime.now());
    await service.scheduleRestEnd(id: 1, endsAt: rest.endsAt);
    messenger.showSnackBar(
      SnackBar(
        content: Text(granted ? '已排 5 秒後的休息通知，可鎖屏測試' : '通知權限未取得'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gymy', style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.sm),
              Text('地基就緒 · 設計系統已套用', style: AppTypography.body),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '01:30',
                style:
                    AppTypography.timerLarge.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkoutSessionScreen(
                      title: sampleWorkoutTitle,
                      plan: sampleWorkoutPlan,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: AppRadius.pillRadius,
                    boxShadow: AppShadows.accentButton,
                  ),
                  child: Text(
                    '開始今天的訓練',
                    style: AppTypography.zh(
                      size: 15,
                      weight: FontWeight.w700,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => _testRestNotification(context, ref),
                child: Text('🔔 測試休息通知（5 秒）', style: AppTypography.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
