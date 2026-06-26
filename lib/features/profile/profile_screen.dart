import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/enums.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

String genderLabel(Gender g) => switch (g) {
      Gender.male => '男',
      Gender.female => '女',
      Gender.other => '其他',
    };

String goalLabel(TrainingGoal g) => switch (g) {
      TrainingGoal.gain => '增肌',
      TrainingGoal.cut => '減脂',
      TrainingGoal.maintain => '維持',
    };

String expLabel(TrainingExperience e) => switch (e) {
      TrainingExperience.beginner => '新手',
      TrainingExperience.intermediate => '中階',
      TrainingExperience.advanced => '進階',
    };

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// 「我」分頁：顯示 / 編輯個人資料（UserProfile）。
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, UserProfile? p) async {
    final result = await showProfileEditSheet(context, initial: p);
    if (result == null) return;
    await ref.read(profileRepositoryProvider).saveProfile(
          heightCm: result.heightCm,
          age: result.age,
          gender: result.gender,
          experience: result.experience,
          goal: result.goal,
          daysPerWeek: result.daysPerWeek,
          minutesPerSession: result.minutesPerSession,
        );
    ref.invalidate(profileProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('我', style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: async.when(
                  data: (p) => _content(context, ref, p),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      Center(child: Text('讀取失敗', style: AppTypography.body)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, UserProfile? p) {
    if (p == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('尚未設定個人資料', style: AppTypography.body),
            const SizedBox(height: AppSpacing.lg),
            _PrimaryButton(label: '設定', onTap: () => _edit(context, ref, null)),
          ],
        ),
      );
    }
    final freq = p.daysPerWeek != null
        ? '一週 ${p.daysPerWeek} 天 · 每次 ${p.minutesPerSession ?? '—'} 分'
        : '—';
    return ListView(
      children: [
        _row('身高', p.heightCm != null ? '${_fmt(p.heightCm!)} cm' : '—'),
        _row('年齡', p.age?.toString() ?? '—'),
        _row('性別', p.gender != null ? genderLabel(p.gender!) : '—'),
        _row('訓練經驗', p.experience != null ? expLabel(p.experience!) : '—'),
        _row('目標', p.goal != null ? goalLabel(p.goal!) : '—'),
        _row('訓練頻率', freq),
        const SizedBox(height: AppSpacing.xl),
        _PrimaryButton(label: '編輯', onTap: () => _edit(context, ref, p)),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body),
            Text(value,
                style: AppTypography.zh(
                    size: 15,
                    weight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );
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
        height: 52,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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

// ───────────────────────── 編輯 ─────────────────────────

class ProfileInput {
  const ProfileInput({
    this.heightCm,
    this.age,
    this.gender,
    this.experience,
    this.goal,
    this.daysPerWeek,
    this.minutesPerSession,
  });

  final double? heightCm;
  final int? age;
  final Gender? gender;
  final TrainingExperience? experience;
  final TrainingGoal? goal;
  final int? daysPerWeek;
  final int? minutesPerSession;
}

Future<ProfileInput?> showProfileEditSheet(
  BuildContext context, {
  UserProfile? initial,
}) {
  return showModalBottomSheet<ProfileInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
    builder: (_) => _ProfileEditSheet(initial: initial),
  );
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({this.initial});
  final UserProfile? initial;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _height =
      TextEditingController(text: _initNum(widget.initial?.heightCm));
  late final TextEditingController _age =
      TextEditingController(text: widget.initial?.age?.toString() ?? '');
  late final TextEditingController _days = TextEditingController(
      text: widget.initial?.daysPerWeek?.toString() ?? '');
  late final TextEditingController _minutes = TextEditingController(
      text: widget.initial?.minutesPerSession?.toString() ?? '');

  late Gender? _gender = widget.initial?.gender;
  late TrainingExperience? _experience = widget.initial?.experience;
  late TrainingGoal? _goal = widget.initial?.goal;

  static String _initNum(double? v) =>
      v == null ? '' : (v == v.roundToDouble() ? v.toInt().toString() : '$v');

  @override
  void dispose() {
    _height.dispose();
    _age.dispose();
    _days.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      ProfileInput(
        heightCm: double.tryParse(_height.text.trim()),
        age: int.tryParse(_age.text.trim()),
        gender: _gender,
        experience: _experience,
        goal: _goal,
        daysPerWeek: int.tryParse(_days.text.trim()),
        minutesPerSession: int.tryParse(_minutes.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        right: AppSpacing.page,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
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
            Text('個人資料', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _numField(_height, '身高 (cm)')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _numField(_age, '年齡')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _PillGroup<Gender>(
              label: '性別',
              values: Gender.values,
              selected: _gender,
              labelOf: genderLabel,
              onSelect: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PillGroup<TrainingExperience>(
              label: '訓練經驗',
              values: TrainingExperience.values,
              selected: _experience,
              labelOf: expLabel,
              onSelect: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PillGroup<TrainingGoal>(
              label: '目標',
              values: TrainingGoal.values,
              selected: _goal,
              labelOf: goalLabel,
              onSelect: (v) => setState(() => _goal = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _numField(_days, '一週幾天')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _numField(_minutes, '每次幾分鐘')),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 54,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: AppRadius.pillRadius,
                  boxShadow: AppShadows.accentButton,
                ),
                child: Text('儲存',
                    style: AppTypography.zh(
                        size: 16,
                        weight: FontWeight.w700,
                        color: AppColors.onAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTypography.number(size: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.label,
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 2)),
      ),
    );
  }
}

class _PillGroup<T> extends StatelessWidget {
  const _PillGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final v in values)
              GestureDetector(
                onTap: () => onSelect(v),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color:
                        v == selected ? AppColors.accent : AppColors.iconBg,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    labelOf(v),
                    style: AppTypography.zh(
                      size: 13,
                      weight: FontWeight.w700,
                      color: v == selected
                          ? AppColors.onAccent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
