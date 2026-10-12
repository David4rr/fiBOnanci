import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/profile_modal.dart';
import 'package:fibonanci_app/presentation/widgets/profile_avatar.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:fibonanci_app/presentation/widgets/dashboard_bento_grid.dart';
import 'package:flutter/material.dart';
import 'package:fibonanci_app/core/formatters/app_currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('Minimalist Cardless Settings Feature Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('EditProfileTab excludes Currency & Income Target; SettingsTab manages them inline', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await bloc.stream.firstWhere((s) => s.status == FinanceStatus.success && s.profiles.isNotEmpty);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ProfileModal.show(context, walletCount: 2, txCount: 0),
                  child: const Text('Open Profile'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();

      // 1. Open Edit Profile inline by tapping ProfileAvatar
      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileEditTab), findsOneWidget);
      // Currency selector & Target Pemasukan Bulanan must NOT be in EditProfileTab
      expect(find.text('Mata Uang Utama'), findsNothing);
      expect(find.text('Target Pemasukan Bulanan'), findsNothing);

      // Return to Profile Summary
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // 2. Open 3-dot morphing menu and navigate to Pengaturan (Tab 4)
      await tester.tap(find.byKey(const Key('profile_morphing_menu_trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_settings_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile_settings_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSettingsTab), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('PENGATURAN GLOBAL • SEMUA PROFIL'), findsOneWidget);
      expect(find.textContaining('PENGATURAN PROFIL • @'), findsOneWidget);
      expect(find.text('Mata Uang Utama'), findsOneWidget);
      expect(find.text('Target Pemasukan Bulanan'), findsOneWidget);

      // Initially Settings shows only clean menu rows (sub-controls collapsed)
      expect(find.byKey(const Key('settings_currency_USD')), findsNothing);
      expect(find.byKey(const Key('settings_cycle_day_25')), findsNothing);
      expect(find.byKey(const Key('settings_add_category_toggle')), findsNothing);

      // 3. Tap Mata Uang Utama menu row -> opens sub-route inside modal with left back arrow
      AppCurrency.resetRates();
      await tester.tap(find.byKey(const Key('settings_currency_menu_row')));
      await tester.pumpAndSettle();
      expect(find.text('PILIH MATA UANG'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings_currency_USD')));
      await tester.pumpAndSettle();
      expect(bloc.state.profile.currency, 'USD');
      expect(find.byKey(const Key('settings_exchange_rate_row')), findsOneWidget);
      expect(find.text('Rp 16.000'), findsOneWidget);

      // Edit custom offline rate to 1 USD = Rp 15.000
      await tester.tap(find.byKey(const Key('settings_exchange_rate_row')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('settings_exchange_rate_input')), '15000');
      await tester.tap(find.byKey(const Key('settings_exchange_rate_save')));
      await tester.pumpAndSettle();
      expect(AppCurrency.rateFor('USD'), 15000.0);

      // Tap left back arrow in modal header to return to Pengaturan root menu
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('PENGATURAN GLOBAL • SEMUA PROFIL'), findsOneWidget);
      expect(find.textContaining('PENGATURAN PROFIL • @'), findsOneWidget);

      // Enter $ 5.000 income target in sub-route -> auto-returns to Pengaturan root menu on Save
      await tester.tap(find.byKey(const Key('settings_income_target_row')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('settings_income_target_input')), '5000');
      await tester.tap(find.byKey(const Key('settings_income_target_save')));
      await tester.pumpAndSettle();
      expect(find.textContaining(r'$ 5.000'), findsOneWidget);
      expect(bloc.state.profile.monthlyIncomeTarget, 75000000.0);
      AppCurrency.resetRates();

      // 4. Tap Tanggal Mulai Siklus menu row -> opens sub-route, select Tgl 25, then custom Tgl 18, then tap back arrow
      await tester.tap(find.byKey(const Key('settings_cycle_day_menu_row')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_cycle_day_25')));
      await tester.pumpAndSettle();
      expect(bloc.state.budgetCycleDay, 25);
      await tester.enterText(find.byKey(const Key('settings_custom_cycle_day_input')), '18');
      await tester.tap(find.byKey(const Key('settings_custom_cycle_day_save')));
      await tester.pumpAndSettle();
      expect(bloc.state.budgetCycleDay, 18);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();
      // 5. Toggle Privacy Balance Masking on Pengaturan root menu
      await tester.tap(find.byKey(const Key('settings_privacy_switch')));
      await tester.pumpAndSettle();
      expect(bloc.state.isBalanceHidden, isTrue);

      // 6. Tap Kategori Transaksi menu row -> opens sub-route & add category
      final initialCatCount = bloc.state.categories.length;
      await tester.tap(find.byKey(const Key('settings_category_menu_row')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_add_category_toggle')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('settings_new_category_input')), 'Kopi & Nongkrong');
      await tester.tap(find.byKey(const Key('settings_save_category_button')));
      await tester.pumpAndSettle();

      expect(bloc.state.categories.length, initialCatCount + 1);
      expect(find.text('Kopi & Nongkrong'), findsOneWidget);

      // 7. Tap back arrow to return to Pengaturan root, then verify CSV / Excel file export & Hapus/Reset Profil sub-route
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('settings_export_csv_row')), 120, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byKey(const Key('settings_export_csv_row')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_export_csv_file_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings_export_saved_path')), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings_export_excel_file_btn')));
      await tester.pumpAndSettle();
      expect(find.textContaining('.xls'), findsWidgets);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('settings_delete_profile_row')), 120, scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('ZONA BAHAYA • @'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings_delete_profile_row')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings_confirm_delete_profile_button')), findsOneWidget);
    });

    testWidgets('When isBalanceHidden is enabled, each masked nominal has an eye icon to peek individually', (tester) async {
      const metrics = SafeToSpendMetrics(
        totalRealBalance: 10000000,
        pendingBills: 1000000,
        safeToSpendMonthly: 9000000,
        safeToSpendDaily: 300000,
        daysRemainingInMonth: 30,
        healthStatus: FinancialHealthStatus.comfortable,
        selectedWalletsCount: 1,
        isAllWallets: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardBentoGrid(
              metrics: metrics,
              wallets: const [],
              subscriptions: const [],
              currencyFormatter: AppCurrency.forCode('IDR'),
              isBalanceHidden: true,
              onNavigateToWallets: () {},
              onNavigateToSubscriptions: () {},
            ),
          ),
        ),
      );

      // All 4 Bento cards are masked and each has an eye icon
      expect(find.text('Rp •••••••'), findsNWidgets(4));
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(4));
      expect(find.text('Rp 9.000.000'), findsNothing);

      // Tap the first eye icon (Safe to Spend) to peek
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();

      // Only Safe to Spend is revealed; the other 3 remain masked
      expect(find.text('Rp 9.000.000'), findsOneWidget);
      expect(find.text('Rp •••••••'), findsNWidgets(3));
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap the eye-off icon to hide it again
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.text('Rp 9.000.000'), findsNothing);
      expect(find.text('Rp •••••••'), findsNWidgets(4));
    });
  });
}
