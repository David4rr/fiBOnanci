import 'package:fibonanci_app/presentation/widgets/overlapping_deck.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Tapping history item opens edit modal without crash and allows reassigning wallet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 950 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    // 1. Seed and add initial transaction
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name.contains('BCA Utama'));
    final seaBank = wallets.firstWhere((w) => w.name.contains('SeaBank'));
    final categories = await db.select(db.categories).get();

    const uuid = Uuid();
    final now = DateTime.now().toUtc();
    final txId = uuid.v4();

    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(txId),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(50000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Kopi Kenangan'),
        transactionDate: drift.Value(now),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    // 2. Launch App
    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    print('OverlappingDeckItem count: ${find.byType(OverlappingDeckItem).evaluate().length}');
    // 3. Verify Kopi Kenangan is rendered in history
    expect(find.text('Kopi Kenangan'), findsOneWidget);

    // 4. Tap the history item to expand it!
    await tester.tap(find.text('Kopi Kenangan'));
    await tester.pumpAndSettle();

    // Tap "Kelola" action button on expanded card to open Edit modal
    expect(find.text('Kelola'), findsOneWidget);
    await tester.tap(find.text('Kelola'));
    await tester.pumpAndSettle();

    // 5. Verify Edit modal appears cleanly without crash!
    expect(find.text('Edit Transaksi'), findsOneWidget);
    expect(find.textContaining('REKENING PENYIMPANAN'), findsOneWidget);

    // 6. Test reassigning wallet to SeaBank
    await db.updateTransactionWithWalletReassignment(
      txId: txId,
      newWalletId: seaBank.id,
      newAmount: 50000.0,
      newType: 'expense',
      newCategoryId: categories.first.id,
      newNotes: 'Kopi Kenangan Pindah ke SeaBank',
    );

    // Close modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    final txAfter = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
    expect(txAfter.walletId, seaBank.id);

    await db.close();
  });
}
