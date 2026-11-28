enum ReportPeriod {
  thisMonth('Bulan Ini'),
  lastMonth('Bulan Lalu'),
  threeMonths('3 Bulan'),
  allTime('Semua');

  final String label;
  const ReportPeriod(this.label);
}

enum ReportGranularity {
  week('Minggu'),
  month('Bulan'),
  quarter('Kuartal');

  final String label;
  const ReportGranularity(this.label);
}

enum ReportFlowType {
  expense('Pengeluaran'),
  income('Pemasukan'),
  all('Semua Arus');

  final String label;
  const ReportFlowType(this.label);
}

class CategorySpendItem {
  final String categoryId;
  final String name;
  final String colorHex;
  final double amount;
  final double percentage;
  final int txCount;

  const CategorySpendItem({
    required this.categoryId,
    required this.name,
    required this.colorHex,
    required this.amount,
    required this.percentage,
    required this.txCount,
  });
}

class WalletReportItem {
  final String walletId;
  final String name;
  final String colorHex;
  final double balance;
  final double income;
  final double expense;

  const WalletReportItem({
    required this.walletId,
    required this.name,
    required this.colorHex,
    required this.balance,
    required this.income,
    required this.expense,
  });
}

class FinancialReportData {
  final ReportPeriod period;
  final double totalIncome;
  final double totalExpense;
  final double netCashflow;
  final double savingsRate;
  final double dailyAverageExpense;
  final int totalTxCount;
  final double totalWalletBalance;
  final double totalPocketBalance;
  final double totalNetWorth;
  final double monthlyCommittedBills;
  final List<CategorySpendItem> expenseByCategory;
  final List<CategorySpendItem> incomeByCategory;
  final List<WalletReportItem> walletBreakdown;

  const FinancialReportData({
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashflow,
    required this.savingsRate,
    required this.dailyAverageExpense,
    required this.totalTxCount,
    required this.totalWalletBalance,
    required this.totalPocketBalance,
    required this.totalNetWorth,
    required this.monthlyCommittedBills,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.walletBreakdown,
  });
}
