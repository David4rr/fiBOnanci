import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/pocket_detail_modal.dart';
import 'package:fibonanci_app/presentation/screens/expense_history_screen.dart';
import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:fibonanci_app/presentation/widgets/transaction_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('ExpenseHistoryScreen Inline Edit & Arrow Morphing Tests', () {
    testWidgets('Tapping Kelola on transaction card slides inline to edit state without opening second modal', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isNotEmpty)),
      );

      final wallets = await repo.getWallets();
      final categories = await db.select(db.categories).get();
      const uuid = Uuid();
      final now = DateTime.now();

      // Seed a test expense transaction
      final txId = uuid.v4();
      await db.logTransactionWithBalanceMutation(
        tx: TransactionsCompanion(
          id: drift.Value(txId),
          walletId: drift.Value(wallets.first.id),
          categoryId: drift.Value(categories.first.id),
          amount: const drift.Value(150000.0),
          type: const drift.Value('expense'),
          notes: const drift.Value('Makan Malam Ramen'),
          transactionDate: drift.Value(now),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      final allTxs = await (db.select(db.transactions)..where((t) => t.isDeleted.equals(false))).get();

      addTearDown(bloc.close);
      addTearDown(db.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: ExpenseHistoryScreen(
                allTransactions: allTxs,
                wallets: wallets,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initial State: shows Riwayat Pengeluaran and down arrow
      expect(find.text('Riwayat\nPengeluaran'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('Makan Malam Ramen'), findsOneWidget);

      // 2. Tap transaction card to expand it and reveal "Kelola" button
      await tester.tap(find.text('Makan Malam Ramen'));
      await tester.pumpAndSettle();

      expect(find.text('Kelola'), findsOneWidget);

      // 3. Tap "Kelola" -> Should transition INLINE to TransactionDetailModal
      await tester.tap(find.text('Kelola'));
      await tester.pumpAndSettle();

      // Verify no multiple modal bottom sheets were stacked
      // The TransactionDetailModal is rendered directly inline in the PageView!
      expect(find.byType(TransactionDetailModal), findsOneWidget);

      // Verify form is top-aligned directly below app bar
      final appBarBottom = tester.getBottomLeft(find.byType(ExpenseHistoryAppBar)).dy;
      final modalTop = tester.getTopLeft(find.byType(TransactionDetailModal)).dy;
      expect(modalTop, lessThanOrEqualTo(appBarBottom + 24));

      // Verify app bar title switched to "Edit Transaksi"
      expect(find.text('Edit Transaksi'), findsOneWidget);
      expect(find.text('Makan Malam Ramen'), findsWidgets);

      // Verify chevron morphed into left arrow (Icons.keyboard_arrow_left_rounded)
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);

      // 4. Tap the morphed left arrow to return to the history deck
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // Verify returned to history deck and arrow morphed back to down chevron
      expect(find.text('Riwayat\nPengeluaran'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });
  });

  group('Savings Wallet Deposit & Withdrawal Consistency Tests', () {
    testWidgets('PocketTransferDialog provides consistent CurrencyAmountField and semantic button themes', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      await repo.addPocket(
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        type: 'emergency',
        colorHex: '#10B981',
        iconName: 'flag',
      );
      final pockets = await repo.getPockets();
      final pocket = pockets.first;
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isNotEmpty)),
      );

      addTearDown(bloc.close);
      addTearDown(db.close);

      // Test DEPOSIT
      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: true),
                  child: const Text('Deposit Button'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deposit Button'));
      await tester.pumpAndSettle();

      expect(find.text('Isi Dana ke Kantong'), findsOneWidget);
      // Verify CurrencyAmountField is used with label "Nominal"
      expect(find.byType(CurrencyAmountField), findsOneWidget);
      final depositAmountField = tester.widget<CurrencyAmountField>(find.byType(CurrencyAmountField));
      expect(depositAmountField.prefixColor, AppColors.neoMint);

      // Verify PrimaryActionButton uses neoMint for deposit
      final depositActionButton = tester.widget<PrimaryActionButton>(find.byType(PrimaryActionButton));
      expect(depositActionButton.backgroundColor, AppColors.neoMint);
      expect(depositActionButton.text, 'Konfirmasi');

      // Dismiss deposit sheet
      await tester.tap(find.descendant(of: find.byType(ModalHeader), matching: find.byIcon(Icons.keyboard_arrow_down_rounded)));
      await tester.pumpAndSettle();

      // Test WITHDRAWAL
      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: false),
                  child: const Text('Withdraw Button'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Withdraw Button'));
      await tester.pumpAndSettle();

      expect(find.text('Tarik Dana ke Rekening'), findsOneWidget);
      expect(find.byType(CurrencyAmountField), findsOneWidget);
      final withdrawAmountField = tester.widget<CurrencyAmountField>(find.byType(CurrencyAmountField));
      expect(withdrawAmountField.prefixColor, AppColors.neoCoral);

      // Verify PrimaryActionButton uses neoCoral for withdrawal (outflow)
      final withdrawActionButton = tester.widget<PrimaryActionButton>(find.byType(PrimaryActionButton));
      expect(withdrawActionButton.backgroundColor, AppColors.neoCoral);
      expect(withdrawActionButton.text, 'Konfirmasi');
    });

    testWidgets('PocketDetailActions renders balanced symmetrical tactile buttons for deposit and withdrawal', (tester) async {
      final pocketWithFunds = PocketEntry(
        id: 'p1',
        name: 'Liburan',
        type: 'goal',
        currentAmount: 2500000.0,
        targetAmount: 5000000.0,
        colorHex: '#3B82F6',
        iconName: 'flag',
        isSynced: false,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PocketDetailActions(
              pocket: pocketWithFunds,
              pocketColor: const Color(0xFF3B82F6),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify both buttons are present
      expect(find.text('Isi Dana'), findsOneWidget);
      expect(find.text('Tarik Dana'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.south_west_rounded), findsOneWidget);
      expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);

      // Both buttons are 48px high ElevatedButton widgets
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('PocketDetailModal transitions inline via PageView without secondary modal stacking', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      await repo.addPocket(
        name: 'Dana Liburan',
        targetAmount: 5000000.0,
        type: 'goal',
        colorHex: '#3B82F6',
        iconName: 'flag',
      );
      final pockets = await repo.getPockets();
      final pocket = pockets.first;
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isNotEmpty)),
      );

      addTearDown(bloc.close);
      addTearDown(db.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PocketDetailModal.show(context, pocket: pocket),
                  child: const Text('Buka Modal Kantong'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Open PocketDetailModal
      await tester.tap(find.text('Buka Modal Kantong'));
      await tester.pumpAndSettle();

      // Verify Tab 0 is displayed: ModalHeader shows pocket name, down arrow
      expect(find.text('Dana Liburan'), findsWidgets);
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.descendant(of: find.byType(ModalHeader), matching: find.byIcon(Icons.keyboard_arrow_down_rounded)), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);

      // Count modal routes: exactly 1 modal bottom sheet is open
      expect(find.byType(PocketDetailSheet), findsOneWidget);

      // 2. Tap "Isi Dana"
      await tester.tap(find.text('Isi Dana'));
      await tester.pumpAndSettle();

      // Verify STILL ONLY 1 modal sheet is open (NO second modal bottom sheet)
      expect(find.byType(PocketDetailSheet), findsOneWidget);

      // Verify inline transition to Tab 1:
      // Title changed to "Isi Dana ke Kantong", arrow morphed to left
      expect(find.text('Isi Dana ke Kantong'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.byType(PocketTransferForm), findsOneWidget);

      // 3. Tap left morphing arrow to return to Tab 0
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // Verify returned to Tab 0
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.descendant(of: find.byType(ModalHeader), matching: find.byIcon(Icons.keyboard_arrow_down_rounded)), findsOneWidget);
      expect(find.text('Isi Dana ke Kantong'), findsNothing);

      // 4. Tap "Isi Dana" again, enter amount, and confirm
      await tester.tap(find.text('Isi Dana'));
      await tester.pumpAndSettle();

      final amountField = find.widgetWithText(TextField, 'Nominal');
      await tester.enterText(amountField, '100000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      // After confirm, transitions back to Tab 0 with updated data (no dialog popped out to main screen)
      expect(find.byType(PocketDetailSheet), findsOneWidget);
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.text('Setoran ke Kantong Dana Liburan'), findsOneWidget);

      // 5. Tap the transaction tile inside PocketDetailModal to edit it inline
      await tester.tap(find.text('Setoran ke Kantong Dana Liburan'));
      await tester.pumpAndSettle();

      // Verify STILL ONLY 1 modal sheet is open (NO second modal bottom sheet)
      expect(find.byType(PocketDetailSheet), findsOneWidget);
      expect(find.text('Edit Transaksi'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // 6. Tap left arrow to return to Tab 0
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.descendant(of: find.byType(ModalHeader), matching: find.byIcon(Icons.keyboard_arrow_down_rounded)), findsOneWidget);
      expect(find.text('Edit Transaksi'), findsNothing);

      // 7. Tap transaction tile again, modify notes, and save
      await tester.tap(find.text('Setoran ke Kantong Dana Liburan'));
      await tester.pumpAndSettle();

      final notesField = find.widgetWithText(TextField, 'Catatan (Opsional)');
      await tester.enterText(notesField, 'Setoran ke Dana Liburan Bali');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify returned to Tab 0 with updated note
      expect(find.byType(PocketDetailSheet), findsOneWidget);
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.text('Setoran ke Dana Liburan Bali'), findsOneWidget);
    });

    testWidgets('PocketDetailModal deletes pocket using SlideToDeleteButton and confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      await repo.addPocket(
        name: 'Dana Darurat Baru',
        targetAmount: 10000000.0,
        type: 'emergency',
        colorHex: '#10B981',
        iconName: 'shield',
      );
      final pockets = await repo.getPockets();
      final pocket = pockets.first;
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isNotEmpty)),
      );

      addTearDown(bloc.close);
      addTearDown(db.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PocketDetailModal.show(context, pocket: pocket),
                  child: const Text('Open Pocket'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Pocket'));
      await tester.pumpAndSettle();

      // Verify SlideToDeleteButton is present
      final sliderFinder = find.byType(SlideToDeleteButton);
      expect(sliderFinder, findsOneWidget);
      expect(find.text('Hapus Kantong'), findsOneWidget);

      // Slide or tap to trigger delete
      await tester.tap(sliderFinder);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Hapus Kantong?'), findsOneWidget);
      expect(find.text('Kantong "Dana Darurat Baru" akan dihapus. Riwayat transaksi tetap tersimpan di buku kas.'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Verify modal is dismissed
      expect(find.byType(PocketDetailSheet), findsNothing);
    });
  });
}
