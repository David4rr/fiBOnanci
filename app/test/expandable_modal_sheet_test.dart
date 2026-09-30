import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableModalSheet Widget Tests', () {
    testWidgets('Opens at initialChildSize 0.85, expands to 1.0 on drag up, and dismisses on close', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sheetKey = GlobalKey<ExpandableModalSheetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.65),
                        pageBuilder: (ctx, _, _) => ExpandableModalSheet(
                          key: sheetKey,
                          initialChildSize: 0.85,
                          minChildSize: 0.40,
                          maxChildSize: 1.0,
                          snapSizes: const [0.85, 1.0],
                          builder: (c, scrollController, currentSize) {
                            return Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragUpdate: (d) => sheetKey.currentState?.handleHeaderDragUpdate(d),
                                  onVerticalDragEnd: (d) => sheetKey.currentState?.handleHeaderDragEnd(d),
                                  child: Container(
                                    height: 80,
                                    color: AppColors.canvasCardSurface,
                                    child: Row(
                                      children: [
                                        const Text('Modal Header'),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => Navigator.of(ctx).pop(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: 40,
                                    itemBuilder: (ctx2, i) => ListTile(title: Text('Item $i')),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Header'), findsOneWidget);
      expect(sheetKey.currentState?.currentSize, closeTo(0.85, 0.02));

      // Drag up on header to expand to 1.0
      await tester.drag(find.text('Modal Header'), const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(sheetKey.currentState?.currentSize, closeTo(1.0, 0.02));

      // Drag down on header to collapse to 0.85
      await tester.drag(find.text('Modal Header'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(sheetKey.currentState?.currentSize, closeTo(0.85, 0.02));

      // Tap close button to dismiss
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Modal Header'), findsNothing);
      expect(find.text('Open Modal'), findsOneWidget);
    });
    testWidgets('Opens in full screen (1.0) right away by default and collapses to 0.85 on drag down', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sheetKey = GlobalKey<ExpandableModalSheetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.65),
                        pageBuilder: (ctx, _, _) => ExpandableModalSheet(
                          key: sheetKey,
                          builder: (c, scrollController, currentSize) {
                            return ListView(
                              controller: scrollController,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragUpdate: (d) => sheetKey.currentState?.handleHeaderDragUpdate(d),
                                  onVerticalDragEnd: (d) => sheetKey.currentState?.handleHeaderDragEnd(d),
                                  child: const SizedBox(height: 80, child: Text('Full Screen Header')),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Full Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Full Modal'));
      await tester.pumpAndSettle();

      // Immediately opens at 1.0 (full screen)
      expect(find.text('Full Screen Header'), findsOneWidget);
      expect(sheetKey.currentState?.currentSize, closeTo(1.0, 0.02));

      // Drag down collapses to 0.85
      await tester.drag(find.text('Full Screen Header'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(sheetKey.currentState?.currentSize, closeTo(0.85, 0.02));
    });

    testWidgets('Dismisses when dragged down past minChildSize', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sheetKey = GlobalKey<ExpandableModalSheetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.65),
                        pageBuilder: (ctx, _, _) => ExpandableModalSheet(
                          key: sheetKey,
                          initialChildSize: 0.85,
                          minChildSize: 0.40,
                          maxChildSize: 1.0,
                          snapSizes: const [0.85, 1.0],
                          builder: (c, scrollController, currentSize) {
                            return ListView(
                              controller: scrollController,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragUpdate: (d) => sheetKey.currentState?.handleHeaderDragUpdate(d),
                                  onVerticalDragEnd: (d) => sheetKey.currentState?.handleHeaderDragEnd(d),
                                  child: const SizedBox(
                                    height: 100,
                                    child: Text('Draggable Content'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Draggable Content'), findsOneWidget);

      // Drag down past minChildSize threshold to dismiss
      await tester.drag(find.text('Draggable Content'), const Offset(0, 550));
      await tester.pumpAndSettle();

      expect(find.text('Draggable Content'), findsNothing);
      expect(find.text('Open Modal'), findsOneWidget);
    });

    testWidgets('Dismisses immediately on moderate downward drag when opened at initialChildSize 0.94', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sheetKey = GlobalKey<ExpandableModalSheetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.65),
                        pageBuilder: (ctx, _, _) => ExpandableModalSheet(
                          key: sheetKey,
                          initialChildSize: 0.94,
                          minChildSize: 0.25,
                          maxChildSize: 1.0,
                          snapSizes: const [0.94, 1.0],
                          builder: (c, scrollController, currentSize) {
                            return ListView(
                              controller: scrollController,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragUpdate: (d) => sheetKey.currentState?.handleHeaderDragUpdate(d),
                                  onVerticalDragEnd: (d) => sheetKey.currentState?.handleHeaderDragEnd(d),
                                  child: const SizedBox(height: 100, child: Text('Detail 0.94 Header')),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open 0.94 Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open 0.94 Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Detail 0.94 Header'), findsOneWidget);
      expect(sheetKey.currentState?.currentSize, closeTo(0.94, 0.02));

      // Drag down moderately (only 80px) from 0.94 -> dismisses!
      await tester.drag(find.text('Detail 0.94 Header'), const Offset(0, 80));
      await tester.pumpAndSettle();

      expect(find.text('Detail 0.94 Header'), findsNothing);
      expect(find.text('Open 0.94 Modal'), findsOneWidget);
    });

    testWidgets('Dismisses on downward drag even when scrollController is not attached to any scrollable', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sheetKey = GlobalKey<ExpandableModalSheetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.65),
                        pageBuilder: (ctx, _, _) => ExpandableModalSheet(
                          key: sheetKey,
                          initialChildSize: 0.94,
                          minChildSize: 0.25,
                          maxChildSize: 1.0,
                          snapSizes: const [0.94, 1.0],
                          builder: (c, scrollController, currentSize) {
                            return Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragUpdate: (d) => sheetKey.currentState?.handleHeaderDragUpdate(d),
                                  onVerticalDragEnd: (d) => sheetKey.currentState?.handleHeaderDragEnd(d),
                                  child: const SizedBox(height: 100, child: Text('Unattached Header')),
                                ),
                                const Expanded(child: Text('Custom non-scrollable body')),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Unattached Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Unattached Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Unattached Header'), findsOneWidget);

      // Drag down on unattached header (80px) -> dismisses!
      await tester.drag(find.text('Unattached Header'), const Offset(0, 80));
      await tester.pumpAndSettle();

      expect(find.text('Unattached Header'), findsNothing);
      expect(find.text('Open Unattached Modal'), findsOneWidget);
    });
  });
}
