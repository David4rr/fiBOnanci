import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('IPhoneViewportContainer Unit Tests', () {
    testWidgets('Constrains width to 430pt and centers child on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1000 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late double capturedInnerWidth;
      late Size capturedChildRenderSize;
      const innerKey = ValueKey('inner_blue_container');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IPhoneViewportContainer(
              child: Builder(
                builder: (context) {
                  capturedInnerWidth = MediaQuery.sizeOf(context).width;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      capturedChildRenderSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return Container(key: innerKey, color: Colors.blue);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // On wide screens (1000pt), inner width is clamped to 430pt
      expect(capturedInnerWidth, 430.0);
      expect(capturedChildRenderSize.width, 430.0);

      // Container is horizontally centered: left offset should be (1000 - 430) / 2 = 285.0
      final childFinder = find.byKey(innerKey);
      final childTopLeft = tester.getTopLeft(childFinder);
      expect(childTopLeft.dx, 285.0);
    });

    testWidgets('Passes through natural width on standard phone screens (<= 430pt)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late double capturedInnerWidth;
      late Size capturedChildRenderSize;
      const innerKey = ValueKey('inner_green_container');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IPhoneViewportContainer(
              child: Builder(
                builder: (context) {
                  capturedInnerWidth = MediaQuery.sizeOf(context).width;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      capturedChildRenderSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return Container(key: innerKey, color: Colors.green);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // On phone screen (390pt), width remains natural (390pt)
      expect(capturedInnerWidth, 390.0);
      expect(capturedChildRenderSize.width, 390.0);

      // Starts at left = 0
      final childFinder = find.byKey(innerKey);
      final childTopLeft = tester.getTopLeft(childFinder);
      expect(childTopLeft.dx, 0.0);
    });

    testWidgets('Clears horizontal safe area padding when stretched to avoid landscape notch distortion', (tester) async {
      tester.view.physicalSize = const Size(900 * 2, 600 * 2);
      tester.view.devicePixelRatio = 2.0;
      tester.view.padding = const FakeViewPadding(left: 44, right: 44, top: 20, bottom: 20);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
      });

      late EdgeInsets capturedPadding;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IPhoneViewportContainer(
              child: Builder(
                builder: (context) {
                  capturedPadding = MediaQuery.paddingOf(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // Left and right are reset to 0 in centered mobile column
      expect(capturedPadding.left, 0.0);
      expect(capturedPadding.right, 0.0);
      // Vertical padding preserved: 20 physical pixels / 2.0 devicePixelRatio = 10.0
      expect(capturedPadding.top, 10.0);
      expect(capturedPadding.bottom, 10.0);
    });
  });

  group('FiBOnanciApp Full-Screen Stretching Disabled Tests', () {
    testWidgets('FiBOnanciApp on wide desktop/tablet screen renders clamped to iPhone dimensions', (tester) async {
      tester.view.physicalSize = const Size(1200 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      addTearDown(db.close);

      await tester.pumpWidget(
        FiBOnanciApp(database: db, repository: repo),
      );
      await tester.pumpAndSettle();

      // Verify MaterialApp builder applies IPhoneViewportContainer
      expect(find.byType(IPhoneViewportContainer), findsWidgets);

      // Main navigation shell and scaffold width should be 430pt, not 1200pt
      final scaffoldFinder = find.byType(Scaffold).first;
      final scaffoldSize = tester.getSize(scaffoldFinder);
      expect(scaffoldSize.width, 430.0);

      // Scaffold is horizontally centered: left offset is (1200 - 430) / 2 = 385.0
      final scaffoldTopLeft = tester.getTopLeft(scaffoldFinder);
      expect(scaffoldTopLeft.dx, 385.0);

      // Cleanly dispose widget tree and drain Drift stream timers
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
