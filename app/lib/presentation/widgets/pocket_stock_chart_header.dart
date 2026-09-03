import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PocketStockChartHeader extends StatelessWidget {
  final double displayBalance;
  final Color themeColor;
  final bool isUpward;
  final String pctFormatted;
  final String deltaFormatted;
  final int pocketsCount;
  final int? scrubbedIndex;
  final String? scrubbedLabel;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  const PocketStockChartHeader({
    super.key,
    required this.displayBalance,
    required this.themeColor,
    required this.isUpward,
    required this.pctFormatted,
    required this.deltaFormatted,
    required this.pocketsCount,
    required this.scrubbedIndex,
    required this.scrubbedLabel,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL DANA TERKUMPUL',
                style: AppTypography.badgeLabel.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 9.5,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currencyFormatter.format(displayBalance),
                style: GoogleFonts.plusJakartaSans(
                  color: themeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (scrubbedIndex != null)
                Text(
                  scrubbedLabel != null ? 'Titik: $scrubbedLabel' : 'Titik pantau',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textWhite.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUpward ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: themeColor,
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            pctFormatted,
                            style: GoogleFonts.plusJakartaSans(
                              color: themeColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$deltaFormatted ($pocketsCount kantong)',
                        style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.canvasBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onFilterChanged(filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor.withValues(alpha: 0.18) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? themeColor : AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
