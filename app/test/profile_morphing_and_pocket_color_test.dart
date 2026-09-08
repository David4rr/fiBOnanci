import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/profile_modal.dart';
import 'package:fibonanci_app/presentation/screens/wallet/wallet_pockets_view.dart';
import 'package:fibonanci_app/presentation/widgets/bento_folder_card.dart';
import 'package:fibonanci_app/presentation/widgets/pocket_card_theme.dart';

void main() {
  group('Pocket Color & Profile Modal Morphing Tests', () {
    test('Pocket card theme configuration does not define or use a gradient', () {
      final now = DateTime.now();
      final pocket = PocketEntry(
        id: 'pocket-1',
        name: 'Dana Darurat',
        type: 'emergency',
        currentAmount: 5000000.0,
        targetAmount: 20000000.0,
        colorHex: '#7DF24E',
        iconName: 'shield',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final config = PocketCardThemeConfig.resolve(pocket, 0);
      expect(config.backgroundColor, isA<Color>());
      expect(config.backgroundColor.a, equals(1.0));
    });

    testWidgets('WalletPocketsView renders BentoFolderCard without gradient (solid color only)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final now = DateTime.now();
      final pockets = [
        PocketEntry(
          id: 'p-1',
          name: 'Dana Darurat',
          type: 'emergency',
          currentAmount: 2500000.0,
          targetAmount: 10000000.0,
          colorHex: '#7DF24E',
          iconName: 'shield',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                WalletPocketsView(
                  pockets: pockets,
                  totalPocketsAmount: 2500000.0,
                  transactions: const [],
                  currencyFormatter: currencyFormatter,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bentoCardFinder = find.byType(BentoFolderCard);
      expect(bentoCardFinder, findsOneWidget);

      final bentoCard = tester.widget<BentoFolderCard>(bentoCardFinder);
      expect(bentoCard.gradient, isNull);
      expect(bentoCard.backgroundColor, isNotNull);
    });

    testWidgets('ProfileModal uses morphing for 3-dot menu and inline edit without secondary modals', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.profiles.isNotEmpty)),
      );

      addTearDown(bloc.close);
      addTearDown(db.close);

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ProfileModal.show(context, walletCount: 2, txCount: 5),
                  child: const Text('Open Profile'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open ProfileModal
      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileModal), findsOneWidget);
      expect(find.text('Profil Pengguna'), findsOneWidget);

      // Verify 3-dot button is present
      final dotsFinder = find.byType(ProfileMorphingMenu);
      expect(dotsFinder, findsOneWidget);

      // Tap 3-dot menu
      await tester.tap(dotsFinder);
      await tester.pumpAndSettle();

      // Verify morphing menu opened via OverlayPortal (NOT ModalBottomSheetRoute)
      expect(find.byType(ModalBottomSheetRoute), findsNothing);
      expect(find.text('Menu Profil'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('New Profile'), findsOneWidget);
      expect(find.text('Health Finance Details'), findsOneWidget);
      expect(find.text('Share Profile'), findsOneWidget);

      // Tap 'Edit Profile' from the morphing menu
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Verify NO secondary modal route was pushed
      expect(find.byType(ModalBottomSheetRoute), findsNothing);

      // Verify inline transition to Edit Profile tab
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.byType(ProfileEditTab), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'), findsOneWidget);

      // Verify back chevron in ModalHeader
      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);

      // Tap back chevron in header to return to summary view inline
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      // Verify back on Profile summary view
      expect(find.text('Profil Pengguna'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });
  });
}
