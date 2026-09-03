import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class InboxNotificationCard extends StatelessWidget {
  final String bankLabel;
  final String type;
  final double amount;
  final String counterparty;
  final String? walletName;
  final String text;
  final Color cardAccent;

  const InboxNotificationCard({
    super.key,
    required this.bankLabel,
    required this.type,
    required this.amount,
    required this.counterparty,
    this.walletName,
    required this.text,
    required this.cardAccent,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardAccent.withValues(alpha: 0.18), width: 1),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          borderRadius: BorderRadius.circular(16.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: cardAccent,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    bankLabel,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: AppColors.textWhite),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: cardAccent.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: cardAccent.withValues(alpha: 0.20), width: 1),
                                  ),
                                  child: Text(
                                    isIncome ? 'MASUK' : 'KELUAR',
                                    style: GoogleFonts.plusJakartaSans(color: cardAccent, fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (amount > 0)
                            Text(
                              isIncome ? '+Rp ${amount.toStringAsFixed(0)}' : '-Rp ${amount.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                color: isIncome ? AppColors.neoMint : AppColors.neoCoral,
                              ),
                            ),
                        ],
                      ),
                      if (walletName != null || counterparty.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              if (counterparty.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    counterparty,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textWhite.withValues(alpha: 0.85)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (counterparty.isNotEmpty && walletName != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('•', style: TextStyle(fontSize: 10, color: AppColors.textSubtle.withValues(alpha: 0.8))),
                                ),
                              if (walletName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(4)),
                                  child: Text(walletName!, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                                ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          text,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w400, color: AppColors.textSubtle, height: 1.35),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
