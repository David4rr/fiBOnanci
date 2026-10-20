import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'transaction_modal_selectors.dart';

class TransactionTransferDestinationSelector extends StatelessWidget {
  final List<ProfileEntry> profiles;
  final ProfileEntry currentProfile;
  final String selectedTargetProfileId;
  final ValueChanged<String> onTargetProfileChanged;
  final String? selectedDestinationWalletId;
  final List<WalletEntry> destinationWallets;
  final ValueChanged<String?> onDestinationWalletChanged;

  const TransactionTransferDestinationSelector({
    super.key,
    required this.profiles,
    required this.currentProfile,
    required this.selectedTargetProfileId,
    required this.onTargetProfileChanged,
    required this.selectedDestinationWalletId,
    required this.destinationWallets,
    required this.onDestinationWalletChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showProfilePicker = profiles.length > 1;
    final isCrossProfile = selectedTargetProfileId != currentProfile.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showProfilePicker) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  Icons.switch_account_rounded,
                  size: 13,
                  color: isCrossProfile ? AppColors.neoChartreuse : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'PROFIL TUJUAN TRANSFER',
                  style: AppTypography.cardMetricLabel.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: isCrossProfile ? AppColors.neoChartreuse : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: profiles.map((p) {
                final isSelected = p.id == selectedTargetProfileId;
                final isCurrent = p.id == currentProfile.id;
                final label = isCurrent ? '${p.username} (Profil Ini)' : p.username;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onTargetProfileChanged(p.id),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCrossProfile ? AppColors.neoChartreuse.withValues(alpha: 0.18) : AppColors.canvasInputSearch)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isCrossProfile ? AppColors.neoChartreuse : AppColors.canvasBorder)
                              : AppColors.canvasBorderSubtle,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.badgeLabel.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isCrossProfile ? AppColors.neoChartreuse : AppColors.textWhite)
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
        TransactionDropdownContainer(
          child: DropdownButton<String>(
            value: selectedDestinationWalletId,
            isExpanded: true,
            dropdownColor: AppColors.canvasCardSurface,
            hint: Text(
              isCrossProfile ? 'Pilih Rekening di Profil Tujuan' : 'Pilih Rekening Tujuan',
              style: AppTypography.listSubtitle,
            ),
            items: destinationWallets
                .map((w) => DropdownMenuItem(
                      value: w.id,
                      child: Row(
                        children: [
                          Expanded(child: Text(w.name, style: AppTypography.listTitle)),
                          if (isCrossProfile)
                            Text(
                              '• Masuk Kas',
                              style: AppTypography.listSubtitle.copyWith(fontSize: 11, color: AppColors.neoMint),
                            ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: onDestinationWalletChanged,
          ),
        ),
      ],
    );
  }
}
