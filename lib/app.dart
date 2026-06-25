import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_dimens.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

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

/// 暫時的佔位首頁，僅用來確認設計 token / 主題正確套用。
/// 之後會被真正的導覽骨架取代。
class _FoundationPlaceholder extends StatelessWidget {
  const _FoundationPlaceholder();

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.timerLarge.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
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
            ],
          ),
        ),
      ),
    );
  }
}
