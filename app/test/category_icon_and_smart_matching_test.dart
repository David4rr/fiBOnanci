import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/settings/category_icon_picker.dart';
import 'package:fibonanci_app/presentation/modals/settings/settings_category_section.dart';
import 'package:fibonanci_app/presentation/theme/category_icon_resolver.dart';
import 'package:fibonanci_app/core/smart_input/smart_transaction_parser.dart';
import 'package:drift/native.dart';

void main() {
  final now = DateTime.now().toUtc();
  final sampleCategories = [
    CategoryEntry(id: 'cat_food', name: 'Makanan & Minuman', type: 'expense', iconName: 'utensils', colorHex: '#EF4444', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_trans', name: 'Transportasi', type: 'expense', iconName: 'car', colorHex: '#F97316', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_shop', name: 'Belanja & Kebutuhan', type: 'expense', iconName: 'shopping_bag', colorHex: '#F59E0B', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_bills', name: 'Tagihan & Utilitas', type: 'expense', iconName: 'receipt', colorHex: '#3B82F6', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_ent', name: 'Hiburan & Langganan', type: 'expense', iconName: 'film', colorHex: '#8B5CF6', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_health', name: 'Kesehatan', type: 'expense', iconName: 'heart_pulse', colorHex: '#EC4899', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_pet', name: 'Hewan Peliharaan', type: 'expense', iconName: 'pets', colorHex: '#10B981', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_salary', name: 'Gaji Pokok', type: 'income', iconName: 'banknote', colorHex: '#10B981', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
    CategoryEntry(id: 'cat_bonus', name: 'Bonus & Freelance', type: 'income', iconName: 'sparkles', colorHex: '#14B8A6', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
  ];

  group('CategoryIconResolver & CategoryIconPicker Tests', () {
    test('CategoryIconResolver maps known icon keys and falls back gracefully', () {
      expect(CategoryIconResolver.mapCategoryIcon('coffee'), Icons.coffee_rounded);
      expect(CategoryIconResolver.mapCategoryIcon('pets'), Icons.pets_rounded);
      expect(CategoryIconResolver.mapCategoryIcon('home'), Icons.home_rounded);
      expect(CategoryIconResolver.mapCategoryIcon('electric_bolt'), Icons.electric_bolt_rounded);
      expect(CategoryIconResolver.mapCategoryIcon('unknown', fallback: Icons.help_outline), Icons.help_outline);
      expect(CategoryIconResolver.availableIcons.length, greaterThanOrEqualTo(20));
    });

    testWidgets('CategoryIconPicker renders icons and responds to selection', (tester) async {
      String selected = 'utensils';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryIconPicker(
              selectedIcon: selected,
              onIconChanged: (icon) => selected = icon,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PILIH IKON'), findsOneWidget);
      expect(find.text('Makanan'), findsOneWidget);

      final coffeeKey = find.byKey(const Key('category_icon_coffee'));
      expect(coffeeKey, findsOneWidget);
      await tester.tap(coffeeKey);
      await tester.pumpAndSettle();
      expect(selected, 'coffee');
    });
  });

  group('SmartCategoryMatcher Accuracy Tests', () {
    test('accurately classifies notification body & counterparty across Indonesian merchants', () {
      final f1 = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'expense',
        text: 'Pembayaran QRIS Rp 45.000 ke KOPI KENANGAN berhasil',
        counterparty: 'KOPI KENANGAN',
      );
      expect(f1?.id, 'cat_food');

      final f2 = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'expense',
        text: 'Transaksi Berhasil Rp 150.000 di PT PLN (PERSERO)',
        counterparty: 'PLN PREPAID',
      );
      expect(f2?.id, 'cat_bills');

      final f3 = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'expense',
        text: 'Gojek Payment Rp 18.000 untuk GoRide ke Stasiun Gambir',
        counterparty: 'GOJEK',
      );
      expect(f3?.id, 'cat_trans');

      final f4 = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'expense',
        text: 'Pembayaran di INDOMARET POINT Rp 32.500 berhasil',
        counterparty: 'INDOMARET',
      );
      expect(f4?.id, 'cat_shop');

      final f5 = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'income',
        text: 'Transfer masuk dari PT GOOGLE INDONESIA Rp 25.000.000 (Gaji Bulanan)',
        counterparty: 'PT GOOGLE INDONESIA',
      );
      expect(f5?.id, 'cat_salary');
    });

    test('accurately classifies Receipt OCR and custom categories with icon semantics', () {
      final receiptMatch = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'expense',
        text: 'PT. SUMBER ALFARIA TRIJAYA, TBK\nJL. RAYA PASAR MINGGU NO 12\nTOTAL: Rp 58.000',
      );
      expect(receiptMatch?.id, 'cat_shop');

      final petMatch = SmartCategoryMatcher.matchCategory(
        categories: sampleCategories, type: 'expense',
        text: 'Beli pakan kucing whiskas di petshop 75 ribu',
      );
      expect(petMatch?.id, 'cat_pet');

      final voiceDraft = SmartTransactionParser.parse(
        rawText: 'Beli obat batuk dan vitamin di apotek kimia farma 50 ribu',
        source: SmartInputSource.voice,
        wallets: [
          WalletEntry(id: 'w1', name: 'BCA', type: 'bank', currency: 'IDR', balance: 1000000, colorHex: '#0060AF', iconName: 'landmark', createdAt: now, updatedAt: now, isSynced: false, isDeleted: false),
        ],
        categories: sampleCategories,
      );
      expect(voiceDraft.categoryId, 'cat_health');
      expect(voiceDraft.amount, 50000.0);
    });
  });

  group('SettingsCategorySection Icon Integration Tests', () {
    testWidgets('allows selecting an icon when adding a new category and displays icon in chips', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      addTearDown(() async {
        await bloc.close();
        await db.close();
      });

      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: SettingsCategorySection(categories: sampleCategories),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Category chips render category icon
      expect(find.byIcon(Icons.restaurant_rounded), findsWidgets);
      expect(find.byIcon(Icons.directions_car_rounded), findsWidgets);

      // Tap + Tambah
      await tester.tap(find.byKey(const Key('settings_add_category_toggle')));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryIconPicker), findsOneWidget);
      expect(find.byKey(const Key('settings_new_category_input')), findsOneWidget);

      // Enter name and choose coffee icon
      await tester.enterText(find.byKey(const Key('settings_new_category_input')), 'Kafe & Kopi');
      await tester.pumpAndSettle();

      final coffeeIcon = find.byKey(const Key('category_icon_coffee'));
      await tester.tap(coffeeIcon);
      await tester.pumpAndSettle();

      // Tap Simpan
      await tester.tap(find.byKey(const Key('settings_save_category_button')));
      await tester.pumpAndSettle();

      final updatedCats = await repo.getCategories();
      final added = updatedCats.firstWhere((c) => c.name == 'Kafe & Kopi');
      expect(added.iconName, 'coffee');
    });
  });
}
