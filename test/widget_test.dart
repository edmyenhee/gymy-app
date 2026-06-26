import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymy/app.dart';

void main() {
  // 測試環境不抓網路字體，改用 fallback，避免 flaky。
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('App 啟動並套用主題', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymyApp()));

    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('開始訓練'), findsOneWidget);
  });
}
