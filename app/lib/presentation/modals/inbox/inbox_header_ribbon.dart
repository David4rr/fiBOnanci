import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class InboxHeaderRibbon extends StatelessWidget {
  final int pendingCount;

  const InboxHeaderRibbon({
    super.key,
    required this.pendingCount,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Kotak Masuk Notifikasi',
                      style: AppTypography.modalTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.neoChartreuse, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(
                            '$pendingCount',
                            style: GoogleFonts.plusJakartaSans(color: AppColors.neoChartreuse, fontWeight: FontWeight.w800, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 28,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
        if (pendingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              'Geser kanan untuk terima, kiri untuk tolak',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }
}
