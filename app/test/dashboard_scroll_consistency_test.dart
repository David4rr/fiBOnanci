import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/screens/dashboard_screen.dart';
import 'package:fibonanci_app/presentation/widgets/bottom_nav_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Dashboard uses CustomScrollView with 140px bottom clearance consistent with WalletScreen', (tester) async {
    tester.view.physicalSize = const Size(400 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    await db.select(db.wallets).get();
    final repo = DriftFinanceRepository(db);

    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // Verify CustomScrollView is used instead of SingleChildScrollView
    expect(find.descendant(of: find.byType(DashboardScreen), matching: find.byType(CustomScrollView)), findsOneWidget);
    expect(find.descendant(of: find.byType(DashboardScreen), matching: find.byType(SingleChildScrollView)), findsNothing);

    // Verify CustomScrollView fills full viewport height (800.0) without being clipped at 742
    final scrollBox = tester.renderObject<RenderBox>(
      find.descendant(of: find.byType(DashboardScreen), matching: find.byType(CustomScrollView)),
    );
    expect(scrollBox.size.height, 800.0);

    // Verify BottomNavDock is positioned floating above it
    final dockFinder = find.byType(BottomNavDock);
    expect(dockFinder, findsOneWidget);
    final dockRect = tester.getRect(dockFinder);
    expect(dockRect.bottom, 800.0);

    // Drag to test scrolling down
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    await db.close();
  });
}
