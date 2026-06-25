import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// App 主題（深色）。集中設計 token，畫面只吃 `Theme.of(context)` 或具名樣式。
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: Color(0xFFE5484D),
      onError: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      textTheme: TextTheme(
        displayLarge: AppTypography.screenTitle,
        headlineMedium: AppTypography.screenTitle,
        titleMedium: AppTypography.sectionTitle,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.label,
        labelLarge: AppTypography.exerciseName,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}
