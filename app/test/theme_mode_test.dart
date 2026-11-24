import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/presentation/modals/settings/settings_theme_selector.dart';
import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/theme/app_theme.dart';
import 'package:fibonanci_app/presentation/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File storageFile;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fibonanci_theme_test_');
    storageFile = File('${tempDir.path}/test_prefs.json');
    ProfilePreferencesStorage.setStorageFile(storageFile);
  });

  tearDown(() async {
    ProfilePreferencesStorage.resetForTest();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    AppColors.updateBrightness(Brightness.dark);
    themeModeNotifier.value = ThemeMode.system;
  });

  group('AppPalette & AppColors Brightness Tests', () {
    test('Dark palette values are active when Brightness.dark', () {
      AppColors.updateBrightness(Brightness.dark);

      expect(AppColors.isDark, isTrue);
      expect(AppColors.canvasBg, const Color(0xFF0C0D11));
      expect(AppColors.canvasCardSurface, const Color(0xFF17181F));
      expect(AppColors.textPrimary, Colors.white);
      expect(AppColors.textWhite, Colors.white);
      expect(AppTypography.modalTitle.color, Colors.white);
      expect(AppTypography.heroGreeting.color, Colors.white);
    });

    test('Light palette values are active when Brightness.light', () {
      AppColors.updateBrightness(Brightness.light);

      expect(AppColors.isDark, isFalse);
      expect(AppColors.canvasBg, const Color(0xFF1E1714));
      expect(AppColors.canvasCardSurface, const Color(0xFF2B211B));
      expect(AppColors.textPrimary, const Color(0xFFFAF5EE));
      expect(AppColors.textWhite, const Color(0xFFFAF5EE));
      expect(AppColors.borderSubtle, const Color(0x24FFFFFF));
      expect(AppTypography.modalTitle.color, const Color(0xFFFAF5EE));
      expect(AppTypography.heroGreeting.color, const Color(0xFFFAF5EE));
    });

    test('Brand accents remain constant across themes', () {
      AppColors.updateBrightness(Brightness.dark);
      expect(AppColors.neoChartreuse, const Color(0xFFD4F442));
      expect(AppColors.neoMint, const Color(0xFF7DF24E));
      expect(AppColors.textAccent, const Color(0xFFD4F442));
      expect(AppColors.textIncome, const Color(0xFF7DF24E));
      expect(AppColors.statusComfortable, const Color(0xFFD4F442));

      AppColors.updateBrightness(Brightness.light);
      expect(AppColors.neoChartreuse, const Color(0xFFD4F442));
      expect(AppColors.neoMint, const Color(0xFF7DF24E));
      expect(AppColors.textAccent, const Color(0xFFD4F442));
      expect(AppColors.textIncome, const Color(0xFF7DF24E));
      expect(AppColors.statusComfortable, const Color(0xFFD4F442));
    });
  });

  group('AppTheme & Storage Tests', () {
    test('parseAppThemeMode correctly converts strings to ThemeMode', () {
      expect(parseAppThemeMode('system'), ThemeMode.system);
      expect(parseAppThemeMode('dark'), ThemeMode.dark);
      expect(parseAppThemeMode('light'), ThemeMode.light);
      expect(parseAppThemeMode('invalid'), ThemeMode.system);
      expect(parseAppThemeMode(null), ThemeMode.system);
    });

    test('ThemeMode persists to ProfilePreferencesStorage', () async {
      setAppThemeMode(ThemeMode.light);
      expect(themeModeNotifier.value, ThemeMode.light);

      final stored = ProfilePreferencesStorage.getThemeMode();
      expect(stored, 'light');

      setAppThemeMode(ThemeMode.dark);
      expect(themeModeNotifier.value, ThemeMode.dark);
      expect(ProfilePreferencesStorage.getThemeMode(), 'dark');

      setAppThemeMode(ThemeMode.system);
      expect(themeModeNotifier.value, ThemeMode.system);
      expect(ProfilePreferencesStorage.getThemeMode(), 'system');
    });
  });

  group('SettingsThemeSelector Widget Tests', () {
    testWidgets('renders single circular button and cycles through 3 modes when tapped', (tester) async {
      themeModeNotifier.value = ThemeMode.system;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (context, mode, _) {
                return const Center(child: SettingsThemeSelector());
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cycleBtn = find.byKey(const Key('theme_cycle_toggle_btn'));
      expect(cycleBtn, findsOneWidget);
      expect(find.text('Tema Tampilan'), findsOneWidget);
      expect(find.text('Sistem'), findsOneWidget);

      // Tap 1: System -> Light
      await tester.tap(cycleBtn);
      await tester.pumpAndSettle();
      expect(themeModeNotifier.value, ThemeMode.light);
      expect(find.text('Terang'), findsOneWidget);

      // Tap 2: Light -> Dark
      await tester.tap(cycleBtn);
      await tester.pumpAndSettle();
      expect(themeModeNotifier.value, ThemeMode.dark);
      expect(find.text('Gelap'), findsOneWidget);

      // Tap 3: Dark -> System
      await tester.tap(cycleBtn);
      await tester.pumpAndSettle();
      expect(themeModeNotifier.value, ThemeMode.system);
      expect(find.text('Sistem'), findsOneWidget);
    });
  });
}
