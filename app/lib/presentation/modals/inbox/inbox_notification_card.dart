import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../theme/app_colors.dart';
import 'inbox_wallet_chip.dart';

class InboxNotificationCard extends StatelessWidget {
  final String bankLabel;
  final String type;
  final double amount;
  final String counterparty;
  final String? walletName;
  final String? profileName;
  final VoidCallback? onSwitchWallet;
  final String text;
  final Color cardAccent;
  final int currentIndex;
  final int totalCount;
  final bool isTopCard;

  const InboxNotificationCard({
    super.key,
    required this.bankLabel,
    required this.type,
    required this.amount,
    required this.counterparty,
    this.walletName,
    this.profileName,
    this.onSwitchWallet,
    required this.text,
    required this.cardAccent,
    this.currentIndex = 0,
    this.totalCount = 1,
    this.isTopCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    final formattedAmount = RupiahInputFormatter.format(amount);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopCard ? AppColors.canvasBorder : Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
        boxShadow: isTopCard
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bankLabel.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isIncome ? AppColors.neoMint : AppColors.textSubtle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 165),
                child: InboxWalletChip(
                  walletName: walletName,
                  profileName: profileName,
                  onSwitchWallet: onSwitchWallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (amount > 0)
            Text(
              isIncome ? '+Rp $formattedAmount' : '-Rp $formattedAmount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isIncome ? AppColors.neoMint : AppColors.textWhite,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            counterparty.isNotEmpty ? counterparty : (isIncome ? 'Pemasukan' : 'Pengeluaran'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSubtle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Container(
            height: 0.5,
            color: Colors.white.withValues(alpha: 0.07),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
