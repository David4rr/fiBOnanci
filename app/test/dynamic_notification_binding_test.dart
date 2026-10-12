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
  });
}
