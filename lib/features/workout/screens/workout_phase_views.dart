import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../active_workout.dart';
import '../widgets/workout_controls.dart';

String _fmtWeight(double w) =>
    w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);

String _scheme(ActiveExercise e) {
  final w = e.plannedWeightKg;
  final base = '${e.plannedSets} 組 × ${e.plannedReps} 下';
  return w == null ? base : '$base · ${_fmtWeight(w)}kg';
}

// ───────────────────────── 開始前 ─────────────────────────

/// 開始前：動作清單 + 「開始今天的訓練」。
class PreStartView extends StatelessWidget {
  const PreStartView({
    super.key,
    required this.workout,
    required this.onStart,
    this.onBack,
    this.onEditExercise,
  });

  final ActiveWorkout workout;
  final VoidCallback onStart;
  final VoidCallback? onBack;
  final void Function(int index)? onEditExercise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  child: Text('‹ 返回', style: AppTypography.body),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(workout.title, style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${workout.exercises.length} 個動作 · 點開始進入訓練',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: workout.exercises.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _ExerciseRow(
                    index: i + 1,
                    exercise: workout.exercises[i],
                    onEdit: onEditExercise == null
                        ? null
                        : () => onEditExercise!(i),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _PrimaryButton(label: '開始今天的訓練', onTap: onStart),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.exercise, this.onEdit});

  final int index;
  final ActiveExercise exercise;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          Text('$index',
              style: AppTypography.number(size: 15, color: AppColors.accent)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: AppTypography.exerciseName),
                const SizedBox(height: 2),
                Text(_scheme(exercise), style: AppTypography.label),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Text('改',
                    style: AppTypography.zh(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.accent)),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── 記錄這組 ─────────────────────────

/// 記錄這一組：weight / reps 步進器（可點數字鍵盤輸入）+ RPE pill（選填）+ 完成這組。
class RecordSetView extends StatelessWidget {
  const RecordSetView({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.exerciseCount,
    required this.setNumber,
    required this.elapsedSeconds,
    required this.weightKg,
    required this.reps,
    required this.rpe,
    required this.onWeightDelta,
    required this.onRepsDelta,
    required this.onWeightSet,
    required this.onRepsSet,
    required this.onRpe,
    required this.onCompleteSet,
  });

  final ActiveExercise exercise;
  final int exerciseIndex; // 0-based
  final int exerciseCount;
  final int setNumber; // 1-based
  final int elapsedSeconds;
  final double weightKg;
  final int reps;
  final int? rpe;
  final ValueChanged<double> onWeightDelta;
  final ValueChanged<int> onRepsDelta;
  final ValueChanged<double> onWeightSet;
  final ValueChanged<int> onRepsSet;
  final ValueChanged<int?> onRpe;
  final VoidCallback onCompleteSet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopInfoBar(
                center: '動作 ${exerciseIndex + 1} / $exerciseCount',
                elapsedSeconds: elapsedSeconds,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(exercise.name, style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '目標 ${exercise.plannedSets}×${exercise.plannedReps}'
                '${exercise.plannedWeightKg != null ? ' · 課表 ${_fmtWeight(exercise.plannedWeightKg!)}kg' : ''}',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SetProgress(
                total: exercise.plannedSets,
                done: exercise.loggedSets.length,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('SET ',
                      style: AppTypography.zh(
                          size: 18,
                          weight: FontWeight.w700,
                          color: AppColors.textTertiary)),
                  Text('$setNumber',
                      style: AppTypography.number(
                          size: 30,
                          weight: FontWeight.w700,
                          color: AppColors.accent)),
                  Text(' / ${exercise.plannedSets}',
                      style: AppTypography.number(
                          size: 18, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              ValueStepper(
                label: '重量 (kg)',
                value: _fmtWeight(weightKg),
                onMinus: () => onWeightDelta(-2.5),
                onPlus: () => onWeightDelta(2.5),
                onValueChanged: (n) => onWeightSet(n.toDouble()),
                keyboardDecimal: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              ValueStepper(
                label: '次數',
                value: '$reps',
                onMinus: () => onRepsDelta(-1),
                onPlus: () => onRepsDelta(1),
                onValueChanged: (n) => onRepsSet(n.toInt()),
              ),
              const SizedBox(height: AppSpacing.xl),
              _RpePills(value: rpe, onRpe: onRpe),
              const Spacer(),
              _PrimaryButton(label: '完成這組', onTap: onCompleteSet),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetProgress extends StatelessWidget {
  const _SetProgress({required this.total, required this.done});

  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              height: 6,
              decoration: BoxDecoration(
                color: i < done ? AppColors.accent : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}

class _RpePills extends StatelessWidget {
  const _RpePills({required this.value, required this.onRpe});

  final int? value;
  final ValueChanged<int?> onRpe;

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('RPE 自覺強度', style: AppTypography.sectionTitle),
        content: Text(
          '這一組你覺得有多吃力（1–10），選填。\n\n'
          '10 = 力竭，再也做不動\n'
          '9 = 大概還能多做 1 下\n'
          '8 = 還能多做約 2 下\n'
          '7 = 還能多做約 3 下\n'
          '6 以下 = 還算輕鬆\n\n'
          '之後週期回顧會用它判斷疲勞、調整課表。',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('知道了',
                style: AppTypography.zh(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('強度 RPE', style: AppTypography.label),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showInfo(context),
          behavior: HitTestBehavior.opaque,
          child: const Icon(Icons.help_outline,
              size: 15, color: AppColors.textTertiary),
        ),
        const SizedBox(width: AppSpacing.sm),
        for (final v in const [6, 7, 8, 9, 10])
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onRpe(value == v ? null : v),
              child: Container(
                width: 38,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == v ? AppColors.accent : AppColors.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$v',
                  style: AppTypography.number(
                    size: 13,
                    weight: FontWeight.w700,
                    color: value == v
                        ? AppColors.onAccent
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        Text('選填', style: AppTypography.label),
      ],
    );
  }
}

// ───────────────────────── 休息倒數 ─────────────────────────

/// 休息倒數：計時環 + 跳過 / +30s。
class RestView extends StatelessWidget {
  const RestView({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.elapsedSeconds,
    required this.onSkip,
    required this.onExtend,
    this.nextLabel,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final int elapsedSeconds;
  final VoidCallback onSkip;
  final VoidCallback onExtend;
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds <= 0 ? 0.0 : remainingSeconds / totalSeconds;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkPageGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                _TopInfoBar(center: '休息中', elapsedSeconds: elapsedSeconds),
                const Spacer(),
                Text('休 息 中',
                    style: AppTypography.zh(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 5,
                    )),
                const SizedBox(height: AppSpacing.lg),
                RestTimerRing(
                  progress: progress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatMmss(remainingSeconds),
                          style: AppTypography.timerLarge
                              .copyWith(color: AppColors.accent)),
                      Text('建議 $totalSeconds 秒', style: AppTypography.label),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (nextLabel != null)
                  Text('下一組：$nextLabel', style: AppTypography.body),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: _OutlineButton(label: '跳過', onTap: onSkip)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _OutlineButton(label: '+30s', onTap: onExtend)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('倒數結束震動提示 · 鎖屏仍通知', style: AppTypography.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── 訓練完成 ─────────────────────────

/// 訓練完成：統計 + 計畫 vs 實際。
class FinishedView extends StatelessWidget {
  const FinishedView({
    super.key,
    required this.workout,
    required this.elapsedSeconds,
    required this.onDone,
  });

  final ActiveWorkout workout;
  final int elapsedSeconds;
  final VoidCallback onDone;

  int get _totalSets =>
      workout.exercises.fold(0, (sum, e) => sum + e.loggedSets.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkPageGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          gradient: AppColors.accentGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.accentButton,
                        ),
                        child: const Icon(Icons.check,
                            color: AppColors.onAccent, size: 36),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('訓練完成！', style: AppTypography.screenTitle),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            label: '總時間', value: formatMmss(elapsedSeconds))),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _StatCard(
                            label: '完成組數', value: '$_totalSets')),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('計畫 vs 實際', style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView.separated(
                    itemCount: workout.exercises.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) =>
                        _PlanVsActualRow(exercise: workout.exercises[i]),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PrimaryButton(label: '完成並存檔', onTap: onDone),
              ],
            ),
          ),
        ),
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
              style: AppTypography.number(size: 24, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _PlanVsActualRow extends StatelessWidget {
  const _PlanVsActualRow({required this.exercise});

  final ActiveExercise exercise;

  @override
  Widget build(BuildContext context) {
    final actual = exercise.loggedSets
        .map((s) =>
            '${_fmtWeight(s.weightKg ?? 0)}×${s.reps ?? 0}${s.rpe != null ? '@${s.rpe}' : ''}')
        .join('  ');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.name, style: AppTypography.exerciseName),
          const SizedBox(height: 2),
          Text('計畫 ${_scheme(exercise)}', style: AppTypography.label),
          const SizedBox(height: 2),
          Text('實際 ${actual.isEmpty ? '—' : actual}',
              style: AppTypography.body),
        ],
      ),
    );
  }
}

// ───────────────────────── 共用元件 ─────────────────────────

class _TopInfoBar extends StatelessWidget {
  const _TopInfoBar({required this.center, required this.elapsedSeconds});

  final String center;
  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.iconBg,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Text(center,
              style: AppTypography.number(size: 12, color: AppColors.accent)),
        ),
        const Spacer(),
        Text('⏱ ${formatMmss(elapsedSeconds)}',
            style: AppTypography.number(size: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: AppRadius.pillRadius,
          boxShadow: AppShadows.accentButton,
        ),
        child: Text(label,
            style: AppTypography.zh(
                size: 16, weight: FontWeight.w700, color: AppColors.onAccent)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.pillRadius,
        ),
        child: Text(label,
            style: AppTypography.zh(
                size: 15, weight: FontWeight.w500, color: AppColors.textSecondary)),
      ),
    );
  }
}

// ───────────────────────── 訓練總覽（動作之間）─────────────────────────

/// 動作之間回到的總覽：挑一個未完成動作開始；全部完成則「完成訓練」。
class OverviewView extends StatelessWidget {
  const OverviewView({
    super.key,
    required this.workout,
    required this.elapsedSeconds,
    required this.onStartExercise,
    required this.onFinish,
  });

  final ActiveWorkout workout;
  final int elapsedSeconds;
  final ValueChanged<int> onStartExercise;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final done = workout.exercises.where((e) => e.isComplete).length;
    final total = workout.exercises.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(workout.title, style: AppTypography.screenTitle),
                  ),
                  Text('⏱ ${formatMmss(elapsedSeconds)}',
                      style: AppTypography.number(
                          size: 13, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('$done / $total 動作完成 · 點動作開始',
                  style: AppTypography.body),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: total,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final ex = workout.exercises[i];
                    return _OverviewRow(
                      index: i + 1,
                      exercise: ex,
                      onTap: ex.isComplete ? null : () => onStartExercise(i),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (workout.isAllComplete)
                _PrimaryButton(label: '完成訓練', onTap: onFinish)
              else
                Text('做完所有動作後即可完成訓練', style: AppTypography.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.index, required this.exercise, this.onTap});

  final int index;
  final ActiveExercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = exercise.isComplete;
    final inProgress = exercise.isStarted && !done;
    final status = done
        ? '已完成'
        : inProgress
            ? '進行中 ${exercise.loggedSets.length}/${exercise.plannedSets} 組'
            : _scheme(exercise);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          border: inProgress ? Border.all(color: AppColors.accent) : null,
        ),
        child: Row(
          children: [
            Text('$index',
                style: AppTypography.number(
                    size: 15,
                    color: done ? AppColors.textDisabled : AppColors.accent)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: AppTypography.exerciseName.copyWith(
                          color: done
                              ? AppColors.textTertiary
                              : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(status, style: AppTypography.label),
                ],
              ),
            ),
            Icon(
              done ? Icons.check_circle : Icons.chevron_right,
              color: done ? AppColors.accent : AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
