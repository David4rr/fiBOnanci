import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/bento_folder_card.dart';
import 'package:fibonanci_app/presentation/widgets/folder_tab_card.dart';
import 'package:fibonanci_app/presentation/widgets/overlapping_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
void main() {
  testWidgets('FolderTabCard renders child and clips without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FolderTabCard(
            backgroundColor: AppColors.neoChartreuse,
            child: Text('Safe to Spend'),
          ),
        ),
      ),
    );

    expect(find.text('Safe to Spend'), findsOneWidget);
  });

  testWidgets('OverlappingDeckItem renders title, category, and formatted currency', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OverlappingDeckItem(
            title: 'Kopi Kenangan',
            category: 'Makanan & Minuman',
            amount: 35000.0,
            categoryColor: AppColors.neoCoral,
            iconData: Icons.coffee,
          ),
        ),
      ),
    );

    expect(find.text('Kopi Kenangan'), findsOneWidget);
    expect(find.text('MAKANAN & MINUMAN'), findsOneWidget);
    expect(find.textContaining('35.000'), findsOneWidget);
  });

  testWidgets('OverlappingDeckItem expanded displays daily spending for active day, not weekly sum', (tester) async {
    // Wednesday 2026-10-14 -> activeDayIndex = 2
    final txDate = DateTime(2026, 10, 14, 12, 0);
    // Mon: 100k, Tue: 200k, Wed: 50k, Thu..Sun: 0
    final weeklySpending = [100000.0, 200000.0, 50000.0, 0.0, 0.0, 0.0, 0.0];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverlappingDeckItem(
            title: 'Kopi Kenangan',
            category: 'PENGELUARAN',
            amount: 35000.0,
            categoryColor: AppColors.neoCoral,
            iconData: Icons.coffee,
            isExpanded: true,
            transactionDate: txDate,
            weeklySpending: weeklySpending,
          ),
        ),
      ),
    );

    // Header amount is individual transaction
    expect(find.textContaining('35.000'), findsOneWidget);
    // Chart nominal must be Wednesday daily spending (50.000), NOT weekly sum (350.000)
    expect(find.textContaining('50.000'), findsOneWidget);
    expect(find.textContaining('350.000'), findsNothing);
  });

  testWidgets('BentoFolderCard renders title, subtitle, progress and handles tap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BentoFolderCard(
            backgroundColor: AppColors.neoMint,
            iconData: Icons.shield_outlined,
            title: 'Rp 15.000.000',
            subtitle: 'Dana Darurat',
            progress: 0.6,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Rp 15.000.000'), findsOneWidget);
    expect(find.text('Dana Darurat'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

    await tester.tap(find.byType(BentoFolderCard));
    expect(tapped, isTrue);
  });

  testWidgets('StackedCardDeckScrollList isolates expanded weekly spending and daily total per walletId', (tester) async {
    initializeDateFormatting('id_ID', null);
    final now = DateTime(2026, 10, 14, 12, 0);
    final wallets = <WalletEntry>[
      WalletEntry(
        id: 'w_bca', name: 'BCA Utama', type: 'bank', currency: 'IDR',
        balance: 1000000.0, iconName: 'account_balance', colorHex: '#D4F442',
        createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
      ),
      WalletEntry(
        id: 'w_gopay', name: 'GoPay', type: 'ewallet', currency: 'IDR',
        balance: 500000.0, iconName: 'account_balance_wallet', colorHex: '#99E6FF',
        createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
      ),
    ];
    final txBca = TransactionEntry(
      id: 'tx_bca', walletId: 'w_bca', categoryId: 'c1', source: 'manual',
      amount: 35000.0, type: 'expense', notes: 'Kopi Kenangan',
      transactionDate: now, createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
    );
    final txGopay = TransactionEntry(
      id: 'tx_gopay', walletId: 'w_gopay', categoryId: 'c1', source: 'manual',
      amount: 80000.0, type: 'expense', notes: 'Makan Siang',
      transactionDate: now, createdAt: now, updatedAt: now, isSynced: false, isDeleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: StackedCardDeckScrollList(
              transactions: [txBca, txGopay],
              wallets: wallets,
              expandedTxId: 'tx_bca',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // BCA card expanded: dailyTotal should be 35.000 for BCA, NOT 115.000 (BCA + GoPay)
    expect(find.textContaining('35.000'), findsWidgets);
    expect(find.textContaining('115.000'), findsNothing);

    // Tap Makan Siang (GoPay) to toggle expand GoPay card
    await tester.tap(find.text('Makan Siang'));
    await tester.pumpAndSettle();

    // GoPay card expanded: dailyTotal should be 80.000 for GoPay, NOT 115.000
    expect(find.textContaining('80.000'), findsWidgets);
    expect(find.textContaining('115.000'), findsNothing);
  });
}
