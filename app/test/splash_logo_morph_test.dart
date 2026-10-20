import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/presentation/widgets/common/fibonanci_logo_mark.dart';
import 'package:fibonanci_app/presentation/widgets/common/fibonanci_splash_gate.dart';

void main() {
  group('FibonanciLogoMark & FibonanciSplashGate Morphing Tests', () {
    testWidgets('FibonanciLogoMark renders across morphProgress 0.0 -> 0.5 -> 1.0 without error', (tester) async {
      for (final p in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: FibonanciLogoMark(
                  size: 96,
                  morphProgress: p,
                  showGlow: true,
                ),
              ),
            ),
          ),
        );
        expect(find.byType(FibonanciLogoMark), findsOneWidget);
      }
    });

    testWidgets('FibonanciSplashGate animates morphing stages and unmounts overlay on completion', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FibonanciSplashGate(
            duration: Duration(milliseconds: 1200),
            child: Scaffold(
              body: Text('DASHBOARD_READY_CONTENT'),
            ),
          ),
        ),
      );

      // Frame 0: both underlying child and splash overlay are present
      expect(find.byKey(const Key('fibonanci_splash_overlay')), findsOneWidget);
      expect(find.byKey(const Key('fibonanci_splash_logo')), findsOneWidget);
      expect(find.text('DASHBOARD_READY_CONTENT'), findsOneWidget);

      // Mid-morph Stage 1 -> Stage 2 (450ms)
      await tester.pump(const Duration(milliseconds: 450));
      final midLogo = tester.widget<FibonanciLogoMark>(
        find.byKey(const Key('fibonanci_splash_logo')),
      );
      expect(midLogo.morphProgress, greaterThan(0.3));
      expect(midLogo.morphProgress, lessThan(1.0));
      expect(find.text('φ 1.618 • ON-DEVICE VAULT'), findsOneWidget);

      // Stage 2 -> Stage 3 (950ms): logo morph completed (1.0), curtain dissolving
      await tester.pump(const Duration(milliseconds: 500));
      final lateLogo = tester.widget<FibonanciLogoMark>(
        find.byKey(const Key('fibonanci_splash_logo')),
      );
      expect(lateLogo.morphProgress, equals(1.0));

      // Settle animation -> splash overlay unmounts completely
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('fibonanci_splash_overlay')), findsNothing);
      expect(find.text('DASHBOARD_READY_CONTENT'), findsOneWidget);
    });

    testWidgets('FibonanciSplashGate animates shared element flight from center shrinking to top-left corner', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FibonanciSplashGate(
            duration: const Duration(milliseconds: 1200),
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: FibonanciSplashGate.isSplashActive,
                        builder: (context, isActive, child) {
                          return Opacity(
                            opacity: isActive ? 0.0 : 1.0,
                            child: child,
                          );
                        },
                        child: FibonanciLogoMark(
                          key: FibonanciSplashGate.dashboardLogoKey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'fiBOnanci',
                        key: FibonanciSplashGate.dashboardTextKey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // At t=0: splash overlay logo is centered and large
      final startLogoFinder = find.byKey(const Key('fibonanci_splash_logo'));
      expect(startLogoFinder, findsOneWidget);
      final startRect = tester.getRect(startLogoFinder);
      expect(startRect.width, equals(104.0));
      // Horizontally centered on 400 width: (400 - 104) / 2 = 148
      expect(startRect.left, closeTo(148.0, 1.0));

      // At 400ms: splash text is revealed in center
      await tester.pump(const Duration(milliseconds: 400));
      final startTextFinder = find.byKey(const Key('fibonanci_splash_text'));
      expect(startTextFinder, findsOneWidget);
      final startTextRect = tester.getRect(startTextFinder);
      expect(startTextRect.top, greaterThan(startRect.bottom));
      expect(startTextRect.left, greaterThan(50.0));

      // At 850ms (t ≈ 0.70): flight in progress towards top-left, shrinking
      await tester.pump(const Duration(milliseconds: 450));
      final flightLogoFinder = find.byKey(const Key('fibonanci_splash_logo'));
      final flightRect = tester.getRect(flightLogoFinder);
      expect(flightRect.width, lessThan(104.0));
      expect(flightRect.width, greaterThan(24.0));
      expect(flightRect.left, lessThan(startRect.left)); // moved left
      expect(flightRect.top, lessThan(startRect.top)); // moved up

      // Text also in flight towards header position
      final flightTextFinder = find.byKey(const Key('fibonanci_splash_text'));
      expect(flightTextFinder, findsOneWidget);
      final flightTextRect = tester.getRect(flightTextFinder);
      expect(flightTextRect.left, lessThan(startTextRect.left)); // moved left towards header
      expect(flightTextRect.top, lessThan(startTextRect.top)); // moved up towards header

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('fibonanci_splash_overlay')), findsNothing);
      expect(find.byKey(FibonanciSplashGate.dashboardLogoKey), findsOneWidget);
      final finalRect = tester.getRect(find.byKey(FibonanciSplashGate.dashboardLogoKey));
      expect(finalRect.width, equals(24.0));
      expect(finalRect.left, equals(20.0));
    });

    testWidgets('FibonanciSplashGate provides strictly monotonic 120Hz trajectory with zero offscreen layers', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FibonanciSplashGate(
            duration: const Duration(milliseconds: 1200),
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      FibonanciLogoMark(
                        key: FibonanciSplashGate.dashboardLogoKey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'fiBOnanci',
                        key: FibonanciSplashGate.dashboardTextKey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Ensure child is wrapped in RepaintBoundary for single-pass GPU isolation
      expect(find.byType(RepaintBoundary), findsWidgets);

      // Advance to flight start (t = 0.48 * 1200 = 576ms)
      await tester.pump(const Duration(milliseconds: 576));

      double lastLeft = double.infinity;
      double lastWidth = double.infinity;

      // Sample 10 frames during flight (~8.33ms intervals / 60ms steps)
      for (int i = 0; i < 9; i++) {
        await tester.pump(const Duration(milliseconds: 60));
        final logoFinder = find.byKey(const Key('fibonanci_splash_logo'));
        if (logoFinder.evaluate().isNotEmpty) {
          final rect = tester.getRect(logoFinder);
          // Must strictly progress towards target (monotonic decrease in left and width)
          expect(rect.left, lessThanOrEqualTo(lastLeft + 0.001));
          expect(rect.width, lessThanOrEqualTo(lastWidth + 0.001));
          lastLeft = rect.left;
          lastWidth = rect.width;
        }
      }

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('fibonanci_splash_overlay')), findsNothing);
    });
  });
}
