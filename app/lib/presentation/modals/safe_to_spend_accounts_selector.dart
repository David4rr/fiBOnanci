import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SafeToSpendAccountsSelector extends StatelessWidget {
  final List<WalletEntry> wallets;
  final Set<String> selectedIds;
  final bool isAll;

  const SafeToSpendAccountsSelector({
    super.key,
    required this.wallets,
    required this.selectedIds,
    required this.isAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'SUMBER REKENING PENGELUARAN',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isAll ? 'Semua (${wallets.length})' : '${selectedIds.length} Dipilih',
              style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text('Semua (${wallets.length})'),
              selected: isAll,
              selectedColor: AppColors.neoChartreuse,
              backgroundColor: AppColors.canvasInputSearch,
              labelStyle: TextStyle(
                color: isAll ? AppColors.textDarkPrimary : AppColors.textWhite,
                fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (_) {
                context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null));
              },
            ),
            for (final w in wallets) ...[
              Builder(builder: (context) {
                final isSelected = !isAll && selectedIds.contains(w.id);
                return FilterChip(
                  label: Text(w.name),
                  selected: isSelected,
                  selectedColor: AppColors.neoChartreuse,
                  backgroundColor: AppColors.canvasInputSearch,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    Set<String> newSet;
                    if (isAll) {
                      newSet = {w.id};
                    } else {
                      newSet = Set<String>.from(selectedIds);
                      if (selected) {
                        newSet.add(w.id);
                      } else {
                        newSet.remove(w.id);
                      }
                    }

                    if (newSet.isEmpty || newSet.length >= wallets.length) {
                      context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null));
                    } else {
                      context.read<FinanceBloc>().add(SetSafeToSpendWalletsEvent(newSet));
                    }
                  },
                );
              }),
            ],
          ],
        ),
      ],
    );
  }
}
