import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'app_choice_chip.dart';
import 'filter_choice.dart';
import 'primary_action_button.dart';

/// Inner panel content for the expandable search filter dropdown.
class ExpandableSearchFilterPanel extends StatelessWidget {
  final String headerTitle;
  final String primaryFilterTitle;
  final List<FilterChoice> primaryFilterChoices;
  final String tempType;
  final String? tempWalletId;
  final List<WalletEntry> wallets;
  final bool showWalletFilter;
  final bool hasPendingChange;
  final ValueChanged<String> onSelectType;
  final ValueChanged<String?> onSelectWallet;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const ExpandableSearchFilterPanel({
    super.key,
    this.headerTitle = 'Filter Transaksi',
    this.primaryFilterTitle = 'TIPE TRANSAKSI',
    this.primaryFilterChoices = kDefaultTransactionTypeChoices,
    required this.tempType,
    required this.tempWalletId,
    required this.wallets,
    required this.showWalletFilter,
    required this.hasPendingChange,
    required this.onSelectType,
    required this.onSelectWallet,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerTitle,
                style: AppTypography.listTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              if (hasPendingChange)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onReset,
                  child: Text(
                    'Reset',
                    style: AppTypography.listSubtitle.copyWith(
                      color: AppColors.neoChartreuse,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            primaryFilterTitle,
            style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in primaryFilterChoices)
                AppChoiceChip(
                  label: choice.label,
                  selected: tempType == choice.value,
                  onTap: () => onSelectType(choice.value),
                  borderRadius: 10,
                ),
            ],
          ),
          if (showWalletFilter && wallets.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'REKENING',
              style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChoiceChip(
                  label: 'Semua Rekening',
                  selected: tempWalletId == null,
                  onTap: () => onSelectWallet(null),
                  borderRadius: 10,
                ),
                for (final w in wallets)
                  AppChoiceChip(
                    label: w.name,
                    selected: tempWalletId == w.id,
                    onTap: () => onSelectWallet(w.id),
                    borderRadius: 10,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          PrimaryActionButton(
            text: 'Terapkan Filter',
            height: 40,
            borderRadius: 10,
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}
