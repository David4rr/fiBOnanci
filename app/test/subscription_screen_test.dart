import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/screens/subscription_screen.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('SubscriptionScreen & SubscriptionCard Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);

      // Add sample subscriptions
      final wallets = await repo.getWallets();
      final categories = await repo.getCategories();
      final walletId = wallets.first.id;
      final catId = categories.first.id;

      await repo.addSubscription(
        title: 'Spotify Family',
        cost: 86900.0,
        dueDay: 15,
        walletId: walletId,
        categoryId: catId,
        autoDeduct: true,
      );

      await repo.addSubscription(
        title: 'Netflix Premium 4K',
        cost: 186000.0,
        dueDay: 28,
        walletId: walletId,
        categoryId: catId,
        autoDeduct: false,
      );
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Renders SubscriptionScreen with summary banner and SubscriptionCard widgets', (tester) async {
      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: SubscriptionScreen(db: db),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title & subscriptions
      expect(find.text('Tagihan & Langganan'), findsOneWidget);
      expect(find.text('Spotify Family'), findsOneWidget);
      expect(find.text('Netflix Premium 4K'), findsOneWidget);
      expect(find.byType(SubscriptionCard), findsNWidgets(2));
    });

    testWidgets('Tapping card opens detail modal and marks subscription as paid', (tester) async {
      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: SubscriptionScreen(db: db),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Spotify card to open detail modal
      await tester.tap(find.text('Spotify Family'));
      await tester.pumpAndSettle();

      // Verify modal content & action buttons
      expect(find.text('Rekening Pembayaran'), findsOneWidget);
      expect(find.text('Metode Pembayaran'), findsOneWidget);
      expect(find.text('Tandai Sudah Lunas Bulan Ini'), findsOneWidget);
      expect(find.text('Edit Tagihan'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tap Tandai Sudah Lunas Bulan Ini
      await tester.tap(find.text('Tandai Sudah Lunas Bulan Ini'));
      await tester.pumpAndSettle();

      // Spotify Family is now paid
      expect(find.text('LUNAS BULAN INI'), findsOneWidget);
    });

    testWidgets('Tapping Edit Tagihan opens edit modal and updates subscription', (tester) async {
      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: SubscriptionScreen(db: db),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Spotify card
      await tester.tap(find.text('Spotify Family'));
      await tester.pumpAndSettle();

      // Tap Edit Tagihan
      await tester.tap(find.text('Edit Tagihan'));
      await tester.pumpAndSettle();

      // Verify Edit form is shown
      expect(find.text('Edit Tagihan Rutin'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Hapus Langganan Ini'), findsOneWidget);

      // Edit name
      await tester.enterText(find.widgetWithText(TextField, 'Spotify Family'), 'Spotify Duo Platinum');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify updated title in card deck
      expect(find.text('Spotify Duo Platinum'), findsOneWidget);
    });

    testWidgets('Tapping Hapus removes subscription from list', (tester) async {
      final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: SubscriptionScreen(db: db),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Spotify card
      await tester.tap(find.text('Spotify Family'));
      await tester.pumpAndSettle();

      // Tap Hapus button
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Hapus Tagihan?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Verify Spotify is removed
      expect(find.text('Spotify Family'), findsNothing);
      expect(find.text('Netflix Premium 4K'), findsOneWidget);
    });
  });
}
