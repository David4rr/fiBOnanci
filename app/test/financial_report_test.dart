import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/domain/services/financial_report_service.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/modals/profile_modal.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('FinancialReportService Pure Domain Tests', () {
    final refDate = DateTime(2026, 10, 15, 12, 0);

    final wallets = [
      WalletEntry(
        id: 'w-bca', profileId: 'p-1', name: 'BCA Utama', type: 'bank',
        currency: 'IDR', balance: 12000000, colorHex: '#0066AE', iconName: 'bank',
        accountNumber: '1234', createdAt: refDate, updatedAt: refDate,
        isSynced: false, isDeleted: false,
      ),
      WalletEntry(
        id: 'w-gopay', profileId: 'p-1', name: 'GoPay', type: 'ewallet',
        currency: 'IDR', balance: 500000, colorHex: '#00AED6', iconName: 'wallet',
        accountNumber: null, createdAt: refDate, updatedAt: refDate,
        isSynced: false, isDeleted: false,
      ),
    ];

    final pockets = [
      PocketEntry(
        id: 'pk-1', profileId: 'p-1', name: 'Dana Darurat', type: 'emergency',
        targetAmount: 10000000, currentAmount: 3000000, colorHex: '#D4F442',
        iconName: 'savings', targetDate: null, linkedWalletId: 'w-bca',
        notes: null, createdAt: refDate, updatedAt: refDate,
        isSynced: false, isDeleted: false,
      ),
    ];

    final categories = [
      CategoryEntry(
        id: 'c-food', name: 'Makanan & Minuman', type: 'expense',
        iconName: 'restaurant', colorHex: '#EF4444',
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
      CategoryEntry(
        id: 'c-salary', name: 'Gaji & Pendapatan', type: 'income',
        iconName: 'work', colorHex: '#10B981',
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
    ];

    final subscriptions = [
      SubscriptionEntry(
        id: 's-1', profileId: 'p-1', walletId: 'w-bca', categoryId: 'c-food',
        title: 'Netflix', cost: 186000, billingCycle: 'monthly', dueDay: 20,
        autoDeduct: true, status: 'active', lastPaidDate: null,
        isInstallment: false, totalCycles: null, paidCycles: 0, deadlineDate: null,
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
    ];

    final transactions = [
      TransactionEntry(
        id: 't-inc-oct', profileId: 'p-1', walletId: 'w-bca', categoryId: 'c-salary',
        amount: 10000000, type: 'income', destinationWalletId: null,
        notes: 'Gaji Oktober', transactionDate: DateTime(2026, 10, 5),
        source: 'manual', externalRef: null,
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
      TransactionEntry(
        id: 't-exp-oct', profileId: 'p-1', walletId: 'w-gopay', categoryId: 'c-food',
        amount: 2500000, type: 'expense', destinationWalletId: null,
        notes: 'Kopi & Makan', transactionDate: DateTime(2026, 10, 10),
        source: 'manual', externalRef: null,
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
      TransactionEntry(
        id: 't-pocket-ignore', profileId: 'p-1', walletId: 'w-bca', categoryId: 'c-food',
        amount: 1000000, type: 'expense', destinationWalletId: null,
        notes: 'Isi kantong', transactionDate: DateTime(2026, 10, 11),
        source: 'manual', externalRef: 'pocket_deposit_pk-1',
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
      TransactionEntry(
        id: 't-exp-sep', profileId: 'p-1', walletId: 'w-bca', categoryId: 'c-food',
        amount: 1500000, type: 'expense', destinationWalletId: null,
        notes: 'Belanja September', transactionDate: DateTime(2026, 9, 18),
        source: 'manual', externalRef: null,
        createdAt: refDate, updatedAt: refDate, isSynced: false, isDeleted: false,
      ),
    ];

    test('calculates thisMonth metrics, net worth, savings rate, and ignores pocket internal transfers', () {
      final report = FinancialReportService.generate(
        wallets: wallets,
        pockets: pockets,
        categories: categories,
        transactions: transactions,
        subscriptions: subscriptions,
        period: ReportPeriod.thisMonth,
        referenceDate: refDate,
      );

      expect(report.totalIncome, 10000000);
      expect(report.totalExpense, 2500000);
      expect(report.netCashflow, 7500000);
      expect(report.savingsRate, closeTo(75.0, 0.01));
      expect(report.totalWalletBalance, 12500000);
      expect(report.totalPocketBalance, 3000000);
      expect(report.totalNetWorth, 15500000);
      expect(report.monthlyCommittedBills, 186000);
      expect(report.expenseByCategory.single.name, 'Makanan & Minuman');
      expect(report.expenseByCategory.single.percentage, closeTo(100.0, 0.01));
    });

    test('filters lastMonth and threeMonths periods accurately', () {
      final lastMonthReport = FinancialReportService.generate(
        wallets: wallets,
        pockets: pockets,
        categories: categories,
        transactions: transactions,
        subscriptions: subscriptions,
        period: ReportPeriod.lastMonth,
        referenceDate: refDate,
      );
      expect(lastMonthReport.totalIncome, 0);
      expect(lastMonthReport.totalExpense, 1500000);

      final threeMonthsReport = FinancialReportService.generate(
        wallets: wallets,
        pockets: pockets,
        categories: categories,
        transactions: transactions,
        subscriptions: subscriptions,
        period: ReportPeriod.threeMonths,
        referenceDate: refDate,
      );
      expect(threeMonthsReport.totalIncome, 10000000);
      expect(threeMonthsReport.totalExpense, 4000000);
    });
  });

  group('ProfileModal Laporan Keuangan Integration Tests', () {
    testWidgets('Tapping Laporan Keuangan in ProfileModal slides inline to FinancialReportTab and switches periods', (tester) async {
      tester.view.physicalSize = const Size(420 * 2, 920 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final wallets = await db.select(db.wallets).get();
      final categories = await db.select(db.categories).get();
      final repo = DriftFinanceRepository(db);

      await repo.addTransaction(
        walletId: wallets.first.id,
        categoryId: categories.first.id,
        amount: 350000,
        type: 'expense',
        notes: 'Makan Siang Tim',
        transactionDate: DateTime.now(),
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(Scaffold).first);
      ProfileModal.show(ctx, walletCount: wallets.length, txCount: 1);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_morphing_menu_trigger')), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile_morphing_menu_trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_financial_report_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile_financial_report_button')));
      await tester.pumpAndSettle();
      expect(find.text('Laporan Keuangan'), findsOneWidget);
      expect(find.text('Total Kekayaan Bersih'), findsOneWidget);
      expect(find.text('POSISI ASET & KEWAJIBAN'), findsOneWidget);
      expect(find.byKey(const Key('category_donut_chart')), findsOneWidget);
      expect(find.text('Arus Kas Bersih'), findsOneWidget);
      expect(find.text('AKTIVITAS PER REKENING'), findsOneWidget);
      await tester.tap(find.byKey(const Key('report_period_threeMonths')));
      await tester.pumpAndSettle();
      expect(find.textContaining('ARUS KAS BERSIH (3 BULAN)'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('report_category_row_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('report_category_row_0')));
      await tester.pumpAndSettle();
      expect(find.text('100.0% Arus Kas'), findsOneWidget);
      await db.close();
    });
  });
}
