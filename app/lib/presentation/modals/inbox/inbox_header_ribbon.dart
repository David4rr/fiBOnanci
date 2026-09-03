import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class InboxHeaderRibbon extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onSimulate;
  final VoidCallback onRejectFirst;
  final VoidCallback onConfirmFirst;

  const InboxHeaderRibbon({
    super.key,
    required this.pendingCount,
    required this.onSimulate,
    required this.onRejectFirst,
    required this.onConfirmFirst,
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.textWhite,
                      ),
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onSimulate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neoChartreuse.withValues(alpha: 0.15)),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.neoChartreuse, size: 11),
                      ),
                      const SizedBox(width: 5),
                      Text('Simulasi', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: -0.1)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: const Center(child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 15)),
                ),
              ),
            ),
          ],
        ),
        if (pendingCount > 0)
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.025),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onRejectFirst,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, size: 13, color: AppColors.neoCoral),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text('Salah', style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11)),
                ),
                Flexible(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onConfirmFirst,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text('Benar', style: GoogleFonts.plusJakartaSans(color: AppColors.neoMint, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.neoMint),
                          ],
                        ),
                      ),
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
