import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_card.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_due_day_slider.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_installment_selector.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_stacked_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('Installment Deadline & SafeToSpend Lifecycle Tests', () {
    final refDate = DateTime(2026, 9, 6);

    test('calculateDeadlineDate computes correct end month and year', () {
      // If current day (6) <= dueDay (15), first month is September 2026.
      // 3-month plan: Sep, Oct, Nov 2026.
      final d1 = SubscriptionInstallmentSelector.calculateDeadlineDate(
        dueDay: 15,
        totalCycles: 3,
        referenceDate: refDate,
      );
      expect(d1.year, 2026);
      expect(d1.month, 11);
      expect(d1.day, 15);

      // If current day (6) > dueDay (5), first month is October 2026.
      // 6-month plan: Oct 2026 to Mar 2027.
      final d2 = SubscriptionInstallmentSelector.calculateDeadlineDate(
        dueDay: 5,
        totalCycles: 6,
        referenceDate: refDate,
      );
      expect(d2.year, 2027);
      expect(d2.month, 3);
      expect(d2.day, 5);
    });

    test('SafeToSpendService deducts active installment but skips completed or expired plans', () {
      final wallets = [
        WalletEntry(
          id: 'w1',
          name: 'BCA',
          type: 'bank',
          currency: 'IDR',
          balance: 5000000,
          colorHex: '#0060AF',
          iconName: 'landmark',
          createdAt: refDate,
          updatedAt: refDate,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final activeInstallment = SubscriptionEntry(
        id: 'sub_active',
        walletId: 'w1',
        categoryId: 'c1',
        title: 'Cicilan HP 3 Bulan',
        cost: 1000000,
        billingCycle: 'monthly',
        dueDay: 20,
        autoDeduct: false,
        status: 'active',
        lastPaidDate: null,
        isInstallment: true,
        totalCycles: 3,
        paidCycles: 1, // 1 of 3 paid
        deadlineDate: DateTime(2026, 11, 20),
        createdAt: refDate,
        updatedAt: refDate,
        isSynced: false,
        isDeleted: false,
      );

      final completedInstallment = SubscriptionEntry(
        id: 'sub_completed',
        walletId: 'w1',
        categoryId: 'c1',
        title: 'Cicilan Laptop Lunas',
        cost: 2000000,
        billingCycle: 'monthly',
        dueDay: 10,
        autoDeduct: false,
        status: 'completed',
        lastPaidDate: DateTime(2026, 8, 10),
        isInstallment: true,
        totalCycles: 3,
        paidCycles: 3,
        deadlineDate: DateTime(2026, 8, 10),
        createdAt: refDate,
        updatedAt: refDate,
        isSynced: false,
        isDeleted: false,
      );

      final metrics = SafeToSpendService.calculate(
        wallets: wallets,
        subscriptions: [activeInstallment, completedInstallment],
        referenceDate: refDate,
      );

      // Only the active installment (1,000,000) should be pending
      expect(metrics.pendingBills, 1000000.0);
      expect(metrics.safeToSpendMonthly, 4000000.0);
    });

    test('markSubscriptionAsPaid increments paidCycles and auto-completes plan at final cycle', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final wallet = await (db.select(db.wallets)..limit(1)).getSingle();
      final category = await (db.select(db.categories)..limit(1)).getSingle();

      const subId = 'installment_test_1';
      await db.into(db.subscriptions).insert(
        SubscriptionsCompanion(
          id: const drift.Value(subId),
          walletId: drift.Value(wallet.id),
          categoryId: drift.Value(category.id),
          title: const drift.Value('Pinjaman Online 2x'),
          cost: const drift.Value(500000),
          billingCycle: const drift.Value('monthly'),
          dueDay: const drift.Value(15),
          autoDeduct: const drift.Value(false),
          status: const drift.Value('active'),
          isInstallment: const drift.Value(true),
          totalCycles: const drift.Value(2),
          paidCycles: const drift.Value(0),
          deadlineDate: drift.Value(DateTime(2026, 10, 15)),
          createdAt: drift.Value(refDate),
          updatedAt: drift.Value(refDate),
        ),
      );

      // 1st payment
      await db.markSubscriptionAsPaid(subId);
      var sub = await (db.select(db.subscriptions)..where((t) => t.id.equals(subId))).getSingle();
      expect(sub.paidCycles, 1);
      expect(sub.status, 'active');

      // 2nd and final payment
      await db.markSubscriptionAsPaid(subId);
      sub = await (db.select(db.subscriptions)..where((t) => t.id.equals(subId))).getSingle();
      expect(sub.paidCycles, 2);
      expect(sub.status, 'completed');
    });
  });

  group('UI Redesign & Bottom Counter Removal Tests', () {
    testWidgets('SubscriptionDueDaySlider renders bespoke milestones and responds to interaction', (tester) async {
      int selectedDay = 15;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SubscriptionDueDaySlider(
                  dueDay: selectedDay,
                  onDayChanged: (d) => setState(() => selectedDay = d),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('TANGGAL JATUH TEMPO'), findsOneWidget);
      expect(find.text('Tgl 15 setiap bulan'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);

      // Tap on milestone 5
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(selectedDay, 5);
      expect(find.text('Tgl 5 setiap bulan'), findsOneWidget);
    });

    testWidgets('SubscriptionStackedDeck does NOT render bottom counter badge (clean floating stack)', (tester) async {
      final now = DateTime.now();
      final mockWallets = [
        WalletEntry(
          id: 'w1',
          name: 'BCA',
          type: 'bank',
          currency: 'IDR',
          balance: 5000000,
          colorHex: '#0060AF',
          iconName: 'landmark',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];
      final mockSubs = [
        SubscriptionEntry(
          id: 's1',
          walletId: 'w1',
          categoryId: 'c1',
          title: 'Netflix',
          cost: 186000,
          billingCycle: 'monthly',
          dueDay: 15,
          autoDeduct: true,
          status: 'active',
          lastPaidDate: null,
          isInstallment: false,
          paidCycles: 0,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
        SubscriptionEntry(
          id: 's2',
          walletId: 'w1',
          categoryId: 'c1',
          title: 'Spotify',
          cost: 55000,
          billingCycle: 'monthly',
          dueDay: 20,
          autoDeduct: false,
          status: 'active',
          lastPaidDate: null,
          isInstallment: false,
          paidCycles: 0,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionStackedDeck(
              subscriptions: mockSubs,
              wallets: mockWallets,
              onTapCard: (_, _) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure the old counter text '1 / 2' does not exist in the widget tree
      expect(find.text('1 / 2'), findsNothing);
      expect(find.text('Netflix'), findsOneWidget);
    });

    testWidgets('SubscriptionCardBadges renders installment progress badge', (tester) async {
      const theme = ModernistCardTheme.streamingCinematic;
      final config = SubscriptionCardThemeConfig.forTheme(theme);

      // In progress
      final activeBadge = SubscriptionCardBadges.buildStatusBadge(
        false,
        15,
        config,
        isInstallment: true,
        totalCycles: 3,
        paidCycles: 0,
        isCompleted: false,
      );

      // Completed
      final completedBadge = SubscriptionCardBadges.buildStatusBadge(
        true,
        15,
        config,
        isInstallment: true,
        totalCycles: 3,
        paidCycles: 3,
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                activeBadge,
                completedBadge,
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('CICILAN 1/3'), findsOneWidget);
      expect(find.textContaining('CICILAN LUNAS (3/3)'), findsOneWidget);
    });

    testWidgets('SubscriptionInstallmentSelector supports custom cicilan tenor and steppers', (tester) async {
      bool isInstallment = true;
      int totalCycles = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SubscriptionInstallmentSelector(
                  isInstallment: isInstallment,
                  totalCycles: totalCycles,
                  dueDay: 15,
                  onToggleInstallment: (v) => setState(() => isInstallment = v),
                  onCyclesChanged: (c) => setState(() => totalCycles = c),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3x'), findsOneWidget);
      expect(find.text('6x'), findsOneWidget);
      expect(find.text('12x'), findsOneWidget);
      expect(find.text('24x'), findsNothing);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Durasi Tenor'), findsNothing);

      // Tap Custom
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('Durasi Tenor'), findsOneWidget);
      expect(find.text('Bln'), findsOneWidget);

      // Tap '+' stepper
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(totalCycles, 4);

      // Tap '-' stepper
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
      expect(totalCycles, 3);

      // Direct type into text field
      await tester.enterText(find.byType(TextField), '10');
      await tester.pumpAndSettle();
      expect(totalCycles, 10);

      // Tap preset 6x
      await tester.tap(find.text('6x'));
      await tester.pumpAndSettle();
      expect(totalCycles, 6);
      expect(find.text('Durasi Tenor'), findsNothing);
    });
  });
}
