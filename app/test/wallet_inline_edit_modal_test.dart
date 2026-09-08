import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail_screen.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:fibonanci_app/presentation/widgets/transaction_modal.dart';
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('WalletDetailScreen Inline Sliding Tab & Morphing Arrow Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Tapping Ubah Saldo slides inline to edit tab, flips arrow left, and morphs back', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // Navigate to Wallets tab
      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      // Tap BCA card to open WalletDetailScreen
      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();

      // Verify WalletDetailScreen is rendered in detail view
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.text('Informasi & Mutasi'), findsOneWidget);
      expect(find.text('Ubah Saldo'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsNothing);

      // Tap Ubah Saldo to slide inline to edit tab
      await tester.tap(find.text('Ubah Saldo'));
      await tester.pumpAndSettle();

      // Verify title updated and arrow morphed to point left
      expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsOneWidget);
      expect(find.text('Perbarui Saldo'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

      // Verify Ubah Saldo fields start at top below app bar, not pushed to bottom
      final amountOffset = tester.getTopLeft(find.descendant(of: find.byType(WalletDetailEditTab), matching: find.byType(CurrencyAmountField)));
      final appBarBottom = tester.getBottomLeft(find.byType(WalletDetailAppBar)).dy;
      expect(amountOffset.dy, lessThanOrEqualTo(appBarBottom + 24));
      // Verify SlideToDeleteButton is present on the edit tab
      expect(find.byType(SlideToDeleteButton), findsOneWidget);
      expect(find.text('Hapus Rekening'), findsOneWidget);

      // Tap the morphed left arrow to return to details view
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // Verify returned to details view and arrow flipped back to point down
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.text('Informasi & Mutasi'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsNothing);

      // Tapping down arrow closes WalletDetailScreen
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(WalletDetailScreen), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Slide-to-delete in edit tab triggers confirmation dialog and deletes wallet', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // Navigate to Wallets tab
      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      // Tap BCA card to open WalletDetailScreen
      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();

      // Tap Ubah Saldo to slide to edit tab
      await tester.tap(find.text('Ubah Saldo'));
      await tester.pumpAndSettle();

      // Drag SlideToDeleteButton thumb across threshold
      final sliderFinder = find.byType(SlideToDeleteButton);
      expect(sliderFinder, findsOneWidget);

      await tester.drag(sliderFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Hapus Rekening?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Verify wallet was deleted
      final activeWallets = await repo.getWallets();
      expect(activeWallets.any((w) => w.id == 'wallet-bca'), isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Tapping Catat Transaksi slides inline to add transaction tab, flips arrow left, and morphs back', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();

      // Tap Catat Transaksi to slide inline to add tx tab
      await tester.tap(find.text('Catat Transaksi'));
      await tester.pumpAndSettle();

      // Verify title updated, subtitle shows wallet name, and arrow morphed to point left
      expect(find.text('Catat Transaksi'), findsWidgets);
      expect(find.text('Rekening: BCA Utama'), findsOneWidget);
      expect(find.text('Simpan Transaksi'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

      // Verify widgets start at top below app bar, not pushed to the bottom of the screen
      final toggleOffset = tester.getTopLeft(find.byType(TransactionTypeToggle));
      final appBarBottom = tester.getBottomLeft(find.byType(WalletDetailAppBar)).dy;
      expect(toggleOffset.dy, lessThanOrEqualTo(appBarBottom + 24));
      // Tap the morphed left arrow to return to details view
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // Verify returned to details view
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.text('Informasi & Mutasi'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsNothing);

      // Tap Catat Transaksi again and save a transaction
      await tester.tap(find.text('Catat Transaksi'));
      await tester.pumpAndSettle();

      final amountField = find.descendant(of: find.byType(TransactionModal), matching: find.byType(TextField)).first;
      await tester.enterText(amountField, '200000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      // Returned to details view and transaction is recorded
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.textContaining('200.000'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Tapping a transaction tile in history slides inline to edit transaction tab and allows slide-to-delete', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final wallets = await repo.getWallets();
      final bca = wallets.firstWhere((w) => w.name.contains('BCA'));
      final categories = await repo.getCategories();
      await repo.addTransaction(
        walletId: bca.id,
        categoryId: categories.first.id,
        amount: 85000.0,
        type: 'expense',
        notes: 'Belanja Mingguan',
        transactionDate: DateTime.now(),
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();

      // Verify Belanja Mingguan transaction tile is rendered in history
      expect(find.text('Belanja Mingguan'), findsOneWidget);

      // Tap transaction tile to slide inline to edit tx tab
      await tester.tap(find.text('Belanja Mingguan'));
      await tester.pumpAndSettle();

      // Verify title updated to Edit Transaksi, subtitle shows notes, arrow points left
      expect(find.text('Edit Transaksi'), findsOneWidget);
      expect(find.text('Belanja Mingguan'), findsWidgets);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Hapus Transaksi'), findsOneWidget);

      // Tap morphed left arrow to return to details view
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      // Tap transaction tile again to slide to edit tab
      await tester.tap(find.text('Belanja Mingguan'));
      await tester.pumpAndSettle();

      // Slide-to-delete transaction
      final sliderFinder = find.byType(SlideToDeleteButton);
      expect(sliderFinder, findsOneWidget);

      await tester.drag(sliderFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Hapus Transaksi?'), findsOneWidget);
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Returns to details view and transaction is deleted
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.text('Belanja Mingguan'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
