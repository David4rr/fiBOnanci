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
    final targetProfile = profiles.firstWhere(
      (p) => p.id == selectedTargetProfileId,
      orElse: () => currentProfile,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showProfilePicker) ...[
          TransactionDropdownContainer(
            child: DropdownButton<String>(
              value: selectedTargetProfileId,
              isExpanded: true,
              dropdownColor: AppColors.canvasCardSurface,
              items: profiles.map((p) {
                final isCurrent = p.id == currentProfile.id;
                return DropdownMenuItem(
                  value: p.id,
                  child: Row(
                    children: [
                      Icon(
                        isCurrent ? Icons.person_rounded : Icons.swap_horiz_rounded,
                        size: 18,
                        color: isCurrent ? AppColors.neoMint : AppColors.neoChartreuse,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCurrent
                              ? 'Profil: ${p.username} (Profil Ini)'
                              : 'Profil: ${p.username} (Lintas Profil)',
                          style: AppTypography.listTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) onTargetProfileChanged(id);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        TransactionDropdownContainer(
          child: DropdownButton<String>(
            value: selectedDestinationWalletId,
            isExpanded: true,
            dropdownColor: AppColors.canvasCardSurface,
            hint: Text(
              isCrossProfile ? 'Pilih Rekening di ${targetProfile.username}' : 'Pilih Rekening Tujuan',
              style: AppTypography.listSubtitle,
            ),
            items: destinationWallets
                .map((w) => DropdownMenuItem(
                      value: w.id,
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: isCrossProfile ? AppColors.neoChartreuse : AppColors.neoCyan,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              w.name,
                              style: AppTypography.listTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
