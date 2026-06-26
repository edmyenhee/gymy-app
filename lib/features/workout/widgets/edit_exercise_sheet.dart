import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import 'workout_controls.dart';

/// 編輯結果。
class EditedExercise {
  const EditedExercise({
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weightKg,
  });

  final int sets;
  final int reps;
  final int restSeconds;
  final double? weightKg;
}

/// 從底部滑出的「編輯動作」彈出層（設計 #7）。回傳編輯後的值，取消則 null。
Future<EditedExercise?> showEditExerciseSheet(
  BuildContext context, {
  required String name,
  required int sets,
  required int reps,
  required int restSeconds,
  double? weightKg,
}) {
  return showModalBottomSheet<EditedExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
    builder: (_) => _EditExerciseSheet(
      name: name,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      weightKg: weightKg,
    ),
  );
}

class _EditExerciseSheet extends StatefulWidget {
  const _EditExerciseSheet({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weightKg,
  });

  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final double? weightKg;

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  late int _sets = widget.sets;
  late int _reps = widget.reps;
  late int _rest = widget.restSeconds;
  late double _weight = widget.weightKg ?? 0;

  String _w(double w) =>
      w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        right: AppSpacing.page,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(widget.name, style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.xs),
          Text('調整組數 / 次數 / 重量 / 休息（套用到這次訓練）',
              style: AppTypography.label),
          const SizedBox(height: AppSpacing.xl),
          ValueStepper(
            label: '組數',
            value: '$_sets',
            onMinus: () => setState(() {
              if (_sets > 1) _sets--;
            }),
            onPlus: () => setState(() => _sets++),
            onValueChanged: (n) =>
                setState(() => _sets = n.toInt() < 1 ? 1 : n.toInt()),
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueStepper(
            label: '次數',
            value: '$_reps',
            onMinus: () => setState(() {
              if (_reps > 1) _reps--;
            }),
            onPlus: () => setState(() => _reps++),
            onValueChanged: (n) =>
                setState(() => _reps = n.toInt() < 1 ? 1 : n.toInt()),
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueStepper(
            label: '重量 (kg)',
            value: _w(_weight),
            keyboardDecimal: true,
            onMinus: () => setState(() {
              final w = _weight - 2.5;
              _weight = w < 0 ? 0 : w;
            }),
            onPlus: () => setState(() => _weight += 2.5),
            onValueChanged: (n) => setState(() {
              final w = n.toDouble();
              _weight = w < 0 ? 0 : w;
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueStepper(
            label: '休息 (秒)',
            value: '$_rest',
            onMinus: () => setState(() {
              final r = _rest - 5;
              _rest = r < 0 ? 0 : r;
            }),
            onPlus: () => setState(() => _rest += 5),
            onValueChanged: (n) => setState(() {
              final r = n.toInt();
              _rest = r < 0 ? 0 : r;
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(
              EditedExercise(
                sets: _sets,
                reps: _reps,
                restSeconds: _rest,
                weightKg: _weight > 0 ? _weight : null,
              ),
            ),
            child: Container(
              height: 54,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: AppRadius.pillRadius,
                boxShadow: AppShadows.accentButton,
              ),
              child: Text('完成',
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
