import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/screens/wallet/wallet_pockets_view.dart';
import 'package:fibonanci_app/presentation/widgets/pocket_card_theme.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Dynamic Card Theming & UI Modernization Tests', () {
    test('Installment & Subscription dynamic theming handles dozens of cards with unique colors', () {
      final now = DateTime.now();
      final subs = List.generate(
        40,
        (i) => SubscriptionEntry(
          id: 'sub-$i',
          walletId: 'w-1',
          categoryId: 'c-1',
          title: 'Cicilan Laptop $i',
          cost: 1500000.0,
          dueDay: 15,
          autoDeduct: false,
          billingCycle: 'monthly',
          status: 'active',
          isInstallment: true,
          totalCycles: 12,
          paidCycles: i % 12,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      );

      final assignedColors = <Color>{};
      for (int i = 0; i < subs.length; i++) {
        final config = SubscriptionCardResolver.resolveConfig(
          subscription: subs[i],
          index: i,
          allSubscriptions: subs,
        );

        // Verify no duplicate background colors across consecutive cards
        if (i > 0) {
          final prevConfig = SubscriptionCardResolver.resolveConfig(
            subscription: subs[i - 1],
            index: i - 1,
            allSubscriptions: subs,
          );
          expect(config.backgroundColor, isNot(equals(prevConfig.backgroundColor)));
        }
        assignedColors.add(config.backgroundColor);

        // Verify STREAMING category badge is completely eliminated
        expect(config.networkBadgeText, isNot(equals('STREAMING')));
      }

      // 40 cards must produce at least 20+ distinct visual colorways
      expect(assignedColors.length, greaterThanOrEqualTo(20));
    });

    test('Savings (Kantong Tabungan) dynamic theming handles dozens of cards with unique colors', () {
      final now = DateTime.now();
      final pockets = List.generate(
        35,
        (i) => PocketEntry(
          id: 'pocket-$i',
          name: 'Kantong $i',
          type: 'savings',
          currentAmount: 1000000.0 * (i + 1),
          targetAmount: 50000000.0,
          colorHex: '#D4F442',
          iconName: 'savings',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      );

      final assignedBgColors = <Color>{};
      for (int i = 0; i < pockets.length; i++) {
        final config = PocketCardThemeConfig.resolve(
          pockets[i],
          i,
          allPockets: pockets,
        );

        // Consecutive cards never have the exact same color
        if (i > 0) {
          final prevConfig = PocketCardThemeConfig.resolve(
            pockets[i - 1],
            i - 1,
            allPockets: pockets,
          );
          expect(config.backgroundColor, isNot(equals(prevConfig.backgroundColor)));
        }
        assignedBgColors.add(config.backgroundColor);
      }

      // 35 pockets must produce at least 20+ distinct visual colorways
      expect(assignedBgColors.length, greaterThanOrEqualTo(20));
    });

    testWidgets('InstallmentCardLayout moves status to category area, drops progress bar & account number', (tester) async {
      final now = DateTime.now();
      final sub = SubscriptionEntry(
        id: 'sub-test',
        walletId: 'w-1',
        categoryId: 'c-1',
        autoDeduct: false,
        title: 'Cicilan MacBook M3 Pro',
        cost: 2500000.0,
        dueDay: 20,
        billingCycle: 'monthly',
        status: 'active',
        isInstallment: true,
        totalCycles: 12,
        paidCycles: 4,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final wallet = WalletEntry(
        id: 'w-1',
        name: 'BCA Prioritas',
        type: 'bank',
        currency: 'IDR',
        balance: 50000000.0,
        colorHex: '#000000',
        iconName: 'wallet',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      const config = SubscriptionCardThemeConfig(
        backgroundColor: Color(0xFF18181B),
        primaryGraphicColor: Color(0xFFFAFAFA),
        secondaryGraphicColor: Color(0xFF71717A),
        textColor: Color(0xFFFAFAFA),
        badgeColor: Color(0xFFFAFAFA),
        networkBadgeText: 'BCA PRIORITAS',
        badgeType: CardBadgeType.chip,
      );

      final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallmentCardLayout(
              subscription: sub,
              wallet: wallet,
              config: config,
              currencyFormatter: fmt,
              isPaidThisMonth: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title is on top-left and status badge is on top-right
      expect(find.text('Cicilan MacBook M3 Pro'), findsOneWidget);
      expect(find.textContaining('CICILAN 5/12'), findsOneWidget);
      expect(find.text('CICILAN TENOR'), findsNothing);
      // Verify NO middle sisa container and NO progress bar (LinearProgressIndicator) is rendered
      expect(find.textContaining('Sisa'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // Verify NO account number (maskedNumber pattern) is rendered
      expect(find.textContaining('......'), findsNothing);
    });
    testWidgets('BillingCardLayout uses same layout: title on top-left, status on top-right, no middle container', (tester) async {
      final now = DateTime.now();
      final sub = SubscriptionEntry(
        id: 'sub-bill-1',
        walletId: 'w-1',
        categoryId: 'c-1',
        title: 'Netflix Premium 4K',
        cost: 186000.0,
        dueDay: 20,
        autoDeduct: true,
        status: 'active',
        billingCycle: 'monthly',
        isInstallment: false,
        paidCycles: 0,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final wallet = WalletEntry(
        id: 'w-1',
        name: 'BCA Prioritas',
        type: 'bank',
        currency: 'IDR',
        iconName: 'wallet',
        balance: 25000000.0,
        colorHex: '#00529B',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      const config = SubscriptionCardThemeConfig(
        backgroundColor: Color(0xFF18181B),
        primaryGraphicColor: Color(0xFFFAFAFA),
        secondaryGraphicColor: Color(0xFF71717A),
        textColor: Color(0xFFFAFAFA),
        badgeColor: Color(0xFFFAFAFA),
        networkBadgeText: 'PREMIUM',
        badgeType: CardBadgeType.chip,
      );

      final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillingCardLayout(
              subscription: sub,
              wallet: wallet,
              config: config,
              currencyFormatter: fmt,
              isPaidThisMonth: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title is on top-left and status badge is on top-right
      expect(find.text('Netflix Premium 4K'), findsOneWidget);
      expect(find.textContaining('JATUH TEMPO'), findsOneWidget);

      // Verify NO middle container icon or text
      expect(find.byIcon(Icons.event_repeat_rounded), findsNothing);

      // Verify recurring label and amount on bottom
      expect(find.text('tagihan rutin /bulan'), findsOneWidget);
      expect(find.text('Rp 186.000'), findsOneWidget);
    });


    testWidgets('WalletPocketsView drops progress bar from savings pocket cards', (tester) async {
      final now = DateTime.now();
      final pockets = [
        PocketEntry(
          id: 'p-1',
          name: 'Dana Darurat',
          type: 'emergency',
          currentAmount: 15000000.0,
          targetAmount: 50000000.0,
          colorHex: '#7DF24E',
          iconName: 'shield',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                WalletPocketsView(
                  pockets: pockets,
                  totalPocketsAmount: 15000000.0,
                  transactions: const [],
                  currencyFormatter: fmt,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dana Darurat'), findsOneWidget);
      expect(find.text('Target Rp 50.000.000'), findsOneWidget);

      // Verify progress bar is dropped
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('30%'), findsNothing);
    });
  });
}
