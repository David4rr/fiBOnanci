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
  });
}
