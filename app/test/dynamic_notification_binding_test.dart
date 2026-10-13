import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/core/notification_parser/bank_presets.dart';
import 'package:fibonanci_app/core/notification_parser/notification_parser.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/wallet/installed_app_picker_modal.dart';
import 'package:fibonanci_app/presentation/modals/wallet/wallet_binding_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/presentation/modals/add_wallet_modal.dart';
import 'package:fibonanci_app/core/native_bridge/notification_bridge.dart';
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Dynamic Notification Binding Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('BankAppPresets includes Krom Bank and popular Indonesian digital banks', () {
      final kromPreset = findBankPresetByPackage('id.krom.bank');
      expect(kromPreset, isNotNull);
      expect(kromPreset!.name, 'Krom Bank');
      expect(kromPreset.packageName, 'id.krom.bank');

      expect(kPopularBankAppPresets.any((p) => p.name == 'Krom Bank'), isTrue);
      expect(kPopularBankAppPresets.any((p) => p.name == 'Bank Jago'), isTrue);
      expect(kPopularBankAppPresets.any((p) => p.name == 'SeaBank Indonesia'), isTrue);
    });

    test('Creating a wallet with arbitrary name and boundPackageName inserts NotificationRule in SQLite', () async {
      // 1. Add wallet with random custom name, bound to Krom Bank package
      await repo.addWallet(
        name: 'Krom Tabungan Maxi 8.75%',
        type: 'bank',
        initialBalance: 1500000.0,
        colorHex: '#00E5FF',
        iconName: 'wallet',
        boundPackageName: 'id.krom.bank',
      );

      // 2. Verify wallet exists
      final wallets = await repo.getWallets();
      final kromWallet = wallets.firstWhere((w) => w.name == 'Krom Tabungan Maxi 8.75%');
      expect(kromWallet, isNotNull);
      expect(kromWallet.balance, 1500000.0);

      // 3. Verify NotificationRule was automatically created and linked to this wallet
      final rules = await repo.getNotificationRulesForWallet(kromWallet.id);
      expect(rules.length, 1);
      expect(rules.first.packageName, 'id.krom.bank');
      expect(rules.first.walletId, kromWallet.id);
      expect(rules.first.isEnabled, isTrue);

      // 4. Verify package is in active notification package whitelist
      final activePackages = await db.getActiveNotificationPackages();
      expect(activePackages.contains('id.krom.bank'), isTrue);
    });

    test('Dynamic Notification Rule matches incoming notification to the correct custom-named wallet', () async {
      // 1. Add custom wallet with user-chosen arbitrary name
      await repo.addWallet(
        name: 'Rekening Bebas Bunga Tinggi',
        type: 'bank',
        initialBalance: 200000.0,
        colorHex: '#10B981',
        iconName: 'landmark',
        boundPackageName: 'id.krom.bank',
      );

      final wallets = await repo.getWallets();
      final targetWallet = wallets.firstWhere((w) => w.name == 'Rekening Bebas Bunga Tinggi');

      // 2. Incoming notification from Krom Bank with universal text pattern
      const rawPkg = 'id.krom.bank';
      const rawTitle = 'Krom Bank';
      const rawBody = 'Transfer masuk sebesar Rp 350.000 dari SITI RAHMAWATI telah berhasil.';

      final parsed = NotificationParser.parse(
        packageName: rawPkg,
        title: rawTitle,
        body: rawBody,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, 350000.0);
      expect(parsed.type, 'income');

      // 3. Resolve wallet dynamically using Database NotificationRule
      final rule = await db.getNotificationRuleForPackage(rawPkg);
      expect(rule, isNotNull);
      expect(rule!.walletId, targetWallet.id);

      final matchedWallet = wallets.firstWhere((w) => w.id == rule.walletId);
      expect(matchedWallet.name, 'Rekening Bebas Bunga Tinggi');

      // 4. Record transaction and mutate balance
      final categories = await repo.getCategories();
      final incomeCat = categories.firstWhere((c) => c.type == 'income');

      await repo.addTransaction(
        walletId: matchedWallet.id,
        categoryId: incomeCat.id,
        amount: parsed.amount,
        type: parsed.type,
        notes: parsed.counterparty,
        source: 'notification_auto',
        externalRef: parsed.externalRef,
      );

      // 5. Verify wallet balance was mutated accurately
      final updatedWallets = await repo.getWallets();
      final finalWallet = updatedWallets.firstWhere((w) => w.id == matchedWallet.id);
      expect(finalWallet.balance, 550000.0); // 200.000 + 350.000
    });

    test('Unbinding and re-binding packages dynamically updates rules', () async {
      await repo.addWallet(
        name: 'Custom Digital Bank',
        type: 'bank',
        initialBalance: 100000.0,
        colorHex: '#3B82F6',
        iconName: 'wallet',
        boundPackageName: 'com.custom.bankapp',
      );

      final wallets = await repo.getWallets();
      final wallet = wallets.firstWhere((w) => w.name == 'Custom Digital Bank');

      var rule = await db.getNotificationRuleForPackage('com.custom.bankapp');
      expect(rule, isNotNull);
      expect(rule!.isEnabled, isTrue);

      // Unbind
      await repo.unbindPackage('com.custom.bankapp');
      rule = await db.getNotificationRuleForPackage('com.custom.bankapp');
      expect(rule, isNull);

      // Rebind to Krom Bank
      await repo.bindWalletToPackage(walletId: wallet.id, packageName: 'id.krom.bank');
      final newRule = await db.getNotificationRuleForPackage('id.krom.bank');
      expect(newRule, isNotNull);
      expect(newRule!.walletId, wallet.id);
    });

    testWidgets('Tapping Cari App button opens InstalledAppPickerModal and picks package', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (call) async {
          if (call.method == 'getInstalledBankApps') {
            return [
              {'packageName': 'id.krom.bank', 'appName': 'Krom Bank'},
              {'packageName': 'id.co.bankbkemobile.digitalbank', 'appName': 'SeaBank'},
            ];
          }
          return null;
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.fibonanci.app/notification_service'),
          null,
        );
      });

      final controller = TextEditingController();
      String? pickedPkg;
      bool customFlag = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletBindingSelector(
              selectedPackage: null,
              isCustomPackage: false,
              customPackageController: controller,
              onPackageChanged: (pkg, custom) {
                pickedPkg = pkg;
                customFlag = custom;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cari App'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Tap Cari App to open modal
      await tester.tap(find.text('Cari App'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(InstalledAppPickerModal), findsOneWidget);
      expect(find.text('Pilih Aplikasi'), findsOneWidget);

      // Search for Krom
      await tester.enterText(find.byType(TextField), 'Krom');
      await tester.pumpAndSettle();

      expect(find.text('Krom Bank'), findsOneWidget);
      expect(find.text('id.krom.bank'), findsOneWidget);

      // Tap Krom Bank in the list
      await tester.tap(find.text('Krom Bank'));
      await tester.pumpAndSettle();

      // Modal closed, package selected
      expect(find.byType(InstalledAppPickerModal), findsNothing);
      expect(controller.text, 'id.krom.bank');
      expect(pickedPkg, 'id.krom.bank');
      expect(customFlag, isTrue);
    });

    testWidgets('AddWalletModal Cari App slides inline without opening a second modal', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (call) async {
          if (call.method == 'getInstalledBankApps') {
            return [
              {'packageName': 'id.krom.bank', 'appName': 'Krom Bank'},
              {'packageName': 'id.co.bankbkemobile.digitalbank', 'appName': 'SeaBank'},
            ];
          }
          return null;
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.fibonanci.app/notification_service'),
          null,
        );
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
      );

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => AddWalletModal.show(ctx),
                    child: const Text('Open Add Wallet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add Wallet'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Rekening Baru'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsNothing);

      // Enter wallet name before sliding to app picker
      await tester.enterText(find.byType(TextField).first, 'Tabungan Krom Utama');
      await tester.pumpAndSettle();

      // Tap Cari App -> slides inline inside AddWalletModal, flips arrow left
      await tester.tap(find.text('Cari App'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Aplikasi'), findsOneWidget);
      expect(find.text('Cari bank atau e-wallet di HP Anda'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
      expect(find.byType(InstalledAppPickerModal), findsOneWidget);

      // Search and pick Krom Bank
      await tester.enterText(
        find.descendant(of: find.byType(InstalledAppPickerModal), matching: find.byType(TextField)),
        'Krom',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Krom Bank'));
      await tester.pumpAndSettle();

      // Slides back inline to Tambah Rekening Baru with package populated
      expect(find.text('Tambah Rekening Baru'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.widgetWithText(TextField, 'id.krom.bank'), findsOneWidget);

      // Save wallet
      await tester.tap(find.text('Simpan Rekening'));
      await tester.pumpAndSettle();

      final wallets = await repo.getWallets();
      final created = wallets.firstWhere((w) => w.name == 'Tabungan Krom Utama');
      final rules = await repo.getNotificationRulesForWallet(created.id);
      expect(rules.single.packageName, 'id.krom.bank');
    });

    test('SeaBank to Bank Jago transfer captures both notifications without accountNumber across package aliases', () async {
      // Create custom-named wallets WITHOUT accountNumber, bound via preset or real Play Store packages
      await repo.addWallet(
        name: 'Dompet SeaBankku',
        type: 'bank',
        accountNumber: null,
        initialBalance: 500000.0,
        colorHex: '#FF5722',
        iconName: 'landmark',
        boundPackageName: 'com.seabank.id',
      );
      await repo.addWallet(
        name: 'Dompet Bang Jago',
        type: 'bank',
        accountNumber: null,
        initialBalance: 200000.0,
        colorHex: '#FF7300',
        iconName: 'sparkles',
        boundPackageName: 'com.bankjago.app',
      );

      // 1. Outgoing notification from real Play Store SeaBank package (id.co.bankbkemobile.digitalbank)
      await NotificationBridge.handleRawNotification(
        {
          'package': 'id.co.bankbkemobile.digitalbank',
          'title': 'Transfer Berhasil',
          'text': 'Transfer sebesar Rp 50.000 ke Bank Jago - DAVID telah berhasil.',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        db,
      );

      // 2. Incoming notification from real Play Store Bank Jago package (com.jago.digitalBanking)
      await NotificationBridge.handleRawNotification(
        {
          'package': 'com.jago.digitalBanking',
          'title': 'Uang Masuk',
          'text': 'Kantong Utama menerima Rp 50.000 dari SEABANK INDONESIA - DAVID.',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        db,
      );

      final updatedWallets = await repo.getWallets();
      final seaWallet = updatedWallets.firstWhere((w) => w.name == 'Dompet SeaBankku');
      final jagoWallet = updatedWallets.firstWhere((w) => w.name == 'Dompet Bang Jago');

      expect(seaWallet.balance, 450000.0);
      expect(jagoWallet.balance, 250000.0);
    });

    test('Multi-bank transfers (Livin Mandiri, myBCA, wondr BNI, Neobank, Superbank, GoPay) resolve across Play Store package aliases without account numbers', () async {
      await repo.addWallet(name: 'Rekening Mandiri', type: 'bank', initialBalance: 1000000.0, colorHex: '#2563EB', iconName: 'landmark', boundPackageName: 'com.bankmandiri.livin');
      await repo.addWallet(name: 'Rekening myBCA', type: 'bank', initialBalance: 500000.0, colorHex: '#0066AE', iconName: 'landmark', boundPackageName: 'com.bca.mybca');
      await repo.addWallet(name: 'Tabungan wondr', type: 'bank', initialBalance: 400000.0, colorHex: '#FF6B00', iconName: 'landmark', boundPackageName: 'id.co.bni.wondr');
      await repo.addWallet(name: 'Tabungan Neo', type: 'bank', initialBalance: 300000.0, colorHex: '#FACC15', iconName: 'sparkles', boundPackageName: 'com.bankneo.neobank');
      await repo.addWallet(name: 'Dompet GoPay', type: 'ewallet', initialBalance: 100000.0, colorHex: '#00AED6', iconName: 'smartphone', boundPackageName: 'com.gojek.app');

      final now = DateTime.now().millisecondsSinceEpoch;
      // 1. Livin Mandiri (id.bmri.livin) -> myBCA (com.bca.mybca.omni.android)
      await NotificationBridge.handleRawNotification({'package': 'id.bmri.livin', 'title': 'Transfer Berhasil', 'text': 'Transfer sebesar Rp 150.000 ke BCA - BUDI berhasil.', 'timestamp': now}, db);
      await NotificationBridge.handleRawNotification({'package': 'com.bca.mybca.omni.android', 'title': 'Dana Masuk', 'text': 'Transfer masuk sebesar Rp 150.000 dari MANDIRI - BUDI.', 'timestamp': now + 1}, db);

      // 2. wondr BNI (id.bni.wondr) -> Neobank (com.bnc.finance)
      await NotificationBridge.handleRawNotification({'package': 'id.bni.wondr', 'title': 'Transaksi Berhasil', 'text': 'Kamu baru aja kirim Rp 75.000 ke BANK NEO COMMERCE.', 'timestamp': now + 2}, db);
      await NotificationBridge.handleRawNotification({'package': 'com.bnc.finance', 'title': 'Dana Masuk', 'text': 'Dana masuk Rp 75.000 dari BNI berhasil masuk ke Tabungan Neo NOW.', 'timestamp': now + 3}, db);

      // 3. GoPay standalone app (com.gojek.gopay) payment
      await NotificationBridge.handleRawNotification({'package': 'com.gojek.gopay', 'title': 'GoPay', 'text': 'Pembayaran Rp 25.000 di Kopi Kenangan berhasil', 'timestamp': now + 4}, db);

      final updated = await repo.getWallets();
      expect(updated.firstWhere((w) => w.name == 'Rekening Mandiri').balance, 850000.0);
      expect(updated.firstWhere((w) => w.name == 'Rekening myBCA').balance, 650000.0);
      expect(updated.firstWhere((w) => w.name == 'Tabungan wondr').balance, 325000.0);
      expect(updated.firstWhere((w) => w.name == 'Tabungan Neo').balance, 375000.0);
      expect(updated.firstWhere((w) => w.name == 'Dompet GoPay').balance, 75000.0);
    });
  });
}
