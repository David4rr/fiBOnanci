import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/l10n/app_localizations.dart';
import 'package:fibonanci_app/core/storage/kofi_prompt_storage.dart';
import 'package:fibonanci_app/presentation/modals/kofi_support_modal.dart';

void main() {
  late Directory tempDir;
  late File storageFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kofi_prompt_test_');
    storageFile = File('${tempDir.path}/kofi_prompt_state.json');
    KofiPromptStorage.setStorageFile(storageFile);
  });

  tearDown(() async {
    KofiPromptStorage.resetForTest();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('KofiPromptStorage', () {
    test('does not show on first 2 opens, shows on 3rd open', () async {
      final now = DateTime(2026, 11, 26, 10, 0);
      expect(KofiPromptStorage.shouldShowPrompt(now: now), isFalse);

      await KofiPromptStorage.recordAppOpen();
      expect(KofiPromptStorage.shouldShowPrompt(now: now), isFalse);

      await KofiPromptStorage.recordAppOpen();
      expect(KofiPromptStorage.shouldShowPrompt(now: now), isFalse);

      await KofiPromptStorage.recordAppOpen();
      expect(KofiPromptStorage.shouldShowPrompt(now: now), isTrue);
    });

    test('snoozes for 14 days and resumes after cooldown', () async {
      final t0 = DateTime(2026, 11, 26, 10, 0);
      for (var i = 0; i < 3; i++) {
        await KofiPromptStorage.recordAppOpen();
      }
      expect(KofiPromptStorage.shouldShowPrompt(now: t0), isTrue);

      await KofiPromptStorage.snooze(now: t0);
      expect(KofiPromptStorage.shouldShowPrompt(now: t0.add(const Duration(days: 13))), isFalse);
      expect(KofiPromptStorage.shouldShowPrompt(now: t0.add(const Duration(days: 14))), isTrue);
    });

    test('permanent dismiss persists across reload', () async {
      final now = DateTime(2026, 11, 26, 10, 0);
      for (var i = 0; i < 3; i++) {
        await KofiPromptStorage.recordAppOpen();
      }
      await KofiPromptStorage.markSupportedOrDismissed();
      expect(KofiPromptStorage.shouldShowPrompt(now: now), isFalse);

      // Reload from disk
      KofiPromptStorage.setStorageFile(storageFile);
      await KofiPromptStorage.load();
      expect(KofiPromptStorage.shouldShowPrompt(now: now), isFalse);
    });
  });

  group('KofiSupportModal', () {
    testWidgets('renders Indonesian copy and handles never-show-again', (tester) async {
      KofiPromptStorage.setStorageFile(null);
      for (var i = 0; i < 3; i++) {
        await KofiPromptStorage.recordAppOpen();
      }

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => KofiSupportModal.show(ctx),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('kofi_support_modal')), findsOneWidget);
      expect(find.text('Suka pakai fiBOnanci?'), findsOneWidget);
      expect(find.text('Dukung di Ko-fi'), findsOneWidget);

      await tester.tap(find.byKey(const Key('kofi_never_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('kofi_support_modal')), findsNothing);
      expect(KofiPromptStorage.shouldShowPrompt(), isFalse);
    });
  });
}
