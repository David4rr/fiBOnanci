import 'package:intl/intl.dart';
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


/// Value object representing stock-like historical balance trajectory for Kantong Tabungan.
class PocketStockTrendResult {
  final List<double> values;
  final List<String> labels;
  final double initialBalance;
  final double currentBalance;
  final double delta;
  final double percentChange;
  final bool isUpward;

  const PocketStockTrendResult({
    required this.values,
    required this.labels,
    required this.initialBalance,
    required this.currentBalance,
    required this.delta,
    required this.percentChange,
    required this.isUpward,
  });
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
  /// Returns a 7-element `List<double>` [Mon, Tue, Wed, Thu, Fri, Sat, Sun].
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

  /// Computes historical stock-like balance trajectory for Kantong Tabungan.
  static PocketStockTrendResult computePocketTrendSeries({
    required double currentTotal,
    required List<TransactionEntry> transactions,
    required String filter, // '1M', '1B', '1T', 'Semua'
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    // Filter pocket-related transactions
    final pocketTxs = transactions.where((t) {
      final n = (t.notes ?? '').toLowerCase();
      return n.contains('kantong') || n.contains('pocket');
    }).toList();

    int numPoints;
    List<DateTime> sampleDates = [];
    List<String> labels = [];

    switch (filter) {
      case '1M':
        numPoints = 7;
        for (int i = numPoints - 1; i >= 0; i--) {
          sampleDates.add(DateTime(now.year, now.month, now.day - i, 23, 59, 59, 999));
        }
        labels = sampleDates.map((d) {
          try {
            return DateFormat('E', 'id_ID').format(d);
          } catch (_) {
            return DateFormat('E').format(d);
          }
        }).toList();
        break;

      case '1B':
        numPoints = 30;
        for (int i = numPoints - 1; i >= 0; i--) {
          sampleDates.add(DateTime(now.year, now.month, now.day - i, 23, 59, 59, 999));
        }
        // Generate 5 evenly spaced labels
        labels = List.generate(numPoints, (index) {
          if (index == 0 || index == 7 || index == 14 || index == 21 || index == 29) {
            try {
              return DateFormat('d MMM', 'id_ID').format(sampleDates[index]);
            } catch (_) {
              return DateFormat('d MMM').format(sampleDates[index]);
            }
          }
          return '';
        });
        break;

      case '1T':
        numPoints = 12;
        for (int i = numPoints - 1; i >= 0; i--) {
          if (i == 0) {
            sampleDates.add(endOfToday);
          } else {
            final lastDay = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59, 999);
            sampleDates.add(lastDay);
          }
        }
        labels = sampleDates.map((d) {
          try {
            return DateFormat('MMM', 'id_ID').format(d);
          } catch (_) {
            return DateFormat('MMM').format(d);
          }
        }).toList();
        break;

      case 'Semua':
      default:
        numPoints = 14;
        DateTime earliest = now.subtract(const Duration(days: 90));
        if (pocketTxs.isNotEmpty) {
          final firstTxDate = pocketTxs
              .map((t) => t.transactionDate.toLocal())
              .reduce((a, b) => a.isBefore(b) ? a : b);
          if (firstTxDate.isBefore(earliest)) {
            earliest = DateTime(firstTxDate.year, firstTxDate.month, firstTxDate.day, 0, 0, 0);
          }
        }
        final startMillis = DateTime(earliest.year, earliest.month, earliest.day, 0, 0, 0).millisecondsSinceEpoch;
        final endMillis = endOfToday.millisecondsSinceEpoch;
        final totalSpan = endMillis - startMillis;

        for (int i = 0; i < numPoints; i++) {
          if (i == numPoints - 1) {
            sampleDates.add(endOfToday);
          } else {
            final millis = (startMillis + (totalSpan * (i / (numPoints - 1)))).round();
            sampleDates.add(DateTime.fromMillisecondsSinceEpoch(millis));
          }
        }
        labels = List.generate(numPoints, (i) {
          if (i == 0 || i == (numPoints ~/ 2) || i == numPoints - 1) {
            try {
              return DateFormat('d/M/yy', 'id_ID').format(sampleDates[i]);
            } catch (_) {
              return DateFormat('d/M/yy').format(sampleDates[i]);
            }
          }
          return '';
        });
        break;
    }

    // Backward reconstruction from currentTotal
    final List<double> values = List.filled(numPoints, currentTotal);

    if (pocketTxs.isNotEmpty) {
      for (int i = numPoints - 2; i >= 0; i--) {
        final dateAfter = sampleDates[i];
        final dateNext = sampleDates[i + 1];

        double netDelta = 0.0;
        for (final tx in pocketTxs) {
          final txDate = tx.transactionDate.toLocal();
          if (txDate.isAfter(dateAfter) && !txDate.isAfter(dateNext)) {
            final n = (tx.notes ?? '').toLowerCase();
            final isDeposit = n.contains('setoran') || tx.type == 'transfer';
            if (isDeposit) {
              netDelta += tx.amount;
            } else {
              netDelta -= tx.amount;
            }
          }
        }
        values[i] = (values[i + 1] - netDelta).clamp(0.0, double.infinity);
      }
    } else {
      for (int i = 0; i < numPoints; i++) {
        values[i] = currentTotal;
      }
    }

    final initial = values.first;
    final current = values.last;
    final delta = current - initial;
    final percentChange = initial > 0
        ? (delta / initial) * 100
        : (current > 0 ? 100.0 : 0.0);
    final isUpward = delta >= 0;

    return PocketStockTrendResult(
      values: values,
      labels: labels,
      initialBalance: initial,
      currentBalance: current,
      delta: delta,
      percentChange: percentChange,
      isUpward: isUpward,
    );
  }
}
