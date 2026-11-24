import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/presentation/widgets/common/smooth_page_view.dart';

void main() {
  testWidgets('SmoothPageView keeps page at 1.0 opacity after reparenting and rebuild', (tester) async {
    final controller = PageController(initialPage: 0);
    final repaintKey = GlobalKey();

    Widget buildTree(bool inStack) {
      final content = Scaffold(
        body: SmoothPageView(
          controller: controller,
          children: const [
            Text('Page 0 Content'),
            Text('Page 1 Content'),
          ],
        ),
      );

      if (inStack) {
        return MaterialApp(
          home: Stack(
            children: [
              const Text('Old Image Placeholder'),
              RepaintBoundary(
                key: repaintKey,
                child: content,
              ),
            ],
          ),
        );
      } else {
        return MaterialApp(
          home: RepaintBoundary(
            key: repaintKey,
            child: content,
          ),
        );
      }
    }

    await tester.pumpWidget(buildTree(false));
    await tester.pumpAndSettle();

    // Move to page 1
    controller.jumpToPage(1);
    await tester.pumpAndSettle();

    double getPage1Opacity() {
      final finder = find.ancestor(
        of: find.text('Page 1 Content'),
        matching: find.byType(Opacity),
      );
      if (finder.evaluate().isEmpty) return 1.0;
      return tester.widget<Opacity>(finder.first).opacity;
    }

    expect(getPage1Opacity(), 1.0);

    // Now reparent into Stack (simulating theme switch)
    await tester.pumpWidget(buildTree(true));
    expect(getPage1Opacity(), 1.0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(getPage1Opacity(), 1.0);

    // Clean up out of Stack
    await tester.pumpWidget(buildTree(false));
    expect(getPage1Opacity(), 1.0);
  });
}
