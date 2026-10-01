import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class InboxWalletChip extends StatelessWidget {
  final String? walletName;
  final String? profileName;
  final VoidCallback? onSwitchWallet;

  const InboxWalletChip({
    super.key,
    this.walletName,
    this.profileName,
    this.onSwitchWallet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('inbox_switch_wallet_button'),
      behavior: HitTestBehavior.opaque,
      onTap: onSwitchWallet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: onSwitchWallet != null
                ? AppColors.neoChartreuse.withValues(alpha: 0.3)
                : AppColors.canvasBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileName != null) ...[
              Flexible(
                child: Text(
                  profileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neoChartreuse,
                  ),
                ),
              ),
              const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
            Flexible(
              child: Text(
                walletName ?? 'Pilih Dompet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            if (onSwitchWallet != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.swap_horiz_rounded, size: 12, color: AppColors.neoChartreuse),
            ],
          ],
        ),
      ),
    );
  }
}
