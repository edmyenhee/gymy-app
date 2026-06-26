import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// 記錄頁的「標籤 ……  −  大數字  +」步進器。
/// 給 [onValueChanged] 時，中間數字變成可直接鍵盤輸入的欄位（點即出鍵盤、原地改）。
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.onValueChanged,
    this.keyboardDecimal = false,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  /// 提供時數字可鍵盤輸入；輸入有效數字會即時回呼。
  final ValueChanged<num>? onValueChanged;
  final bool keyboardDecimal;

  @override
  Widget build(BuildContext context) {
    final Widget valueArea = onValueChanged == null
        ? SizedBox(
            width: 110,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTypography.recordNumber,
            ),
          )
        : _EditableNumber(
            value: value,
            allowDecimal: keyboardDecimal,
            onChanged: onValueChanged!,
          );
    return Row(
      children: [
        Text(label, style: AppTypography.label),
        const Spacer(),
        _RoundButton(
            icon: Icons.remove, color: AppColors.textTertiary, onTap: onMinus),
        valueArea,
        _RoundButton(icon: Icons.add, color: AppColors.accent, onTap: onPlus),
      ],
    );
  }
}

/// inline 可編輯的大數字：點即出鍵盤、原地改；外部 +/- 改值會同步（除非正在編輯）。
class _EditableNumber extends StatefulWidget {
  const _EditableNumber({
    required this.value,
    required this.allowDecimal,
    required this.onChanged,
  });

  final String value;
  final bool allowDecimal;
  final ValueChanged<num> onChanged;

  @override
  State<_EditableNumber> createState() => _EditableNumberState();
}

class _EditableNumberState extends State<_EditableNumber> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      // 聚焦時選取全部，方便直接覆蓋輸入。
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else if (widget.value != _controller.text) {
      // 失焦時若內容無效/空，回復成目前值。
      _controller.text = widget.value;
    }
  }

  @override
  void didUpdateWidget(_EditableNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部（+/-）改值且非編輯中 → 同步欄位。
    if (!_focus.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textAlign: TextAlign.center,
        keyboardType:
            TextInputType.numberWithOptions(decimal: widget.allowDecimal),
        style: AppTypography.recordNumber,
        cursorColor: AppColors.accent,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 4),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border, width: 2)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent, width: 2)),
        ),
        onChanged: (v) {
          final n = widget.allowDecimal
              ? double.tryParse(v.trim())
              : int.tryParse(v.trim());
          if (n != null) widget.onChanged(n);
        },
        onSubmitted: (_) => _focus.unfocus(),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: AppColors.iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

/// 休息計時環：progress 由 1.0 遞減到 0.0。
class RestTimerRing extends StatelessWidget {
  const RestTimerRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 222,
  });

  final double progress;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;
  static const double _stroke = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(_stroke / 2, _stroke / 2) &
        Size(size.width - _stroke, size.height - _stroke);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = AppColors.divider;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    // 發光底層
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accentGlow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    // 主弧
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accent;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}

/// mm:ss 格式化。
String formatMmss(int seconds) {
  final clamped = seconds < 0 ? 0 : seconds;
  final m = (clamped ~/ 60).toString().padLeft(2, '0');
  final s = (clamped % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
