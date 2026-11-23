import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/services/cashflow_calendar_service.dart';
import 'activity_calendar_day_cell.dart';
import 'activity_calendar_detail_peek.dart';
import 'activity_calendar_header.dart';

class ActivityCalendarMatrix extends StatefulWidget {
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;
  final List<CategoryEntry>? categories;
  final List<PocketEntry>? pockets;
  final double dailySafePace;
  final DateTime? trackingStartDate;
  final ValueChanged<TransactionEntry>? onManageTransaction;

  const ActivityCalendarMatrix({
    super.key,
    required this.allTransactions,
    required this.wallets,
    this.categories,
    this.pockets,
    this.dailySafePace = 0.0,
    this.trackingStartDate,
    this.onManageTransaction,
  });

  @override
  State<ActivityCalendarMatrix> createState() => _ActivityCalendarMatrixState();
}

class _ActivityCalendarMatrixState extends State<ActivityCalendarMatrix> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
  }

  void _prevMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _selectedDay = 1;
    });
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
      _selectedDay = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = AppCurrency.of(context);
    final report = CashflowCalendarService.calculate(
      transactions: widget.allTransactions,
      year: _selectedYear,
      month: _selectedMonth,
      dailySafePace: widget.dailySafePace,
      trackingStartDate: widget.trackingStartDate,
    );

    final firstDayOfWeek = DateTime(_selectedYear, _selectedMonth, 1).weekday; // 1 = Mon .. 7 = Sun
    final emptyOffset = firstDayOfWeek - 1;
    final daysInMonth = CashflowCalendarService.getDaysInMonth(_selectedYear, _selectedMonth);
    final totalCells = emptyOffset + daysInMonth;

    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_selectedYear, _selectedMonth));
    final activeSummary = report.dailySummaries[_selectedDay];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActivityCalendarMonthNavigator(monthLabel: monthLabel, onPrev: _prevMonth, onNext: _nextMonth),
          ActivityCalendarStreakSummaryBar(report: report),
          const SizedBox(height: 8),
          const ActivityCalendarWeekdayHeader(),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.95,
              ),
              itemCount: totalCells,
              itemBuilder: (context, idx) {
                if (idx < emptyOffset) {
                  return const SizedBox.shrink();
                }
                final dayNumber = idx - emptyOffset + 1;
                final summary = report.dailySummaries[dayNumber];
                final isToday = now.year == _selectedYear && now.month == _selectedMonth && now.day == dayNumber;
                final isSelected = _selectedDay == dayNumber;

                return ActivityCalendarDayCell(
                  dayNumber: dayNumber,
                  summary: summary,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () => setState(() => _selectedDay = dayNumber),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (activeSummary != null)
            ActivityCalendarDetailPeek(
              summary: activeSummary,
              currencyFormatter: currencyFormatter,
              wallets: widget.wallets,
              categories: widget.categories,
              pockets: widget.pockets,
              onTapTransaction: widget.onManageTransaction,
            ),
        ],
      ),
    );
  }
}
