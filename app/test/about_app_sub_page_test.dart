import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/core/update/app_update_downloader.dart';
import 'package:fibonanci_app/core/update/app_update_service.dart';
import 'package:fibonanci_app/presentation/modals/settings/in_app_update_progress_card.dart';
import 'package:fibonanci_app/presentation/modals/settings/profile_settings_tab.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File storageFile;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fibonanci_about_test_');
    storageFile = File('${tempDir.path}/test_prefs.json');
    ProfilePreferencesStorage.setStorageFile(storageFile);
  });

  tearDown(() async {
    ProfilePreferencesStorage.resetForTest();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('SettingsAboutAppSubPage Widget Tests', () {
    testWidgets('renders hero brand identity, version, and architecture specs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsAboutAppSubPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hero Brand
      expect(find.text('fiBOnanci'), findsOneWidget);
      expect(find.text('Smart Offline-First Finance Intelligence'), findsOneWidget);
      expect(find.text('v${AppUpdateService.currentVersion} • Build 5'), findsOneWidget);

      // Section Headers
      expect(find.text('STATUS & PEMBARUAN APLIKASI'), findsOneWidget);
      expect(find.text('TENTANG & ARSITEKTUR APLIKASI'), findsOneWidget);

      // Update Controls
      expect(find.text('Pembaruan Otomatis'), findsOneWidget);
      expect(find.byKey(const Key('settings_auto_update_switch')), findsOneWidget);
      expect(find.byKey(const Key('about_check_update_now_btn')), findsOneWidget);

      // Specs
      expect(find.text('MIT Open Source'), findsOneWidget);
      expect(find.text('SQLite 3 (SQLCipher)'), findsOneWidget);
      expect(find.text('Deterministic Regex'), findsOneWidget);
      expect(find.text('David4rr/fiBOnanci'), findsOneWidget);
      expect(find.text('Catatan Rilis Lengkap'), findsOneWidget);
    });

    testWidgets('toggling auto-update switch persists preference in storage', (tester) async {
      expect(ProfilePreferencesStorage.getAutoUpdateCheck(), isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsAboutAppSubPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byKey(const Key('settings_auto_update_switch'));
      expect(switchFinder, findsOneWidget);

      // Toggle OFF
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(ProfilePreferencesStorage.getAutoUpdateCheck(), isFalse);

      // Toggle ON
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(ProfilePreferencesStorage.getAutoUpdateCheck(), isTrue);
    });

    testWidgets('tapping check update now button triggers check state transition', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsAboutAppSubPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkBtn = find.byKey(const Key('about_check_update_now_btn'));
      expect(checkBtn, findsOneWidget);

      await tester.tap(checkBtn);
      await tester.pumpAndSettle();

      // In test environment without network client, checkForUpdate returns null safely
      expect(find.byKey(const Key('about_check_update_now_btn')), findsOneWidget);
    });

    testWidgets('InAppUpdateProgressCard renders running and completed states', (tester) async {
      bool installed = false;

      // 1. Running state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppUpdateProgressCard(
              version: '1.0.5',
              progressInfo: const DownloadProgressInfo(
                status: 'running',
                bytesDownloaded: 14 * 1024 * 1024,
                totalBytes: 28 * 1024 * 1024,
                progress: 0.50,
              ),
              onInstall: () => installed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mengunduh v1.0.5...'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('14.0 MB / 28.0 MB'), findsOneWidget);
      expect(find.text('Pembersihan Otomatis Aktif'), findsOneWidget);

      // 2. Completed state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppUpdateProgressCard(
              version: '1.0.5',
              progressInfo: const DownloadProgressInfo(
                status: 'successful',
                bytesDownloaded: 28 * 1024 * 1024,
                totalBytes: 28 * 1024 * 1024,
                progress: 1.0,
              ),
              onInstall: () => installed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pembaruan v1.0.5 Siap Dipasang'), findsOneWidget);
      expect(find.byKey(const Key('install_downloaded_apk_btn')), findsOneWidget);

      await tester.tap(find.byKey(const Key('install_downloaded_apk_btn')));
      await tester.pumpAndSettle();
      expect(installed, isTrue);
    });

    testWidgets('UserFriendlyChangelogView renders formatted categorized items', (tester) async {
      const raw = '''
* feat: multi-profile switching
* fix: history tap layout overflow
* perf: sqlite isolate query indexing
''';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserFriendlyChangelogView(releaseNotes: raw),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FITUR BARU'), findsOneWidget);
      expect(find.text('PERBAIKAN BUG'), findsOneWidget);
      expect(find.text('PENINGKATAN & PERFORMA'), findsOneWidget);
      expect(find.text('Multi-profile switching'), findsOneWidget);
      expect(find.text('History tap layout overflow'), findsOneWidget);
    });

    test('SettingsSubRoute contains aboutApp with accurate titles', () {
      expect(SettingsSubRoute.aboutApp.title, 'Tentang Aplikasi');
      expect(SettingsSubRoute.aboutApp.subtitle, contains('Informasi'));
    });
  });
}
