import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/screens/subscription_screen.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_stacked_deck.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('SubscriptionDetailScreen Full-Screen Modal & Hero Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);

      final wallets = await repo.getWallets();
      final categories = await repo.getCategories();
      final walletId = wallets.first.id;
      final catId = categories.first.id;

      // Routine recurring subscription
      await repo.addSubscription(
        title: 'Netflix 4K Ultra',
        cost: 186000.0,
        dueDay: 20,
        walletId: walletId,
        categoryId: catId,
        autoDeduct: true,
      );

      // Installment plan
      const uuid = Uuid();
      final now = DateTime.now().toUtc();
      await db.into(db.subscriptions).insert(
        SubscriptionsCompanion(
          id: drift.Value(uuid.v4()),
          title: const drift.Value('iPhone 16 Pro Max Cicilan'),
          cost: const drift.Value(1950000.0),
          dueDay: const drift.Value(10),
          walletId: drift.Value(walletId),
          categoryId: drift.Value(catId),
          autoDeduct: const drift.Value(false),
          isInstallment: const drift.Value(true),
          totalCycles: const drift.Value(12),
          paidCycles: const drift.Value(3),
          deadlineDate: drift.Value(DateTime(2027, 2, 10)),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Renders recurring bill in full-screen modal with Hero card, specs, and actions', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Netflix card
      await tester.tap(find.text('Netflix 4K Ultra'));
      await tester.pumpAndSettle();

      // Verify full-screen modal content
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);
      expect(find.text('Detail Tagihan'), findsOneWidget);
      expect(find.text('Siklus Tagihan'), findsOneWidget);
      expect(find.text('Bulanan'), findsOneWidget);
      expect(find.text('Setiap tanggal 20'), findsOneWidget);
      expect(find.text('Auto-Deduct Aktif'), findsOneWidget);
      expect(find.text('Tandai Sudah Lunas Bulan Ini'), findsOneWidget);

      // Verify no emoji glyphs in text
      expect(find.textContaining('✓'), findsNothing);

      // Verify dismiss button closes modal
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionDetailScreen), findsNothing);
    });

    testWidgets('Renders installment plan with progress bar, debt balance, and cycle counter', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Drag to bring iPhone installment card to focus, then tap
      await tester.drag(find.byType(SubscriptionStackedDeck), const Offset(0, -260));
      await tester.pumpAndSettle();
      await tester.tap(find.text('iPhone 16 Pro Max Cicilan'));
      await tester.pumpAndSettle();

      // Verify installment modal content
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);
      expect(find.text('Detail Cicilan'), findsOneWidget);
      expect(find.text('Rencana Cicilan'), findsOneWidget);
      expect(find.text('3 dari 12 bulan lunas'), findsOneWidget);
      expect(find.text('Progress Pembayaran'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Sisa Tagihan Pokok'), findsOneWidget);
      expect(find.text('Tenggat Selesai'), findsOneWidget);
      expect(find.text('Bayar Cicilan Bulan Ini (4/12)'), findsOneWidget);

      // Verify no emoji glyphs in text
      expect(find.textContaining('✓'), findsNothing);

      // Dismiss
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionDetailScreen), findsNothing);
    });

    testWidgets('Modal header matches other modal headers and selected card design remains consistent', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find selected card in deck before tapping
      // Find Netflix card in deck before tapping
      final deckCardFinder = find.descendant(
        of: find.byType(SubscriptionStackedDeck),
        matching: find.byWidgetPredicate((w) => w is SubscriptionCard && w.subscription.title == 'Netflix 4K Ultra'),
      );
      final deckCardWidget = tester.widget<SubscriptionCard>(deckCardFinder);
      expect(deckCardWidget.subscription.title, 'Netflix 4K Ultra');

      // Tap Netflix card
      await tester.tap(find.text('Netflix 4K Ultra'));
      await tester.pumpAndSettle();

      // Verify ModalHeader matches other modal headers in app
      final modalHeaderFinder = find.byType(ModalHeader);
      expect(modalHeaderFinder, findsOneWidget);
      final modalHeader = tester.widget<ModalHeader>(modalHeaderFinder);
      expect(modalHeader.title, 'Detail Tagihan');
      expect(modalHeader.subtitle, 'Netflix 4K Ultra');
      expect(modalHeader.showCloseButton, isTrue);
      expect(modalHeader.closeIcon, Icons.keyboard_arrow_down_rounded);

      // Verify selected card design in detail view matches the deck card
      final detailHeroCardFinder = find.descendant(
        of: find.byType(SubscriptionDetailHeroCard),
        matching: find.byType(SubscriptionCard),
      );
      expect(detailHeroCardFinder, findsOneWidget);
      final detailCardWidget = tester.widget<SubscriptionCard>(detailHeroCardFinder);
      expect(detailCardWidget.indexOverride, equals(deckCardWidget.indexOverride));
      expect(detailCardWidget.subscription.title, equals(deckCardWidget.subscription.title));
    });

    testWidgets('Tapping Edit Cicilan slides left to edit tab and arrow flips to point left to return', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Drag to bring iPhone installment card to focus, then tap
      await tester.drag(find.byType(SubscriptionStackedDeck), const Offset(0, -260));
      await tester.pumpAndSettle();
      await tester.tap(find.text('iPhone 16 Pro Max Cicilan'));
      await tester.pumpAndSettle();
      // Verify Detail Cicilan view is active
      expect(find.text('Detail Cicilan'), findsOneWidget);
      expect(find.text('Edit Cicilan'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      // Verify only 1 SubscriptionDetailScreen exists (no multiple modals)
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);

      // Tap Edit Cicilan
      await tester.tap(find.text('Edit Cicilan'));
      await tester.pumpAndSettle();

      // View slid left to edit tab without spawning a new modal route
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);
      expect(find.byType(SubscriptionDetailEditTab), findsOneWidget);
      expect(find.text('Edit Cicilan'), findsOneWidget);
      expect(find.text('Rencana cicilan tenor & jatuh tempo'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // Arrow icon has flipped to point left to indicate return to installment details
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

      // Tap the flipped left arrow to return to installment details
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // View slid back to installment details
      expect(find.text('Detail Cicilan'), findsOneWidget);
      expect(find.text('iPhone 16 Pro Max Cicilan'), findsNWidgets(2));
      expect(find.text('Edit Cicilan'), findsOneWidget);

      // Arrow icon has flipped back to point down
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsNothing);

      // Tapping down arrow closes the modal
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionDetailScreen), findsNothing);
    });

    testWidgets('Mark as Paid button morphs to success state and holds before modal dismissal', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Netflix card
      await tester.tap(find.text('Netflix 4K Ultra'));
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);
      expect(find.text('Tandai Sudah Lunas Bulan Ini'), findsOneWidget);

      // Tap Tandai Sudah Lunas Bulan Ini
      await tester.tap(find.text('Tandai Sudah Lunas Bulan Ini'));
      // Pump 100ms: animation has started, morph state is active, modal is NOT closed immediately
      await tester.pump(const Duration(milliseconds: 100));

      // Button has morphed to "Berhasil Dibayar!" with checkmark icon
      expect(find.text('Berhasil Dibayar!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      // Modal is still present (not closed immediately!)
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);

      // Pump 400ms: still within 1000ms delay window, modal is still open
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);

      // Advance fake async clock past 1000ms delay and settle transition
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Modal is now dismissed after the delay
      expect(find.byType(SubscriptionDetailScreen), findsNothing);
    });

    testWidgets('SlideToDeleteButton slides from left to right to trigger confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();
      // Drag to bring iPhone installment card to focus, then tap
      await tester.drag(find.byType(SubscriptionStackedDeck), const Offset(0, -260));
      await tester.pumpAndSettle();
      await tester.tap(find.text('iPhone 16 Pro Max Cicilan'));
      await tester.pumpAndSettle();

      // Tap Edit Cicilan to slide to edit tab
      await tester.tap(find.text('Edit Cicilan'));
      await tester.pumpAndSettle();

      // SlideToDeleteButton is present
      expect(find.byType(SlideToDeleteButton), findsOneWidget);
      expect(find.text('Hapus Cicilan Ini'), findsOneWidget);

      // Slide from left to right
      await tester.drag(find.byType(SlideToDeleteButton), const Offset(320, 0));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Hapus Tagihan?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Tagihan?'), findsNothing);
      expect(find.byType(SubscriptionDetailScreen), findsOneWidget);
    });

    testWidgets('Slide-to-delete in billing details view triggers confirmation dialog and deletes', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Netflix card to open detail view (Tab 0)
      await tester.tap(find.text('Netflix 4K Ultra'));
      await tester.pumpAndSettle();

      // SlideToDeleteButton is present in billing details
      expect(find.byType(SlideToDeleteButton), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Slide from left to right to trigger delete
      await tester.drag(find.byType(SlideToDeleteButton), const Offset(320, 0));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Hapus Tagihan?'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Detail modal closes and Netflix is deleted
      expect(find.byType(SubscriptionDetailScreen), findsNothing);
      expect(find.text('Netflix 4K Ultra'), findsNothing);
    });
  });
}
