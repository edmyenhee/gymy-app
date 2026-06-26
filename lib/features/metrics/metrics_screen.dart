import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

enum _Metric { weight, bodyFat, muscle }

String _metricLabel(_Metric m) => switch (m) {
      _Metric.weight => '體重',
      _Metric.bodyFat => '體脂',
      _Metric.muscle => '肌肉量',
    };

String _metricUnit(_Metric m) => switch (m) {
      _Metric.weight => 'kg',
      _Metric.bodyFat => '%',
      _Metric.muscle => 'kg',
    };

double? _metricValue(_Metric m, BodyMetric e) => switch (m) {
      _Metric.weight => e.weightKg,
      _Metric.bodyFat => e.bodyFatPct,
      _Metric.muscle => e.muscleMassKg,
    };

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// 數據分頁：體組成趨勢 + 最近紀錄 + 新增。
class MetricsScreen extends ConsumerStatefulWidget {
  const MetricsScreen({super.key});

  @override
  ConsumerState<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends ConsumerState<MetricsScreen> {
  _Metric _metric = _Metric.weight;

  Future<void> _addRecord() async {
    final result = await showAddMetricSheet(context);
    if (result == null) return;
    await ref.read(bodyMetricsRepositoryProvider).addMetric(
          weightKg: result.weightKg,
          bodyFatPct: result.bodyFatPct,
          muscleMassKg: result.muscleMassKg,
        );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bodyMetricsStreamProvider);
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
                    child: Text('身體數據', style: AppTypography.screenTitle),
                  ),
                  GestureDetector(
                    onTap: _addRecord,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          color: AppColors.accent, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricSwitcher(
                selected: _metric,
                onSelect: (m) => setState(() => _metric = m),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: async.when(
                  data: (metrics) => _content(metrics),
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

  Widget _content(List<BodyMetric> metrics) {
    final series =
        metrics.where((e) => _metricValue(_metric, e) != null).toList();
    if (series.isEmpty) {
      return Center(
        child: Text('尚無${_metricLabel(_metric)}紀錄\n點右上 + 新增一筆',
            textAlign: TextAlign.center, style: AppTypography.body),
      );
    }

    final values = series.map((e) => _metricValue(_metric, e)!).toList();
    final latest = values.last;
    final change = values.length >= 2 ? latest - values[values.length - 2] : null;

    return ListView(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(_fmt(latest),
                style: AppTypography.number(
                    size: 46, weight: FontWeight.w700)),
            const SizedBox(width: 4),
            Text(_metricUnit(_metric), style: AppTypography.body),
            const SizedBox(width: AppSpacing.md),
            if (change != null && change != 0)
              Text(
                '${change > 0 ? '↑' : '↓'} ${_fmt(change.abs())}',
                style: AppTypography.number(
                    size: 14, color: AppColors.accent),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _TrendChart(values: values),
        const SizedBox(height: AppSpacing.xl),
        Text('最近紀錄', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        for (final e in series.reversed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_date(e.recordedAt), style: AppTypography.body),
                Text('${_fmt(_metricValue(_metric, e)!)} ${_metricUnit(_metric)}',
                    style: AppTypography.number(
                        size: 15, color: AppColors.textPrimary)),
              ],
            ),
          ),
      ],
    );
  }

  String _date(DateTime d) => '${d.year}/${d.month}/${d.day}';
}

class _MetricSwitcher extends StatelessWidget {
  const _MetricSwitcher({required this.selected, required this.onSelect});

  final _Metric selected;
  final ValueChanged<_Metric> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in _Metric.values)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelect(m),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: m == selected ? AppColors.accent : AppColors.iconBg,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  _metricLabel(m),
                  style: AppTypography.zh(
                    size: 13,
                    weight: FontWeight.w700,
                    color:
                        m == selected ? AppColors.onAccent : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text('需要至少兩筆紀錄才有趨勢', style: AppTypography.label),
      );
    }
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(painter: _TrendPainter(values)),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
    final dx = size.width / (values.length - 1);
    Offset pt(int i) => Offset(
          i * dx,
          size.height - ((values[i] - minV) / range) * (size.height - 8) - 4,
        );

    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = AppColors.accent.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.accent,
    );
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(pt(i), 3, Paint()..color = AppColors.accent);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.values != values;
}

// ───────────────────────── 新增紀錄 ─────────────────────────

class MetricInput {
  const MetricInput({this.weightKg, this.bodyFatPct, this.muscleMassKg});
  final double? weightKg;
  final double? bodyFatPct;
  final double? muscleMassKg;

  bool get isEmpty =>
      weightKg == null && bodyFatPct == null && muscleMassKg == null;
}

Future<MetricInput?> showAddMetricSheet(BuildContext context) {
  return showModalBottomSheet<MetricInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
    builder: (_) => const _AddMetricSheet(),
  );
}

class _AddMetricSheet extends StatefulWidget {
  const _AddMetricSheet();

  @override
  State<_AddMetricSheet> createState() => _AddMetricSheetState();
}

class _AddMetricSheetState extends State<_AddMetricSheet> {
  final _weight = TextEditingController();
  final _bodyFat = TextEditingController();
  final _muscle = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _bodyFat.dispose();
    _muscle.dispose();
    super.dispose();
  }

  void _save() {
    final input = MetricInput(
      weightKg: double.tryParse(_weight.text.trim()),
      bodyFatPct: double.tryParse(_bodyFat.text.trim()),
      muscleMassKg: double.tryParse(_muscle.text.trim()),
    );
    Navigator.of(context).pop(input.isEmpty ? null : input);
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
          Text('新增紀錄', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.xs),
          Text('至少填一項；留空的不記錄', style: AppTypography.label),
          const SizedBox(height: AppSpacing.lg),
          _field(_weight, '體重 (kg)'),
          const SizedBox(height: AppSpacing.md),
          _field(_bodyFat, '體脂 (%)'),
          const SizedBox(height: AppSpacing.md),
          _field(_muscle, '肌肉量 (kg)'),
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
    );
  }

  Widget _field(TextEditingController c, String label) {
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
