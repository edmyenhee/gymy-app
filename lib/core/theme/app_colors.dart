import 'package:flutter/widgets.dart';

/// 設計 token：色彩。
///
/// 來源為設計交付文件第四節。原型中部分用途有兩三個相近色值，
/// 這裡收斂成單一定值，避免主題髒掉、畫面飄移。
class AppColors {
  AppColors._();

  // ---- 背景層 ----
  static const Color background = Color(0xFF15140F); // 暖炭黑，App 主底
  static const Color surface = Color(0xFF1E1C16); // 卡片、輸入框
  static const Color surfaceHigh = Color(0xFF211F19); // 更深的卡片 / 休息頁
  static const Color sheet = Color(0xFF1B1914); // bottom sheet / 彈出層
  static const Color iconBg = Color(0xFF2A281F); // icon 容器 / 膠囊底

  // ---- 強調色（螢光綠）----
  static const Color accent = Color(0xFF5FE39A); // 當前項目、CTA、進度、強調數字
  static const Color accentGradientStart = Color(0xFF76F0AB);
  static const Color accentGradientEnd = Color(0xFF28B56F);
  static const Color onAccent = Color(0xFF06281A); // 綠色按鈕上的深綠字
  static const Color accentGlow = Color(0x8C5FE39A); // 發光 rgba(95,227,154,.55)

  // ---- 文字 ----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCFCDC6);
  static const Color textTertiary = Color(0xFF8A8A82); // 標籤、說明
  static const Color textDisabled = Color(0xFF6F6D66); // 占位、未啟用

  // ---- 線與框 ----
  static const Color divider = Color(0xFF26241D);
  static const Color border = Color(0xFF2C2B28); // 次要按鈕邊框（未選）

  // ---- 漸層 ----
  /// 主 CTA 漸層（linear 135deg）。
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGradientStart, accentGradientEnd],
  );

  /// 今日卡漸層（radial 130% 90% at 80% 0%）。
  static const RadialGradient todayCardGradient = RadialGradient(
    center: Alignment(0.6, -1.0), // 約 80% 0%
    radius: 1.3,
    colors: [Color(0xFF2A3324), Color(0xFF1D1B15)],
    stops: [0.0, 0.6],
  );

  /// 深色頁背景漸層（歡迎 / 休息 / 生成中）。
  static const RadialGradient darkPageGradient = RadialGradient(
    center: Alignment(0.0, -1.16), // 約 50% -8%
    radius: 1.25,
    colors: [Color(0xFF232A1F), background],
    stops: [0.0, 0.52],
  );
}
