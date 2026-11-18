import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/core/notification_parser/bank_presets.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/add_wallet_modal.dart';
import 'package:fibonanci_app/presentation/modals/wallet/wallet_preset_chips.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('findBankPresetByQuery Unit Tests', () {
    test('accurately resolves Indonesian bank and e-wallet queries to respective packages', () {
      expect(findBankPresetByQuery('BCA')?.packageName, 'com.bca');
      expect(findBankPresetByQuery('Bank BCA')?.packageName, 'com.bca');
      expect(findBankPresetByQuery('BCA Mobile')?.packageName, 'com.bca');
      expect(findBankPresetByQuery('myBCA')?.packageName, 'com.bca.mybca');
      expect(findBankPresetByQuery('blu')?.packageName, 'com.bcadigital.blu');
      expect(findBankPresetByQuery('Mandiri')?.packageName, 'com.bankmandiri.livin');
      expect(findBankPresetByQuery('Livin Mandiri')?.packageName, 'com.bankmandiri.livin');
      expect(findBankPresetByQuery('Bank Jago')?.packageName, 'com.bankjago.app');
      expect(findBankPresetByQuery('Kantong Jago')?.packageName, 'com.bankjago.app');
      expect(findBankPresetByQuery('SeaBank')?.packageName, 'com.seabank.id');
      expect(findBankPresetByQuery('BRI')?.packageName, 'id.co.bri.brimo');
      expect(findBankPresetByQuery('BRImo')?.packageName, 'id.co.bri.brimo');
      expect(findBankPresetByQuery('BNI')?.packageName, 'id.co.bni.wondr');
      expect(findBankPresetByQuery('wondr')?.packageName, 'id.co.bni.wondr');
      expect(findBankPresetByQuery('GoPay')?.packageName, 'com.gojek.app');
      expect(findBankPresetByQuery('Gojek')?.packageName, 'com.gojek.app');
      expect(findBankPresetByQuery('DANA')?.packageName, 'id.dana');
      expect(findBankPresetByQuery('OVO')?.packageName, 'ovo.id');
      expect(findBankPresetByQuery('ShopeePay')?.packageName, 'com.shopee.id');
      expect(findBankPresetByQuery('Flip')?.packageName, 'id.flip');
      expect(findBankPresetByQuery('Rekening Pribadi'), isNull);
    });

    test('presets have correct metadata colors and wallet types', () {
      final bca = findBankPresetByQuery('BCA')!;
      expect(bca.type, 'bank');
      expect(bca.colorHex, '#0060AF');

      final jago = findBankPresetByQuery('Jago')!;
      expect(jago.type, 'bank');
      expect(jago.colorHex, '#FF7300');

      final gopay = findBankPresetByQuery('GoPay')!;
      expect(gopay.type, 'ewallet');
      expect(gopay.colorHex, '#00AED6');
      expect(gopay.iconName, 'smartphone');
    });
  });

  group('AddWalletModal Auto-Include Notification Package Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (call) async => null,
      );
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        null,
      );
      await db.close();
    });

    testWidgets('Tapping BCA preset chip automatically pre-fills name and auto-links com.bca notification', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await expectLater(bloc.stream, emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)));

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: Center(child: ElevatedButton(onPressed: () => AddWalletModal.show(ctx), child: const Text('Buka Modal'))),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka Modal'));
      await tester.pumpAndSettle();

      expect(find.byType(WalletPresetChips), findsOneWidget);
      final bcaChip = find.descendant(of: find.byType(WalletPresetChips), matching: find.text('BCA'));
      expect(bcaChip, findsOneWidget);
      await tester.tap(bcaChip);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'BCA'), findsOneWidget);
      expect(find.textContaining('Notifikasi transaksi otomatis terhubung (com.bca)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(1), '5000000');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan Rekening'));
      await tester.tap(find.text('Simpan Rekening'));
      await tester.pumpAndSettle();

      final wallets = await repo.getWallets();
      final createdWallet = wallets.firstWhere((w) => w.name == 'BCA');
      expect(createdWallet.colorHex, '#0060AF');
      expect(createdWallet.type, 'bank');

      final rules = await repo.getNotificationRulesForWallet(createdWallet.id);
      expect(rules.length, 1);
      expect(rules.first.packageName, 'com.bca');
      expect(rules.first.isEnabled, isTrue);
    });

    testWidgets('Typing Bank Mandiri in Name field auto-links com.bankmandiri.livin in real-time', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await expectLater(bloc.stream, emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)));

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: Center(child: ElevatedButton(onPressed: () => AddWalletModal.show(ctx), child: const Text('Buka Modal'))),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak Terhubung (Input Manual)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Bank Mandiri');
      await tester.pumpAndSettle();

      expect(find.textContaining('Notifikasi transaksi otomatis terhubung (com.bankmandiri.livin)'), findsOneWidget);

      await tester.ensureVisible(find.text('Simpan Rekening'));
      await tester.tap(find.text('Simpan Rekening'));
      await tester.pumpAndSettle();

      final wallets = await repo.getWallets();
      final mandiri = wallets.firstWhere((w) => w.name == 'Bank Mandiri');
      final rules = await repo.getNotificationRulesForWallet(mandiri.id);
      expect(rules.single.packageName, 'com.bankmandiri.livin');
    });
  });
}
