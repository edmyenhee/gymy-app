import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymy/app.dart';
import 'package:gymy/core/db/app_database.dart';
import 'package:gymy/core/providers.dart';

void main() {
  // 測試環境不抓網路字體；體組成串流用空 stream（避免 drift / path_provider）。
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('App 啟動並套用主題', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bodyMetricsStreamProvider
              .overrideWith((ref) => Stream.value(const <BodyMetric>[])),
        ],
        child: const GymyApp(),
      ),
    );

    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('開始訓練'), findsOneWidget);
  });
}
