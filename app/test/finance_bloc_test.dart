import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repository;
  late FinanceBloc bloc;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftFinanceRepository(db);
    bloc = FinanceBloc(repository: repository);
  });

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  test('FinanceBloc initializes, loads data, and precomputes Safe-to-Spend in RAM', () async {
    bloc.add(const LoadFinanceData());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<FinanceState>((state) {
          return state.status == FinanceStatus.success &&
              state.wallets.isNotEmpty &&
              state.categories.isNotEmpty;
        }),
      ),
    );

    expect(bloc.state.wallets.length, 7);
    expect(bloc.state.metrics.totalRealBalance, greaterThan(0));
  });

  test('Adding transaction via BLoC updates in-memory state and Safe-to-Spend', () async {
    bloc.add(const LoadFinanceData());
    await bloc.stream.firstWhere((s) => s.status == FinanceStatus.success);

    final bca = bloc.state.wallets.firstWhere((w) => w.name.contains('BCA'));
    final foodCat = bloc.state.categories.first;
    final initialSafe = bloc.state.metrics.safeToSpendMonthly;

    bloc.add(
      AddTransactionEvent(
        walletId: bca.id,
        categoryId: foodCat.id,
        amount: 25000.0,
        type: 'expense',
        notes: 'Sarapan Pagi',
      ),
    );

    // Wait for reactive database stream to push updated state to BLoC
    await bloc.stream.firstWhere((s) => s.transactions.any((t) => t.notes == 'Sarapan Pagi'));

    expect(bloc.state.transactions.any((t) => t.notes == 'Sarapan Pagi'), isTrue);
    expect(bloc.state.metrics.safeToSpendMonthly, initialSafe - 25000.0);
  });
}
