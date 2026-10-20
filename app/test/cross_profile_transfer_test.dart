import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/widgets/expense_category_helpers.dart';
import 'package:fibonanci_app/presentation/widgets/transaction_cross_profile_selector.dart';
import 'package:fibonanci_app/presentation/widgets/transaction_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Cross-Profile Transfer - Database Mutations', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('executes atomic cross-profile transfer between 2 profiles', () async {
      // 1. Setup Profile A (Pribadi) and Profile B (Management Perumahan)
      await repo.addProfile(username: 'Pribadi', fullName: 'David Pribadi');
      await repo.addProfile(username: 'Perumahan', fullName: 'Pengurus Perumahan');

      final profiles = await repo.getProfiles();
      final profileA = profiles.firstWhere((p) => p.username == 'Pribadi');
      final profileB = profiles.firstWhere((p) => p.username == 'Perumahan');

      // 2. Add wallets to each profile
      await repo.addWallet(
        name: 'BCA Pribadi',
        type: 'bank',
        initialBalance: 1000000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
        profileId: profileA.id,
      );
      await repo.addWallet(
        name: 'Kas Mandiri Perumahan',
        type: 'bank',
        initialBalance: 500000.0,
        colorHex: '#3B82F6',
        iconName: 'account_balance',
        profileId: profileB.id,
      );
      final walletsA = await (db.select(db.wallets)..where((t) => t.profileId.equals(profileA.id))).get();
      final walletsB = await (db.select(db.wallets)..where((t) => t.profileId.equals(profileB.id))).get();

      final walletA = walletsA.first;
      final walletB = walletsB.first;

      // 3. Perform cross-profile transfer: 150.000 from BCA Pribadi to Kas Mandiri Perumahan
      await db.logCrossProfileTransferMutation(
        sourceWalletId: walletA.id,
        destinationWalletId: walletB.id,
        amount: 150000.0,
        notes: 'Iuran Kebersihan Mei',
      );

      // Verify balances
      final updatedWalletA = await (db.select(db.wallets)..where((t) => t.id.equals(walletA.id))).getSingle();
      final updatedWalletB = await (db.select(db.wallets)..where((t) => t.id.equals(walletB.id))).getSingle();

      expect(updatedWalletA.balance, 850000.0);
      expect(updatedWalletB.balance, 650000.0);

      // Verify transactions in Profile A
      final txsA = await (db.select(db.transactions)..where((t) => t.profileId.equals(profileA.id))).get();
      expect(txsA.length, 1);
      final outTx = txsA.first;
      expect(outTx.type, 'expense');
      expect(outTx.amount, 150000.0);
      expect(outTx.notes, contains('Transfer ke Perumahan (Kas Mandiri Perumahan)'));
      expect(outTx.notes, contains('Iuran Kebersihan Mei'));
      expect(outTx.externalRef, startsWith('cross_profile_'));

      // Verify transactions in Profile B
      final txsB = await (db.select(db.transactions)..where((t) => t.profileId.equals(profileB.id))).get();
      expect(txsB.length, 1);
      final inTx = txsB.first;
      expect(inTx.type, 'income');
      expect(inTx.amount, 150000.0);
      expect(inTx.notes, contains('Transfer masuk dari Pribadi (BCA Pribadi)'));
      expect(inTx.notes, contains('Iuran Kebersihan Mei'));
      expect(inTx.externalRef, equals(outTx.externalRef));

      // 4. Test automatic paired reversal when one side is deleted
      await db.deleteTransactionWithBalanceReversal(outTx.id);

      final revertedWalletA = await (db.select(db.wallets)..where((t) => t.id.equals(walletA.id))).getSingle();
      final revertedWalletB = await (db.select(db.wallets)..where((t) => t.id.equals(walletB.id))).getSingle();

      expect(revertedWalletA.balance, 1000000.0);
      expect(revertedWalletB.balance, 500000.0);

      final postDelOutTx = await (db.select(db.transactions)..where((t) => t.id.equals(outTx.id))).getSingle();
      final postDelInTx = await (db.select(db.transactions)..where((t) => t.id.equals(inTx.id))).getSingle();

      expect(postDelOutTx.isDeleted, isTrue);
      expect(postDelInTx.isDeleted, isTrue);
    });
  });

  group('Cross-Profile Transfer - Visual Resolution', () {
    test('resolves card visuals for outgoing and incoming cross-profile transfers', () {
      final now = DateTime.now();
      final outTx = TransactionEntry(
        id: 'out_1',
        walletId: 'w_1',
        categoryId: '11111111-1111-4111-8111-111111111111',
        amount: 150000.0,
        type: 'expense',
        transactionDate: now,
        source: 'manual',
        externalRef: 'cross_profile_test_uuid',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
        notes: 'Transfer ke Perumahan (Kas Mandiri)',
      );

      final inTx = TransactionEntry(
        id: 'in_1',
        walletId: 'w_2',
        categoryId: '11111111-1111-4111-8111-111111111111',
        amount: 150000.0,
        type: 'income',
        transactionDate: now,
        source: 'manual',
        externalRef: 'cross_profile_test_uuid',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
        notes: 'Transfer masuk dari Pribadi (BCA)',
      );

      final outVisual = TransactionVisualResolver.resolve(tx: outTx);
      expect(outVisual.categoryLabel, 'TRANSFER KELUAR');
      expect(outVisual.cardColor, TransactionVisualResolver.transferBlue);
      expect(outVisual.iconData, Icons.north_east_rounded);

      final inVisual = TransactionVisualResolver.resolve(tx: inTx);
      expect(inVisual.categoryLabel, 'TRANSFER MASUK');
      expect(inVisual.cardColor, TransactionVisualResolver.incomeMint);
      expect(inVisual.iconData, Icons.south_west_rounded);
    });
  });

  group('Cross-Profile Transfer - UI Modal', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('renders cross-profile target selector when multiple profiles exist', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Seed 2 profiles
      await repo.addProfile(username: 'Pribadi', fullName: 'David Pribadi');
      await repo.addProfile(username: 'Perumahan', fullName: 'Pengurus Perumahan');
      final profiles = await repo.getProfiles();
      final pA = profiles.firstWhere((p) => p.username == 'Pribadi');
      final pB = profiles.firstWhere((p) => p.username == 'Perumahan');
      await repo.setActiveProfile(pA.id);

      await repo.addWallet(name: 'BCA Pribadi', type: 'bank', initialBalance: 1000000, colorHex: '#10B981', iconName: 'wallet', profileId: pA.id);
      await repo.addWallet(name: 'Kas Mandiri Perum', type: 'bank', initialBalance: 500000, colorHex: '#3B82F6', iconName: 'wallet', profileId: pB.id);
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      await tester.pumpWidget(MaterialApp(
          home: BlocProvider<FinanceBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: TransactionModal(isInline: true),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Switch to Transfer tab
      await tester.tap(find.text('Transfer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check that TransactionTransferDestinationSelector is rendered with consistent dropdown
      expect(find.byType(TransactionTransferDestinationSelector), findsOneWidget);
      expect(find.textContaining('Profil: Pribadi (Profil Ini)'), findsOneWidget);

      // Tap profile dropdown to open menu
      await tester.tap(find.textContaining('Profil: Pribadi (Profil Ini)'));
      await tester.pumpAndSettle();

      // Tap "Perumahan (Lintas Profil)" in the dropdown menu
      await tester.tap(find.textContaining('Perumahan (Lintas Profil)').last);
      await tester.pumpAndSettle();
      // Destination wallet dropdown now immediately displays the wallet from Perumahan profile
      expect(find.text('Kas Mandiri Perum'), findsWidgets);
      expect(find.text('• Masuk Kas'), findsOneWidget);
    });
  });
}
