import '../../data/database/app_database.dart';

/// Value object representing aggregated income & expense for the current month.
class MonthlyCashflow {
  final double income;
  final double expense;

  const MonthlyCashflow({
    this.income = 0.0,
    this.expense = 0.0,
  });

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

/// Pure domain service for transaction analytics, cashflow calculations,
/// and transaction filtering. Isolates business math from Flutter UI widgets.
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
      if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
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
    final List<double> dailyValues = List.filled(30, 0.0);

    for (final tx in transactions) {
      if (walletId != null && tx.walletId != walletId && tx.destinationWalletId != walletId) {
        continue;
      }
      if (tx.type != type) continue;

      final diff = now.difference(tx.transactionDate).inDays;
      if (diff >= 0 && diff < 30) {
        final index = 29 - diff;
        dailyValues[index] += tx.amount;
      }
    }

    return dailyValues;
  }

  /// Computes real 7-day daily spending (Sen–Min, Monday–Sunday) for the week of referenceDate.
  /// Returns a 7-element List<double> [Mon, Tue, Wed, Thu, Fri, Sat, Sun].
  static List<double> computeWeeklySpending(
    List<TransactionEntry> transactions, {
    DateTime? referenceDate,
    String? walletId,
    String? categoryId,
  }) {
    final ref = referenceDate ?? DateTime.now();
    // Monday is weekday 1
    final monday = DateTime(ref.year, ref.month, ref.day).subtract(Duration(days: ref.weekday - 1));
    final List<double> dailySpend = List.filled(7, 0.0);

    for (final tx in transactions) {
      if (tx.type != 'expense' && tx.type != 'transfer') continue;
      if (walletId != null && tx.walletId != walletId) continue;
      if (categoryId != null && tx.categoryId != categoryId) continue;

      final txDate = DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);
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

        final match = notes.contains(cleanQuery) ||
            type.contains(cleanQuery) ||
            amt.contains(cleanQuery) ||
            walletName.contains(cleanQuery);
        if (!match) return false;
      }

      if (typeFilter != 'all' && tx.type != typeFilter) {
        return false;
      }

      if (walletFilter != null && tx.walletId != walletFilter) {
        return false;
      }

      return true;
    }).toList();
  }
}
