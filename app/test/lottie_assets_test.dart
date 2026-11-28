import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  const assets = [
    'assets/lottie/onb_language.json',
    'assets/lottie/onb_welcome.json',
    'assets/lottie/onb_name.json',
    'assets/lottie/onb_username.json',
    'assets/lottie/onb_income.json',
    'assets/lottie/onb_wallet.json',
    'assets/lottie/onb_ready.json',
  ];

  for (final path in assets) {
    testWidgets('Lottie parses and animates $path without errors', (tester) async {
      final bytes = File(path).readAsBytesSync();
      final comp = await LottieComposition.fromBytes(bytes);

      final ctrl = AnimationController(
        vsync: tester,
        duration: comp.duration,
      );
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie(composition: comp, controller: ctrl),
              ),
            ),
          ),
        ),
      );

      for (final t in [0.0, 0.1, 0.25, 0.35, 0.5, 0.65, 0.8, 0.95, 1.0]) {
        ctrl.value = t;
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
