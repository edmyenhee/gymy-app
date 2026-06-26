import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../workout/sample_plan.dart';
import '../workout/screens/workout_session_screen.dart';

String _fmtWeight(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// 首頁 Dashboard（設計 #8）：問候、今日訓練卡、統計卡。
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return '早安';
    if (h < 18) return '午安';
    return '晚安';
  }

  void _startWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WorkoutSessionScreen(
          title: sampleWorkoutTitle,
          plan: sampleWorkoutPlan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final metrics =
        ref.watch(bodyMetricsStreamProvider).asData?.value ??
            const <BodyMetric>[];
    final weights = metrics.where((m) => m.weightKg != null).toList();
    final weightText =
        weights.isEmpty ? '尚未記錄' : '${_fmtWeight(weights.last.weightKg!)} kg';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${now.month} 月 ${now.day} 日',
                          style: AppTypography.label),
                      const SizedBox(height: 2),
                      Text('${_greeting()} 👋',
                          style: AppTypography.screenTitle),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.onAccent, size: 24),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _TodayCard(onStart: () => _startWorkout(context)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _StatCard(label: '體重', value: weightText)),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                    child: _StatCard(label: '本週訓練', value: '0 次')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.todayCardGradient,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日訓練',
              style: AppTypography.zh(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 2)),
          const SizedBox(height: AppSpacing.sm),
          Text(sampleWorkoutTitle,
              style: AppTypography.zh(size: 22, weight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          Text('${sampleWorkoutPlan.length} 個動作 · 今天也加油 💪',
              style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: onStart,
            child: Container(
              height: 52,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: AppRadius.pillRadius,
                boxShadow: AppShadows.accentButton,
              ),
              child: Text('開始訓練',
                  style: AppTypography.zh(
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.onAccent)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTypography.zh(
                  size: 17,
                  weight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
