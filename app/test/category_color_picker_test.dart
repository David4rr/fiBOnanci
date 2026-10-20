import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/settings/category_color_picker.dart';
import 'package:fibonanci_app/presentation/modals/settings/settings_category_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftFinanceRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftFinanceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child, [FinanceBloc? bloc]) {
    final effectiveBloc = bloc ?? FinanceBloc(repository: repo);
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: effectiveBloc,
          child: child,
        ),
      ),
    );
  }

  testWidgets('CategoryColorPicker selects color from 16-palette and custom HEX without icon selector', (tester) async {
    String selectedColor = '#D4F442';

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: CategoryColorPicker(
                selectedColor: selectedColor,
                onColorChanged: (c) => setState(() => selectedColor = c),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(CategoryColorPicker.palette.length, 16);
    expect(find.byKey(const Key('color_chip_#3B82F6')), findsOneWidget);

    // 1. Select palette color
    await tester.tap(find.byKey(const Key('color_chip_#3B82F6')));
    await tester.pumpAndSettle();
    expect(selectedColor, '#3B82F6');

    // 2. Open Custom HEX input and enter custom hex
    await tester.tap(find.text('# Custom HEX'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '#FF4081');
    await tester.pumpAndSettle();
    expect(selectedColor, '#FF4081');
  });

  testWidgets('SettingsCategorySection creates category with custom color from expanded picker', (tester) async {
    final bloc = FinanceBloc(repository: repo);
    bloc.add(const LoadFinanceData());
    await tester.pumpWidget(buildTestableWidget(
      const SettingsCategorySection(categories: []),
      bloc,
    ));
    await tester.pumpAndSettle();

    // Tap + Tambah
    await tester.tap(find.byKey(const Key('settings_add_category_toggle')));
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(find.byKey(const Key('settings_new_category_input')), 'Hobi & Koleksi');
    await tester.pumpAndSettle();

    // Select custom color
    await tester.tap(find.byKey(const Key('color_chip_#EC4899')));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.byKey(const Key('settings_save_category_button')));
    await tester.pumpAndSettle();

    // Verify added to repository
    final categories = await repo.getCategories();
    final created = categories.firstWhere((c) => c.name == 'Hobi & Koleksi');
    expect(created.colorHex, '#EC4899');
    expect(created.iconName, 'category');
  });
}
