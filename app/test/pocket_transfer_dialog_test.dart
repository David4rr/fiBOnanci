import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/pocket_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('PocketDetailModal.showTransferDialog allows selecting dropdown wallet and transfers funds', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftFinanceRepository(db);
    await repo.addPocket(
      name: 'Dana Liburan',
      targetAmount: 5000000.0,
      type: 'goal',
      colorHex: '#26D9D9',
      iconName: 'flag',
    );
    final pockets = await repo.getPockets();
    final pocket = pockets.first;
    final bloc = FinanceBloc(repository: repo);
    bloc.add(const LoadFinanceData());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isNotEmpty)),
    );

    addTearDown(bloc.close);
    addTearDown(db.close);
    await tester.pumpWidget(
      BlocProvider<FinanceBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    PocketDetailModal.showTransferDialog(
                      context,
                      pocket: pocket,
                      isDeposit: true,
                    );
                  },
                  child: const Text('Open Transfer Dialog'),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open Transfer Dialog
    await tester.tap(find.text('Open Transfer Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Isi Dana ke Kantong'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // 2. Tap Dropdown to view items
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // There should be multiple wallet items from seed (e.g. BCA Utama, GoPay, etc.)
    // Select another wallet from the opened popup
    final targetWalletItem = find.textContaining('SeaBank').last;
    expect(targetWalletItem, findsOneWidget);
    await tester.tap(targetWalletItem);
    await tester.pumpAndSettle();

    // 4. Enter amount
    final amountField = find.widgetWithText(TextField, 'Nominal');
    expect(amountField, findsOneWidget);
    await tester.enterText(amountField, '50000');
    await tester.pumpAndSettle();

    // 5. Tap Konfirmasi
    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();

    // Dialog should be closed
    expect(find.text('Isi Dana ke Kantong'), findsNothing);
  });
}
