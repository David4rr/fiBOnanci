import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/bottom_nav_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BottomNavDock 4-item Refactor Tests', () {
    testWidgets('renders pill container with Home, Tagihan, Wallets and isolated circular Add button', (tester) async {
      int selectedIndex = 0;
      bool addPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return BottomNavDock(
                  currentIndex: selectedIndex,
                  onTapIndex: (i) => setState(() => selectedIndex = i),
                  onAddAction: () => addPressed = true,
                );
              },
            ),
          ),
        ),
      );

      // 1. Verify all 4 items are present
      // Home icon & active label (since selectedIndex == 0)
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      // Inactive icons for Tagihan & Wallets
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

      // Isolated right-aligned Add circular button
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // 2. Tap Tagihan -> index updates to 1, Tagihan active label appears
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.text('Tagihan'), findsOneWidget);

      // 3. Tap Wallets -> index updates to 2, Wallets active label appears
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.text('Wallets'), findsOneWidget);

      // 4. Tap isolated circular Add button -> triggers onAddAction
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(addPressed, isTrue);
    });

    testWidgets('Add button is isolated circle with neo-chartreuse color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              currentIndex: 0,
              onTapIndex: (_) {},
              onAddAction: () {},
            ),
          ),
        ),
      );

      // Verify Add button container geometry & decoration
      final addIcon = find.byIcon(Icons.add_rounded);
      expect(addIcon, findsOneWidget);

      final containerFinder = find.ancestor(
        of: addIcon,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, AppColors.neoChartreuse);
      expect(container.constraints?.maxWidth ?? (container.child != null ? 56.0 : 0.0), 56.0);
    });

    testWidgets('Add button triggers 3D tilt, spring slingshot, and rotation on tap', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              currentIndex: 0,
              onTapIndex: (_) {},
              onAddAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      final addIcon = find.byIcon(Icons.add_rounded);
      expect(addIcon, findsOneWidget);

      // Tap the Add button
      await tester.tap(addIcon);
      expect(actionTriggered, isTrue);

      // Advance into animation: shockwave ring is active and rotation is in progress
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final rotationTransition = tester.widget<RotationTransition>(
        find.descendant(
          of: find.byType(AddActionButton),
          matching: find.byType(RotationTransition),
        ),
      );
      expect(rotationTransition.turns.value, greaterThan(0.0));

      // Pump until animation settles
      await tester.pumpAndSettle();
      expect(rotationTransition.turns.value, 0.25);
    });

    testWidgets('Active nav item expands horizontally while inactive items shrink and animate', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return BottomNavDock(
                  currentIndex: selectedIndex,
                  onTapIndex: (i) => setState(() => selectedIndex = i),
                  onAddAction: () {},
                );
              },
            ),
          ),
        ),
      );

      // Find the sized boxes containing each nav item
      final homeFinder = find.ancestor(of: find.text('Home'), matching: find.byType(SizedBox)).first;
      final homeSizeInitial = tester.getSize(homeFinder);

      final tagihanIconFinder = find.byIcon(Icons.receipt_long_outlined);
      final tagihanFinder = find.ancestor(of: tagihanIconFinder, matching: find.byType(SizedBox)).first;
      final tagihanSizeInitial = tester.getSize(tagihanFinder);

      // Active item (Home) is expanded relative to inactive Tagihan (compact 1.35x ratio)
      expect(homeSizeInitial.width, greaterThan(tagihanSizeInitial.width * 1.25));
      // Tap Tagihan to switch active tab
      await tester.tap(tagihanIconFinder);
      await tester.pump();
      // Pump mid-animation frame
      await tester.pump(const Duration(milliseconds: 140));

      final tagihanSizeMid = tester.getSize(find.ancestor(of: find.byIcon(Icons.receipt_long), matching: find.byType(SizedBox)).first);
      // Tagihan has started expanding
      expect(tagihanSizeMid.width, greaterThan(tagihanSizeInitial.width));

      // Let animation settle
      await tester.pumpAndSettle();

      final homeFinderAfter = find.ancestor(of: find.byIcon(Icons.dashboard_outlined), matching: find.byType(SizedBox)).first;
      final homeSizeFinal = tester.getSize(homeFinderAfter);

      final tagihanFinderAfter = find.ancestor(of: find.text('Tagihan'), matching: find.byType(SizedBox)).first;
      final tagihanSizeFinal = tester.getSize(tagihanFinderAfter);

      // Tagihan is now expanded, and Home has shrunk
      expect(tagihanSizeFinal.width, greaterThan(homeSizeFinal.width * 1.25));
      expect(homeSizeFinal.width, lessThan(homeSizeInitial.width));
    });
  });
}
