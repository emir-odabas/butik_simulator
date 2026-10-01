// Smoke test: the app boots and the Atelier IndexTabBar shows all 5 tabs.
import 'package:butik_simulator/app/app.dart';
import 'package:butik_simulator/core/design/components/index_tab_bar.dart';
import 'package:butik_simulator/data/datasources/local/local_storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots and shows the index tab navigation', (tester) async {
    // google_fonts tries to download fonts at runtime; there is no
    // network in tests, so disable fetching and ignore the resulting
    // font-load errors (text falls back to the default font).
    GoogleFonts.config.allowRuntimeFetching = false;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('google_fonts')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await initializeDateFormatting('tr_TR');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const BoutiqueApp(),
      ),
    );
    await tester.pumpAndSettle();

    Finder tab(String label) => find.descendant(
          of: find.byType(IndexTabBar),
          matching: find.text(label),
        );

    expect(tab('Ana Sayfa'), findsOneWidget);
    expect(tab('Mağazam'), findsOneWidget);
    expect(tab('Ürünler'), findsOneWidget);
    expect(tab('Siparişler'), findsOneWidget);
    expect(tab('Profil'), findsOneWidget);
  });
}
