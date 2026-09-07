import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import 'search_filter_chip.dart';

/// Active filter chips row rendered below the search bar when collapsed.
class ExpandableSearchActiveChips extends StatelessWidget {
  final String typeChipLabel;
  final bool hasTypeFilter;
  final String? walletFilter;
  final List<WalletEntry> wallets;
  final VoidCallback onClearType;
  final VoidCallback onClearWallet;

  const ExpandableSearchActiveChips({
    super.key,
    required this.typeChipLabel,
    required this.hasTypeFilter,
    required this.walletFilter,
    required this.wallets,
    required this.onClearType,
    required this.onClearWallet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            if (hasTypeFilter)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SearchFilterChip(
                  label: typeChipLabel,
                  onClear: onClearType,
                ),
              ),
            if (walletFilter != null)
              SearchFilterChip(
                label: 'Rek: ${wallets.firstWhere((w) => w.id == walletFilter, orElse: () => wallets.first).name}',
                onClear: onClearWallet,
              ),
          ],
        ),
      ),
    );
  }
}
