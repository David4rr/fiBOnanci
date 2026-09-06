import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppChoiceChip switches instantaneously without dual-green overlap', (tester) async {
    String selectedValue = 'A';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: [
                  AppChoiceChip(
                    label: 'Option A',
                    selected: selectedValue == 'A',
                    onTap: () {
                      setState(() {
                        selectedValue = 'A';
                      });
                    },
                  ),
                  AppChoiceChip(
                    label: 'Option B',
                    selected: selectedValue == 'B',
                    onTap: () {
                      setState(() {
                        selectedValue = 'B';
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // Helper to count how many containers have the neoChartreuse color
    int countGreenChips() {
      final containers = tester.widgetList<Container>(find.byType(Container));
      int count = 0;
      for (final c in containers) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration && decoration.color == AppColors.neoChartreuse) {
          count++;
        }
      }
      return count;
    }

    // Initially Option A is selected (1 green chip)
    expect(countGreenChips(), equals(1));

    // Tap Option B
    await tester.tap(find.text('Option B'));
    // Do a single micro-pump (first frame after tap) - NO settle
    await tester.pump();

    // Immediately on frame 1, exactly 1 chip is green (Option B).
    // There is NEVER a state where 2 chips are green at once.
    expect(countGreenChips(), equals(1));

    // Settle completely
    await tester.pumpAndSettle();
    expect(countGreenChips(), equals(1));
  });
}
