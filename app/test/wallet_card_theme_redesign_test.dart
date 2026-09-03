import 'dart:ui';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/widgets/modernist_card_painter.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card_deck.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Card Interface Redesign & Dynamic Theme Uniqueness Tests', () {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    test('ModernistCardTheme includes 8 base themes and 12 expanded curated themes (20 total)', () {
      expect(ModernistCardTheme.values.length, 20);

      // Verify all 8 base themes are preserved
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.streamingCinematic));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.audioEmerald));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.utilitiesLemon));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.fiberInternet));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.aiCloudProductivity));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.housingLiving));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.fitnessLifestyle));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.recurringSmartBill));

      // Verify 12 new curated themes
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.tokyoMidnight));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.solarAmber));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.arcticGlacier));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.cyberNeon));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.matchaZen));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.terracottaSunset));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.monochromeStark));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.lavenderDusk));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.cobaltVault));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.blushPop));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.nordicPine));
      expect(ModernistCardTheme.values, contains(ModernistCardTheme.copperPatina));
    });

    test('Dynamic theme randomization guarantees NO TWO CARDS SHARE THE SAME THEME in a wallet deck', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);

      // Fetch the 7 default seeded wallets (BCA, blu, SeaBank, Mandiri, Jago, OVO, ShopeePay)
      final seededWallets = await repo.getWallets();
      expect(seededWallets.length, 7);

      final assignedThemes = <ModernistCardTheme>{};
      for (int i = 0; i < seededWallets.length; i++) {
        final wallet = seededWallets[i];
        final theme = resolveWalletTheme(wallet, i, allWallets: seededWallets);

        // Verify each card theme is unique (no collisions)
        expect(assignedThemes.contains(theme), isFalse,
            reason: 'Card $i (${wallet.name}) received duplicate theme: $theme');
        assignedThemes.add(theme);
      }

      // 7 seeded wallets must have exactly 7 distinct themes
      expect(assignedThemes.length, 7);

      // Verify scaling with 15 unique wallets
      final extendedWallets = List.generate(
        15,
        (i) => WalletEntry(
          id: 'test-wallet-$i',
          name: 'Account $i',
          type: i % 2 == 0 ? 'bank' : 'ewallet',
          currency: 'IDR',
          balance: 100000.0 * (i + 1),
          colorHex: '#000000',
          iconName: 'wallet',
          accountNumber: 'ACC-$i',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          isSynced: false,
          isDeleted: false,
        ),
      );

      final extendedThemes = <ModernistCardTheme>{};
      for (int i = 0; i < extendedWallets.length; i++) {
        final theme = resolveWalletTheme(extendedWallets[i], i, allWallets: extendedWallets);
        expect(extendedThemes.contains(theme), isFalse,
            reason: 'Card $i received duplicate theme: $theme');
        extendedThemes.add(theme);
      }
      expect(extendedThemes.length, 15);

      await db.close();
    });

    test('ModernistCardPainter executes without exception for all 20 themes', () {
      for (final theme in ModernistCardTheme.values) {
        final config = ModernistCardConfig.forTheme(theme);
        final painter = ModernistCardPainter(
          theme: theme,
          primaryColor: config.primaryGraphicColor,
          secondaryColor: config.secondaryGraphicColor,
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        const size = Size(360, 220);

        expect(() => painter.paint(canvas, size), returnsNormally);
        recorder.endRecording().dispose();
      }
    });

    testWidgets('WalletCard renders elevated tactile chip, specular sheen, and dynamic themes', (tester) async {
      final now = DateTime.now().toUtc();
      final wallet1 = WalletEntry(
        id: 'w1',
        name: 'Bank Jago High-Tech',
        type: 'bank',
        currency: 'IDR',
        balance: 4500000.0,
        colorHex: '#FF7300',
        iconName: 'sparkles',
        accountNumber: '5410-9823-4100',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final wallet2 = WalletEntry(
        id: 'w2',
        name: 'blu by BCA Digital',
        type: 'bank',
        currency: 'IDR',
        balance: 2300000.0,
        colorHex: '#00A4E4',
        iconName: 'credit_card',
        accountNumber: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final allWallets = [wallet1, wallet2];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WalletCard(
                  wallet: wallet1,
                  index: 0,
                  allWallets: allWallets,
                  fmt: fmt,
                  cardH: 220,
                  showBottomLayout: true,
                ),
                WalletCard(
                  wallet: wallet2,
                  index: 1,
                  allWallets: allWallets,
                  fmt: fmt,
                  cardH: 220,
                  showBottomLayout: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Bank Jago High-Tech'), findsOneWidget);
      expect(find.text('blu by BCA Digital'), findsOneWidget);
      expect(find.text('5410-9823-4100'), findsOneWidget);
      expect(find.text('-'), findsOneWidget); // wallet2 has null account number -> defaults to '-'
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify theme 0 and theme 1 are strictly distinct
      final theme1 = resolveWalletTheme(wallet1, 0, allWallets: allWallets);
      final theme2 = resolveWalletTheme(wallet2, 1, allWallets: allWallets);
      expect(theme1, isNot(equals(theme2)));
    });

    testWidgets('Stacked WalletCard (showBottomLayout: false) renders balance in peek header, and transitions smoothly on expand', (tester) async {
      final now = DateTime.now().toUtc();
      final wallet = WalletEntry(
        id: 'w_stacked',
        name: 'Mandiri Prioritas',
        type: 'bank',
        currency: 'IDR',
        balance: 18500000.0,
        colorHex: '#F59E0B',
        iconName: 'wallet',
        accountNumber: '1234-5678-9000',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      // 1. Stacked state: showBottomLayout = false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              index: 0,
              fmt: fmt,
              cardH: 220,
              showBottomLayout: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Static header is present
      expect(find.text('Mandiri Prioritas'), findsOneWidget);
      expect(find.text('BANK'), findsOneWidget);

      // Stacked peek row shows SALDO TERSEDIA and formatted balance!
      expect(find.text('SALDO TERSEDIA'), findsOneWidget);
      expect(find.text('Rp 18.500.000'), findsOneWidget);

      // Full expanded ATM elements (lowercase 'Saldo Tersedia' and account number) are NOT present
      expect(find.text('Saldo Tersedia'), findsNothing);
      expect(find.text('1234-5678-9000'), findsNothing);

      // 2. Transition to expanded state: showBottomLayout = true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              index: 0,
              fmt: fmt,
              cardH: 220,
              showBottomLayout: true,
            ),
          ),
        ),
      );
      // Mid-animation frame
      expect(find.text('BANK'), findsOneWidget);
      // Static header remains rock-solid
      expect(find.text('Mandiri Prioritas'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();

      expect(find.text('BANK'), findsOneWidget);
      expect(find.text('Mandiri Prioritas'), findsOneWidget);

      // Expanded ATM layout is now visible with large balance and account number
      expect(find.text('Saldo Tersedia'), findsOneWidget);
      expect(find.text('Rp 18.500.000'), findsOneWidget);
      expect(find.text('1234-5678-9000'), findsOneWidget);
      // Stacked peek row is gone
      expect(find.text('SALDO TERSEDIA'), findsNothing);
    });

    testWidgets('Single unstacked card (e.g. Cash Card at top) renders full layout with animate: false, and taps directly to select', (tester) async {
      final now = DateTime.now().toUtc();
      final cashWallet = WalletEntry(
        id: 'w_cash',
        name: 'Kas Tunai Dompet',
        type: 'cash',
        currency: 'IDR',
        balance: 250000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
        accountNumber: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      WalletEntry? selectedWallet;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCardDeck(
              wallets: [cashWallet],
              fmt: fmt,
              onSelectWallet: (w) => selectedWallet = w,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cash card at top: fully expanded, shows badge KAS TUNAI
      expect(find.text('Kas Tunai Dompet'), findsOneWidget);
      expect(find.text('KAS TUNAI'), findsOneWidget);
      expect(find.text('Saldo Tersedia'), findsOneWidget);
      expect(find.text('Rp 250.000'), findsOneWidget);

      // Does NOT show uppercase stacked peek header
      expect(find.text('SALDO TERSEDIA'), findsNothing);

      // Does NOT render AnimatedSwitcher inside the card body because animate: false
      final cardWidget = tester.widget<WalletCard>(find.byType(WalletCard));
      expect(cardWidget.animate, isFalse);
      expect(cardWidget.showBottomLayout, isTrue);

      // Single tap directly selects wallet without needing an expand animation!
      await tester.tap(find.text('Kas Tunai Dompet'));
      await tester.pumpAndSettle();
      expect(selectedWallet?.id, 'w_cash');
    });

    testWidgets('Multi-card deck: stacked top card has animate: true, bottom unstacked card has animate: false & showBottomLayout: true', (tester) async {
      final now = DateTime.now().toUtc();
      final topWallet = WalletEntry(
        id: 'w_top',
        name: 'BCA Utama',
        type: 'bank',
        currency: 'IDR',
        balance: 5000000.0,
        colorHex: '#0060AF',
        iconName: 'wallet',
        accountNumber: '1122334455',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );
      final bottomWallet = WalletEntry(
        id: 'w_bottom_cash',
        name: 'Kas Tunai Dompet',
        type: 'cash',
        currency: 'IDR',
        balance: 250000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
        accountNumber: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      WalletEntry? selectedWallet;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCardDeck(
              wallets: [topWallet, bottomWallet],
              fmt: fmt,
              onSelectWallet: (w) => selectedWallet = w,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cards = tester.widgetList<WalletCard>(find.byType(WalletCard)).toList();
      expect(cards.length, 2);

      // Card 0 (top, stacked under bottom card): has animation active for smooth text transition, collapsed at rest
      expect(cards[0].animate, isTrue);
      expect(cards[0].showBottomLayout, isFalse);

      // Card 1 (bottom card, not stacked under anything): no animation, renders full layout directly
      expect(cards[1].animate, isFalse);
      expect(cards[1].showBottomLayout, isTrue);

      // Tapping bottom unstacked card directly invokes onSelectWallet
      await tester.tap(find.text('Kas Tunai Dompet'));
      await tester.pumpAndSettle();
      expect(selectedWallet?.id, 'w_bottom_cash');

      // Tapping top card expands it with smooth animation
      await tester.tap(find.text('BCA Utama'));
      await tester.pumpAndSettle();
      final expandedCards = tester.widgetList<WalletCard>(find.byType(WalletCard)).toList();
      expect(expandedCards[0].showBottomLayout, isTrue);
      expect(expandedCards[0].animate, isTrue);
    });

    testWidgets('Expanded stacked card auto-closes after 6s of inactivity', (tester) async {
      final now = DateTime.now().toUtc();
      final topWallet = WalletEntry(
        id: 'w_top',
        name: 'BCA Utama',
        type: 'bank',
        currency: 'IDR',
        balance: 5000000.0,
        colorHex: '#0060AF',
        iconName: 'wallet',
        accountNumber: '1122334455',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );
      final bottomWallet = WalletEntry(
        id: 'w_bottom_cash',
        name: 'Kas Tunai Dompet',
        type: 'cash',
        currency: 'IDR',
        balance: 250000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
        accountNumber: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCardDeck(
              wallets: [topWallet, bottomWallet],
              fmt: fmt,
              onSelectWallet: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap top card to expand it
      await tester.tap(find.text('BCA Utama'));
      await tester.pumpAndSettle();
      var cards = tester.widgetList<WalletCard>(find.byType(WalletCard)).toList();
      expect(cards[0].showBottomLayout, isTrue);

      // Advance clock by 4s -> still expanded (< 6s)
      await tester.pump(const Duration(seconds: 4));
      cards = tester.widgetList<WalletCard>(find.byType(WalletCard)).toList();
      expect(cards[0].showBottomLayout, isTrue);

      // Advance clock past 6s total -> auto-collapses
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      cards = tester.widgetList<WalletCard>(find.byType(WalletCard)).toList();
      expect(cards[0].showBottomLayout, isFalse);
    });
  });
}
