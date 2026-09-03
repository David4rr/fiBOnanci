import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail_screen.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card.dart';
import 'package:fibonanci_app/presentation/modals/add_wallet_modal.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Wallet Account Number Functionality Tests', () {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    testWidgets('WalletCard renders dash (-) when accountNumber is null or empty', (tester) async {
      final now = DateTime.now().toUtc();
      final walletWithoutAcc = WalletEntry(
        id: 'w_no_acc',
        name: 'Bank Jago Kosong',
        type: 'bank',
        currency: 'IDR',
        balance: 150000.0,
        colorHex: '#FF7300',
        iconName: 'wallet',
        accountNumber: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final walletWithEmptyAcc = WalletEntry(
        id: 'w_empty_acc',
        name: 'Bank Mandiri Blank',
        type: 'bank',
        currency: 'IDR',
        balance: 250000.0,
        colorHex: '#002D62',
        iconName: 'wallet',
        accountNumber: '   ',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WalletCard(
                  wallet: walletWithoutAcc,
                  index: 0,
                  fmt: fmt,
                  cardH: 220,
                  showBottomLayout: true,
                ),
                WalletCard(
                  wallet: walletWithEmptyAcc,
                  index: 1,
                  fmt: fmt,
                  cardH: 220,
                  showBottomLayout: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Both cards should display '-' for their account number
      expect(find.text('-'), findsNWidgets(2));
    });

    testWidgets('WalletCard renders user-entered account number when present', (tester) async {
      final now = DateTime.now().toUtc();
      const customAcc = '5410-9823-4100';
      final walletWithAcc = WalletEntry(
        id: 'w_custom_acc',
        name: 'BCA Prioritas',
        type: 'bank',
        currency: 'IDR',
        balance: 10000000.0,
        colorHex: '#0060AF',
        iconName: 'landmark',
        accountNumber: customAcc,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: walletWithAcc,
              index: 0,
              fmt: fmt,
              cardH: 220,
              showBottomLayout: true,
            ),
          ),
        ),
      );

      expect(find.text(customAcc), findsOneWidget);
      expect(find.text('-'), findsNothing);
    });

    test('DriftFinanceRepository persists optional accountNumber correctly', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);

      // 1. Add wallet with account number
      await repo.addWallet(
        name: 'Krom Bank Tech',
        type: 'bank',
        accountNumber: '9900112233',
        initialBalance: 750000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
      );

      // 2. Add wallet without account number
      await repo.addWallet(
        name: 'Dompet Tunai Saku',
        type: 'cash',
        accountNumber: null,
        initialBalance: 50000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
      );

      final wallets = await repo.getWallets();
      final krom = wallets.firstWhere((w) => w.name == 'Krom Bank Tech');
      final cash = wallets.firstWhere((w) => w.name == 'Dompet Tunai Saku');

      expect(krom.accountNumber, '9900112233');
      expect(cash.accountNumber, isNull);

      // 3. Update wallet balance and account number
      await repo.updateWalletBalance(cash.id, 65000.0, accountNumber: 'CASH-01');
      final updatedCash = (await repo.getWallets()).firstWhere((w) => w.id == cash.id);
      expect(updatedCash.balance, 65000.0);
      expect(updatedCash.accountNumber, 'CASH-01');

      await db.close();
    });

    testWidgets('AddWalletModal allows optional account number and saves to database', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      final repo = DriftFinanceRepository(db);
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
                    child: const Text('Open Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Rekening Baru'), findsOneWidget);
      expect(find.text('Nomor Rekening (Opsional, cth: 5410982341)'), findsOneWidget);

      // Enter Name, Balance, and Account Number
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Bank Neo Commerce');
      await tester.enterText(textFields.at(1), '1500000');
      await tester.enterText(textFields.at(2), '8899001122');
      await tester.pumpAndSettle();

      // Tap Simpan Rekening
      await tester.tap(find.text('Simpan Rekening'));
      await tester.pumpAndSettle();

      // Verify new wallet in database
      final wallets = await repo.getWallets();
      final neoWallet = wallets.firstWhere((w) => w.name == 'Bank Neo Commerce');
      expect(neoWallet.accountNumber, '8899001122');
      expect(neoWallet.balance, 1500000.0);

      await db.close();
    });

    testWidgets('AddWalletModal left blank defaults to null and displays dash (-)', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      final repo = DriftFinanceRepository(db);
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
                    child: const Text('Open Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter Name and Balance, leave Account Number blank
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Tabungan Celengan');
      await tester.enterText(textFields.at(1), '200000');
      // Field at index 2 left untouched
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Rekening'));
      await tester.pumpAndSettle();

      final wallets = await repo.getWallets();
      final celengan = wallets.firstWhere((w) => w.name == 'Tabungan Celengan');
      expect(celengan.accountNumber, isNull);

      // Render WalletCard for this wallet -> must show '-'
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: celengan,
              index: 0,
              fmt: fmt,
              cardH: 220,
              showBottomLayout: true,
            ),
          ),
        ),
      );
      expect(find.text('-'), findsOneWidget);

      await db.close();
    });

    testWidgets('Tapping hero card in WalletDetailScreen copies accountNumber to Clipboard', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Mock Clipboard handler
      String? copiedData;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            copiedData = (methodCall.arguments as Map)['text'] as String?;
            return null;
          }
          return null;
        },
      );

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      final repo = DriftFinanceRepository(db);

      const testAcc = '1234567890';
      await repo.addWallet(
        name: 'BCA Digital Copy',
        type: 'bank',
        accountNumber: testAcc,
        initialBalance: 500000.0,
        colorHex: '#0060AF',
        iconName: 'landmark',
      );

      final wallets = await repo.getWallets();
      final wallet = wallets.firstWhere((w) => w.name == 'BCA Digital Copy');

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
            home: Scaffold(
              body: WalletDetailScreen(
                walletId: wallet.id,
                currencyFormatter: fmt,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the hero card
      final cardFinder = find.byType(WalletCard);
      expect(cardFinder, findsOneWidget);
      await tester.tap(cardFinder);
      await tester.pump();

      expect(copiedData, testAcc);
      expect(find.text('Nomor rekening $testAcc disalin'), findsOneWidget);

      await db.close();
    });
  });
}
