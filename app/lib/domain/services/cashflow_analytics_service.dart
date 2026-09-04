import '../../data/database/app_database.dart';
import 'pocket_trend_service.dart';

export 'pocket_trend_service.dart' show PocketStockTrendResult;

/// Value object representing aggregated income & expense for the current month.
class MonthlyCashflow {
  final double income;
  final double expense;

  const MonthlyCashflow({this.income = 0.0, this.expense = 0.0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyCashflow &&
          runtimeType == other.runtimeType &&
          income == other.income &&
          expense == other.expense;

  @override
  int get hashCode => Object.hash(income, expense);
}

/// Pure domain service for transaction analytics and cashflow calculations.
class CashflowAnalyticsService {
  /// Aggregates total income and expense for the current month.
  static MonthlyCashflow calculateMonthlyCashflow(
    List<TransactionEntry> transactions, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    double income = 0.0;
    double expense = 0.0;

    for (final tx in transactions) {
      final localTx = tx.transactionDate.toLocal();
      if (localTx.year == now.year && localTx.month == now.month) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else if (tx.type == 'expense') {
          expense += tx.amount;
        }
      }
    }

    return MonthlyCashflow(income: income, expense: expense);
  }

  /// Computes 30-day daily aggregation series for income or expense.
  static List<double> compute30DaySeries(
    List<TransactionEntry> transactions, {
    required String type,
    String? walletId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<double> dailyValues = List.filled(30, 0.0);

    for (final tx in transactions) {
      if (walletId != null && tx.walletId != walletId && tx.destinationWalletId != walletId) {
        continue;
      }
      if (tx.type != type) continue;

      final localTx = tx.transactionDate.toLocal();
      final txDay = DateTime(localTx.year, localTx.month, localTx.day);
      final diff = today.difference(txDay).inDays;

      if (diff >= 0 && diff < 30) {
        dailyValues[29 - diff] += tx.amount;
      } else if (diff < 0 && diff >= -1) {
        dailyValues[29] += tx.amount;
      }
    }

    return dailyValues;
  }

  /// Computes real 7-day daily spending/income (Sen–Min) for the week of referenceDate.
  static List<double> computeWeeklySpending(
    List<TransactionEntry> transactions, {
    DateTime? referenceDate,
    String? walletId,
    String? categoryId,
    String? type,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final monday = today.subtract(Duration(days: ref.weekday - 1));
    final List<double> dailySpend = List.filled(7, 0.0);

    for (final tx in transactions) {
      if (type != null) {
        if (tx.type != type) continue;
      } else {
        if (tx.type != 'expense' && tx.type != 'transfer') continue;
      }
      if (walletId != null && tx.walletId != walletId && tx.destinationWalletId != walletId) continue;
      if (categoryId != null && tx.categoryId != categoryId) continue;

      final localTx = tx.transactionDate.toLocal();
      final txDate = DateTime(localTx.year, localTx.month, localTx.day);
      final diff = txDate.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        dailySpend[diff] += tx.amount;
      }
    }

    return dailySpend;
  }

  /// Generates 30 labels with 5 evenly spaced date interval markers.
  static List<String> compute30DayLabels({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    return List.generate(30, (i) {
      if (i == 0 || i == 7 || i == 14 || i == 21 || i == 29) {
        final d = now.subtract(Duration(days: 29 - i));
        return '${d.day}/${d.month}';
      }
      return '';
    });
  }

  /// Pure filtering and searching logic for transaction list views.
  static List<TransactionEntry> filterTransactions({
    required List<TransactionEntry> transactions,
    required List<WalletEntry> wallets,
    String query = '',
    String typeFilter = 'all',
    String? walletFilter,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return transactions.where((tx) {
      if (cleanQuery.isNotEmpty) {
        final notes = (tx.notes ?? '').toLowerCase();
        final type = tx.type.toLowerCase();
        final amt = tx.amount.toString();
        final wallet = wallets.firstWhere(
          (w) => w.id == tx.walletId,
          orElse: () => wallets.isNotEmpty
              ? wallets.first
              : WalletEntry(
                  id: '',
                  name: '',
                  type: '',
                  currency: '',
                  balance: 0,
                  colorHex: '#64748B',
                  iconName: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isSynced: false,
                  isDeleted: false,
                ),
        );
        final walletName = wallet.name.toLowerCase();
        final typeIndo = tx.type == 'income' ? 'pemasukan masuk' : (tx.type == 'expense' ? 'pengeluaran keluar' : 'transfer');
        final match = notes.contains(cleanQuery) ||
            type.contains(cleanQuery) ||
            typeIndo.contains(cleanQuery) ||
            amt.contains(cleanQuery) ||
            walletName.contains(cleanQuery);
        if (!match) return false;
      }

      if (typeFilter != 'all' && tx.type != typeFilter) return false;
      if (walletFilter != null && tx.walletId != walletFilter && tx.destinationWalletId != walletFilter) return false;

      return true;
    }).toList();
  }

  /// Computes historical stock-like balance trajectory for Kantong Tabungan.
  static PocketStockTrendResult computePocketTrendSeries({
    required double currentTotal,
    required List<TransactionEntry> transactions,
    required String filter,
    DateTime? referenceDate,
  }) {
    return PocketTrendService.computePocketTrendSeries(
      currentTotal: currentTotal,
      transactions: transactions,
      filter: filter,
      referenceDate: referenceDate,
    );
  }
}
