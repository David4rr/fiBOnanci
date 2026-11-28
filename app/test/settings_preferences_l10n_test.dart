import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/core/l10n/locale_notifier.dart';
import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/l10n/app_localizations.dart';
import 'package:fibonanci_app/presentation/modals/settings/settings_language_selector.dart';
import 'package:fibonanci_app/presentation/modals/settings/settings_style.dart';

void main() {
  tearDown(() {
    ProfilePreferencesStorage.resetForTest();
    localeNotifier.value = const Locale('id');
  });

  testWidgets('SettingsStyle.menuRow hides chevron when onTap is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SettingsStyle.menuRow(title: 'Static Row', valueText: 'Active'),
              SettingsStyle.menuRow(title: 'Tappable Row', valueText: 'Open', onTap: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  test('isBalanceHidden persists across ProfilePreferencesStorage reload and new FinanceBloc', () async {
    final tempDir = await Directory.systemTemp.createTemp('fibonanci_prefs_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final prefsFile = File('${tempDir.path}/prefs.json');

    ProfilePreferencesStorage.setStorageFile(prefsFile);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftFinanceRepository(db);

    final bloc1 = FinanceBloc(repository: repo);
    bloc1.add(const LoadFinanceData());
    await bloc1.stream.firstWhere((s) => s.status == FinanceStatus.success);
    bloc1.add(const ToggleBalanceVisibilityEvent(true));
    await bloc1.stream.firstWhere((s) => s.isBalanceHidden);
    await bloc1.close();

    // Simulate fresh app launch
    ProfilePreferencesStorage.setStorageFile(prefsFile);
    await ProfilePreferencesStorage.load();
    final bloc2 = FinanceBloc(repository: repo);
    bloc2.add(const LoadFinanceData());
    final loaded = await bloc2.stream.firstWhere((s) => s.status == FinanceStatus.success);

    expect(loaded.isBalanceHidden, isTrue);
    await bloc2.close();
    await db.close();
  });

  testWidgets('SettingsLanguageSelector switches app locale between ID and EN', (tester) async {
    localeNotifier.value = const Locale('id');

    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: localeNotifier,
        builder: (context, locale, _) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Column(
                children: [
                  const SettingsLanguageSelector(),
                  Text(AppL10n.of(ctx).financialReportTitle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Laporan Keuangan'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings_language_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Financial Report'), findsOneWidget);
    expect(localeNotifier.value.languageCode, 'en');
  });
}
