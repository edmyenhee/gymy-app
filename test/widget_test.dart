import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymy/app.dart';
import 'package:gymy/core/db/app_database.dart';
import 'package:gymy/core/providers.dart';

void main() {
  // 字體不抓網路；DB 用 in-memory；體組成串流用空 stream（避免 drift 計時器殘留）。
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('App 啟動並套用主題', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
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
