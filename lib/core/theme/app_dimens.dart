import 'package:flutter/widgets.dart';

/// 設計 token：間距。
///
/// 原型 padding / gap 為範圍值（page 22–24、card 13–18、gap 9–14），
/// 這裡收斂成固定階梯，畫面一律吃這些常數。
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const double page = 22; // 頁面左右 padding
  static const double card = 16; // 卡片內 padding
  static const double gap = 12; // 元素間距
}

/// 設計 token：圓角。
class AppRadius {
  AppRadius._();

  static const double input = 12; // 輸入框（原型 10–13）
  static const double card = 18; // 卡片（原型 15–20）
  static const double pill = 26; // CTA / 膠囊（原型 23–29）
  static const double sheet = 28; // 彈出層上緣

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius pillRadius =
      BorderRadius.all(Radius.circular(pill));
  static const BorderRadius inputRadius =
      BorderRadius.all(Radius.circular(input));
  static const BorderRadius sheetTop =
      BorderRadius.vertical(top: Radius.circular(sheet));
}

/// 設計 token：陰影 / 發光。
class AppShadows {
  AppShadows._();

  /// 主 CTA 綠色陰影：0 9px 22px rgba(95,227,154,.3)。
  static const List<BoxShadow> accentButton = [
    BoxShadow(
      color: Color(0x4D5FE39A),
      offset: Offset(0, 9),
      blurRadius: 22,
    ),
  ];
}
