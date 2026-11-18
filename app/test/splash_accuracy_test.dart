import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/theme/app_typography.dart';
import 'package:fibonanci_app/presentation/widgets/common/fibonanci_logo_mark.dart';
import 'package:fibonanci_app/presentation/widgets/common/fibonanci_splash_gate.dart';

void main() {
  group('Splash Landing Accuracy Tests', () {
    testWidgets('accurately lands logo and text on dashboard header targets without drift', (tester) async {
      tester.view.physicalSize = const Size(393 * 2, 852 * 2);
      tester.view.padding = const FakeViewPadding(top: 47.0 * 2, bottom: 34.0 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetPadding();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: FibonanciSplashGate(
            duration: const Duration(milliseconds: 1000),
            child: Scaffold(
              backgroundColor: AppColors.canvasBg,
              body: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FibonanciLogoMark(
                        key: FibonanciSplashGate.dashboardLogoKey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text.rich(
                        TextSpan(
                          style: AppTypography.heroGreeting,
                          children: const [
                            TextSpan(text: 'fi'),
                            TextSpan(
                              text: 'BO',
                              style: TextStyle(color: AppColors.neoChartreuse),
                            ),
                            TextSpan(text: 'nanci'),
                          ],
                        ),
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

      // Settle initial frame
      await tester.pump(const Duration(milliseconds: 50));

      final targetLogoRect = tester.getRect(find.byKey(FibonanciSplashGate.dashboardLogoKey));
      final targetTextRect = tester.getRect(find.byKey(FibonanciSplashGate.dashboardTextKey));

      // Advance animation right before completion: t = 0.98 (980ms / 1000ms)
      // At this stage, flightT = ((0.98 - 0.48) / 0.48).clamp(0, 1) = 1.0!
      await tester.pump(const Duration(milliseconds: 930));

      final flyingLogoFinder = find.byKey(const Key('fibonanci_splash_logo'));
      final flyingTextFinder = find.byKey(const Key('fibonanci_splash_text'));

      expect(flyingLogoFinder, findsOneWidget);
      expect(flyingTextFinder, findsOneWidget);

      final flyingLogoRect = tester.getRect(flyingLogoFinder);
      final flyingTextRect = tester.getRect(flyingTextFinder);

      // Verify that flying logo and text rects match the target header position with subpixel precision (< 0.1px)
      expect(flyingLogoRect.left, closeTo(targetLogoRect.left, 0.1));
      expect(flyingLogoRect.top, closeTo(targetLogoRect.top, 0.1));
      expect(flyingLogoRect.width, closeTo(targetLogoRect.width, 0.1));
      expect(flyingLogoRect.height, closeTo(targetLogoRect.height, 0.1));

      expect(flyingTextRect.left, closeTo(targetTextRect.left, 0.1));
      expect(flyingTextRect.top, closeTo(targetTextRect.top, 0.1));

      // Settle until splash completes and unmounts
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fibonanci_splash_overlay')), findsNothing);
    });
  });
}
