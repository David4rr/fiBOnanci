import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/folder_tab_card.dart';
import 'package:fibonanci_app/presentation/widgets/overlapping_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FolderTabCard renders child and clips without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FolderTabCard(
            backgroundColor: AppColors.neoChartreuse,
            child: Text('Safe to Spend'),
          ),
        ),
      ),
    );

    expect(find.text('Safe to Spend'), findsOneWidget);
  });

  testWidgets('OverlappingDeckItem renders title, category, and formatted currency', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OverlappingDeckItem(
            title: 'Kopi Kenangan',
            category: 'Makanan & Minuman',
            amount: 35000.0,
            categoryColor: AppColors.neoCoral,
            iconData: Icons.coffee,
          ),
        ),
      ),
    );

    expect(find.text('Kopi Kenangan'), findsOneWidget);
    expect(find.text('MAKANAN & MINUMAN'), findsOneWidget);
    expect(find.textContaining('35.000'), findsOneWidget);
  });
}
