import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'health/financial_health_tab.dart';

export 'health/financial_health_pillar_card.dart';
export 'health/financial_health_score_card.dart';
export 'health/financial_health_tab.dart';

class FinancialHealthModal {
  static void show(BuildContext context) {
    final bloc = context.read<FinanceBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final report = state.healthReport;

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              expand: false,
              builder: (sheetContext, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.canvasBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      const ModalGrabHandle(width: 44, padding: EdgeInsets.only(top: 16, bottom: 8)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: ModalHeader(
                          title: 'Audit Kesehatan Finansial',
                          subtitle: 'Berdasarkan rasio arus kas, aset, & tagihan riil',
                          padding: EdgeInsets.zero,
                          onClose: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      Expanded(
                        child: FinancialHealthTab(
                          report: report,
                          scrollController: scrollController,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
