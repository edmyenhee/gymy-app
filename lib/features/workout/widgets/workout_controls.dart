import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// 記錄頁的「標籤 ……  −  大數字  +」步進器。
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.label),
        const Spacer(),
        _RoundButton(icon: Icons.remove, color: AppColors.textTertiary, onTap: onMinus),
        SizedBox(
          width: 110,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.recordNumber,
          ),
        ),
        _RoundButton(icon: Icons.add, color: AppColors.accent, onTap: onPlus),
      ],
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
