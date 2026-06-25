/// 全 App 共用常數。
class AppConstants {
  AppConstants._();

  /// 自用測試階段的固定使用者 ID。
  ///
  /// 所有資料表都帶這個 userId，未來多人時資料結構不需大改。
  /// TODO(上線前): 接上真正的登入與多使用者管理後改為動態值。
  static const String currentUserId = 'local-user';
}
