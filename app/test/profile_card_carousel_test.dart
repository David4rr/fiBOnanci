import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/profile_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('ProfileCardCarousel Swipe & Switch Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Swiping carousel card left/right switches active profile and updates workspace', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Add second profile
      await repo.addProfile(
        username: 'bisnis_pt',
        fullName: 'PT Maju Bersama',
        email: 'bisnis@fibonanci.app',
      );

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => ProfileModal.show(context, walletCount: 7, txCount: 52),
                  child: const Text('Open Profile'),
                ),
              ),
            ),
          ),
        ),
      );
      // Open profile modal
      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();

      // Verify ProfileCardCarousel is rendered with 2 profiles
      expect(find.byType(ProfileCardCarousel), findsOneWidget);
      // Verify active card shows David
      expect(find.text('David Arrozaqi'), findsOneWidget);

      // Swipe carousel left to switch to PT Maju Bersama
      final pageViewFinder = find.descendant(
        of: find.byType(ProfileCardCarousel),
        matching: find.byType(PageView),
      );
      await tester.drag(pageViewFinder, const Offset(-350, 0));
      await tester.pumpAndSettle();

      expect(find.text('PT Maju Bersama'), findsOneWidget);
      expect(bloc.state.profile.username, 'bisnis_pt');

      // Swipe back right to switch back to David
      await tester.drag(pageViewFinder, const Offset(350, 0));
      await tester.pumpAndSettle();
      expect(find.text('David Arrozaqi'), findsOneWidget);
      expect(bloc.state.profile.username, 'David');
    });

    testWidgets('Tapping dot indicator animates carousel to target profile', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repo.addProfile(
        username: 'second_user',
        fullName: 'Second User',
        email: 'second@fibonanci.app',
      );

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => ProfileModal.show(context, walletCount: 7, txCount: 52),
                  child: const Text('Open Profile'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileCardCarousel), findsOneWidget);

      // Tap the second dot indicator inside ProfileCardCarousel using ValueKey
      final secondDotFinder = find.byKey(const ValueKey('profile_carousel_dot_1'));
      expect(secondDotFinder, findsOneWidget);
      await tester.tap(secondDotFinder);
      await tester.pumpAndSettle();

      expect(find.text('Second User'), findsOneWidget);
      expect(bloc.state.profile.username, 'second_user');
    });
  });
}
