import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';

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

/// Service computing stock-like trend curves for Kantong Tabungan balances.
class PocketTrendService {
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
