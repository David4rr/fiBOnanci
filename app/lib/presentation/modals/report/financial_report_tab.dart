import 'package:flutter/material.dart';

import '../../../bloc/finance/finance_state.dart';
import '../../../domain/services/financial_report_service.dart';
import 'financial_report_breakdown_cards.dart';
import 'financial_report_filter_bar.dart';
import 'financial_report_summary_card.dart';

class FinancialReportTab extends StatefulWidget {
  final FinanceState state;

  const FinancialReportTab({super.key, required this.state});

  @override
  State<FinancialReportTab> createState() => _FinancialReportTabState();
}

class _FinancialReportTabState extends State<FinancialReportTab> {
  ReportFlowType _flowType = ReportFlowType.expense;
  ReportGranularity _granularity = ReportGranularity.month;
  int _periodOffset = 0;

  @override
  Widget build(BuildContext context) {
    final report = FinancialReportService.generate(
      wallets: widget.state.wallets,
      pockets: widget.state.pockets,
      categories: widget.state.categories,
      transactions: widget.state.transactions,
      subscriptions: widget.state.subscriptions,
      granularity: _granularity,
      periodOffset: _periodOffset,
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: [
        FinancialReportFilterBar(
          flowType: _flowType,
          granularity: _granularity,
          periodOffset: _periodOffset,
          onFlowTypeChanged: (t) => setState(() => _flowType = t),
          onGranularityChanged: (g) => setState(() {
            _granularity = g;
            _periodOffset = 0;
          }),
          onPeriodOffsetChanged: (offset) => setState(() => _periodOffset = offset),
        ),
        const SizedBox(height: 16),
        FinancialReportSummaryCard(
          data: report,
          flowType: _flowType,
          allTransactions: widget.state.transactions,
          wallets: widget.state.wallets,
        ),
        const SizedBox(height: 22),
        FinancialReportBreakdownCards(data: report),
      ],
    );
  }
}
