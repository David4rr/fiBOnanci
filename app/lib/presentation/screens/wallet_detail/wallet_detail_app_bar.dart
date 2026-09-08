import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletDetailAppBar extends StatelessWidget {
  final WalletEntry wallet;
  final double headerBalanceOpacity;
  final NumberFormat currencyFormatter;
  final VoidCallback? onDismiss;
  final bool isEditing;
  final VoidCallback? onReturnToDetails;
  final String? customTitle;
  final String? customSubtitle;

  const WalletDetailAppBar({
    super.key,
    required this.wallet,
    required this.headerBalanceOpacity,
    required this.currencyFormatter,
    this.onDismiss,
    this.isEditing = false,
    this.onReturnToDetails,
    this.customTitle,
    this.customSubtitle,
  });
  @override
  Widget build(BuildContext context) {
    final title = customTitle ?? (isEditing
        ? 'Penyesuaian Saldo: ${wallet.name}'
        : 'Detail Rekening');
    final subtitle = customSubtitle ?? (isEditing
        ? 'Ubah saldo awal & preferensi rekening'
        : 'Informasi & Mutasi');
    final closeIcon = isEditing
        ? Icons.keyboard_arrow_left_rounded
        : Icons.keyboard_arrow_down_rounded;
    final onClose = isEditing
        ? (onReturnToDetails ?? onDismiss ?? () => Navigator.of(context).pop())
        : (onDismiss ?? () => Navigator.of(context).pop());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.modalTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            style: AppTypography.modalSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isEditing && headerBalanceOpacity > 0.1) ...[
                          const SizedBox(width: 8),
                          Opacity(
                            opacity: headerBalanceOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.neoChartreuse.withValues(alpha: 0.35),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                currencyFormatter.format(wallet.balance),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neoChartreuse,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const ValueKey('wallet_detail_dismiss_button'),
                onPressed: onClose,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, anim) {
                    final key = child.key is ValueKey<IconData>
                        ? (child.key as ValueKey<IconData>).value
                        : null;
                    final turnsTween = key == Icons.keyboard_arrow_left_rounded
                        ? Tween<double>(begin: -0.25, end: 0.0)
                        : (key == Icons.keyboard_arrow_down_rounded
                            ? Tween<double>(begin: 0.25, end: 0.0)
                            : Tween<double>(begin: 0.0, end: 0.0));
                    return RotationTransition(
                      turns: anim.drive(turnsTween),
                      child: FadeTransition(
                        opacity: anim,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    closeIcon,
                    key: ValueKey<IconData>(closeIcon),
                    size: 28,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
