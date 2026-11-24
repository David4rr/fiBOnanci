import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/screens/expense_history_screen.dart';
import 'package:fibonanci_app/presentation/widgets/calendar/activity_calendar_matrix.dart';
import 'package:fibonanci_app/presentation/widgets/calendar/duolingo_animated_flame.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('ActivityCalendarMatrix & Heatmap Widget Tests', () {
    final now = DateTime.now();
    final testWallets = [
      WalletEntry(
        id: 'w1', name: 'BCA Utama', type: 'bank', currency: 'IDR',
        balance: 5000000.0, colorHex: '#10B981', iconName: 'wallet',
        createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
      ),
    ];

    final testTxs = [
      TransactionEntry(
        id: 'tx1', profileId: 'p1', walletId: 'w1', categoryId: 'c1',
        amount: 2500000, type: 'income', notes: 'Gaji Freelance', source: 'manual',
        transactionDate: DateTime(now.year, now.month, 1, 10, 0),
        createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
      ),
      TransactionEntry(
        id: 'tx2', profileId: 'p1', walletId: 'w1', categoryId: 'c2',
        amount: 75000, type: 'expense', notes: 'Makan Siang', source: 'manual',
        transactionDate: DateTime(now.year, now.month, 1, 12, 30),
        createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
      ),
    ];

    testWidgets('renders month navigator, weekday labels, streak banner, and grid cells with nominals', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCalendarMatrix(
              allTransactions: testTxs,
              wallets: testWallets,
              dailySafePace: 150000,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check weekday headers
      expect(find.text('SEN'), findsOneWidget);
      expect(find.text('SEL'), findsOneWidget);
      expect(find.text('RAB'), findsOneWidget);
      expect(find.text('KAM'), findsOneWidget);
      expect(find.text('JUM'), findsOneWidget);
      expect(find.text('SAB'), findsOneWidget);
      expect(find.text('MIN'), findsOneWidget);

      // Check centered streak text and subtitle
      expect(find.textContaining('Streak'), findsWidgets);
      expect(find.text('Streak Hemat'), findsOneWidget);

      // Day 1 exists
      expect(find.text('1'), findsWidgets);

      // Day 1 shows compact expense nominal (75k) rather than fire icon
      expect(find.text('75k'), findsOneWidget);

      // Duolingo animated flame vector is present on header streak banner
      expect(find.byType(DuolingoAnimatedFlame), findsWidgets);
    });

    testWidgets('tapping a day selects it and renders detail peek card with transactions', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      TransactionEntry? managedTx;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCalendarMatrix(
              allTransactions: testTxs,
              wallets: testWallets,
              onManageTransaction: (tx) => managedTx = tx,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Day 1
      await tester.tap(find.text('1').first);
      await tester.pumpAndSettle();

      // Detail peek should show income, expense, and daily allocation
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Alokasi Harian'), findsOneWidget);

      // Transactions on Day 1: Gaji Freelance & Makan Siang
      expect(find.text('Gaji Freelance'), findsOneWidget);
      expect(find.text('Makan Siang'), findsOneWidget);

      // Tap transaction
      await tester.tap(find.text('Gaji Freelance'));
      await tester.pumpAndSettle();
      expect(managedTx?.id, equals('tx1'));
    });

    testWidgets('ExpenseHistoryScreen toggles view between card deck and activity matrix', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseHistoryScreen(
              allTransactions: testTxs,
              wallets: testWallets,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially in deck view
      expect(find.text('Riwayat\nTransaksi'), findsOneWidget);
      expect(find.byType(ActivityCalendarMatrix), findsNothing);

      // Tap calendar toggle button
      final toggleBtn = find.byKey(const Key('expense_history_toggle_calendar_button'));
      expect(toggleBtn, findsOneWidget);
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      // Now in Activity Calendar view!
      expect(find.text('Aktivitas\nKeuangan'), findsOneWidget);
      expect(find.byType(ActivityCalendarMatrix), findsOneWidget);

      // Tap toggle button again to switch back
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      // Back to deck view
      expect(find.text('Riwayat\nTransaksi'), findsOneWidget);
      expect(find.byType(ActivityCalendarMatrix), findsNothing);
    });
  });
}
