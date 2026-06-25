import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// 設計 token：字體與字級。
///
/// 數字 / 拉丁字 → Space Grotesk（tabular figures 等寬數字）。
/// 中文 → Noto Sans TC。手寫鼓勵語 → Caveat（選用）。
///
/// 目前用 google_fonts 於執行時抓取字體並快取。
/// TODO(離線優先): 健身房常無網路，依賴執行時抓字第一次冷啟可能失敗。
/// 上線前須把 Space Grotesk / Noto Sans TC 以 asset 打包，只改這個檔即可
/// （其餘程式吃具名樣式，不受影響）。
class AppTypography {
  AppTypography._();

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// 中文字（Noto Sans TC）。
  static TextStyle zh({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.notoSansTc(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// 數字 / 拉丁字（Space Grotesk，等寬數字）。
  static TextStyle number({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: _tabular,
      );

  /// 手寫鼓勵語（Caveat，選用）。
  static TextStyle handwrite({
    required double size,
    Color color = AppColors.textSecondary,
  }) =>
      GoogleFonts.caveat(fontSize: size, color: color);

  // ---- 具名樣式（對應交付文件第四節字級表）----
  static TextStyle get timerLarge =>
      number(size: 60, weight: FontWeight.w700); // 大計時數字
  static TextStyle get recordNumber =>
      number(size: 34, weight: FontWeight.w700); // 記錄頁重量 / 次數
  static TextStyle get screenTitle =>
      zh(size: 24, weight: FontWeight.w900); // 畫面大標題（22–26）
  static TextStyle get sectionTitle =>
      zh(size: 18, weight: FontWeight.w700); // 區塊標題（17–19）
  static TextStyle get exerciseName =>
      zh(size: 15, weight: FontWeight.w700); // 動作名稱（14–15）
  static TextStyle get body =>
      zh(size: 13, color: AppColors.textSecondary); // 內文
  static TextStyle get bodyStrong =>
      zh(size: 13, weight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get label =>
      zh(size: 11, color: AppColors.textTertiary); // 標籤 / 說明
}
