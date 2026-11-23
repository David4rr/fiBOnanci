import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

/// Tactile, morphing discount and promo adjustment card for subscriptions.
class SubscriptionPromoCard extends StatelessWidget {
  static const presets = [10, 20, 25, 50];

  final SubscriptionEntry subscription;
  final TextEditingController controller;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int? selectedPresetPct;
  final ValueChanged<int?> onSelectPreset;

  const SubscriptionPromoCard({
    super.key,
    required this.subscription,
    required this.controller,
    required this.isExpanded,
    required this.onToggle,
    required this.selectedPresetPct,
    required this.onSelectPreset,
  });

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder),
            ),
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final fmt = AppCurrency.of(context);
    final parsed = isExpanded ? AppCurrency.parseInputOf(context, controller.text) : subscription.cost;
    final effectiveCost = parsed > 0 ? parsed : subscription.cost;
    final diff = subscription.cost - effectiveCost;
    final hasDiscount = isExpanded && diff > 0.01;
    final savedPct = (subscription.cost > 0 && hasDiscount) ? ((diff / subscription.cost) * 100).round().clamp(1, 99) : 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? AppColors.neoChartreuse.withValues(alpha: 0.50) : AppColors.canvasBorder,
          width: isExpanded ? 1.4 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              key: const Key('sub_pay_custom_amount_toggle'),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: hasDiscount ? AppColors.neoMint.withValues(alpha: 0.16) : (isExpanded ? AppColors.neoChartreuse.withValues(alpha: 0.16) : AppColors.canvasInputSearch),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(hasDiscount ? Icons.discount_rounded : Icons.local_offer_rounded, size: 16, color: hasDiscount ? AppColors.neoMint : (isExpanded ? AppColors.neoChartreuse : AppColors.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diskon & Promo Tagihan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                          const SizedBox(height: 2),
                          if (hasDiscount)
                            Row(children: [
                              Text('Hemat ${fmt.format(diff)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neoMint)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.neoMint.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(6)),
                                child: Text('-$savedPct%', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.neoMint)),
                              ),
                            ])
                          else
                            Text('Punya voucher atau diskon bulan ini?', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isExpanded ? AppColors.canvasInputSearch : AppColors.neoChartreuse.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isExpanded ? AppColors.canvasBorder : AppColors.neoChartreuse.withValues(alpha: 0.35)),
                      ),
                      child: Text(isExpanded ? 'Tutup' : 'Pakai Promo', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: isExpanded ? AppColors.textMuted : AppColors.neoChartreuse)),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: AppColors.canvasBorder, height: 1),
                          const SizedBox(height: 12),
                          Row(children: [
                            for (final pct in presets) ...[
                              _buildChip('-$pct%', selectedPresetPct == pct, () => onSelectPreset(pct)),
                              const SizedBox(width: 6),
                            ],
                            _buildChip('Normal', selectedPresetPct == null && !hasDiscount, () => onSelectPreset(null)),
                          ]),
                          if (hasDiscount) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.canvasBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.canvasBorder)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tarif Normal: ${fmt.format(subscription.cost)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, decoration: TextDecoration.lineThrough, color: AppColors.textMuted)),
                                  Text('Bayar: ${fmt.format(effectiveCost)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neoMint, fontFeatures: const [FontFeature.tabularFigures()])),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          CurrencyAmountField(
                            controller: controller,
                            labelText: 'Nominal Bayar Bulan Ini',
                            prefixColor: hasDiscount ? AppColors.neoMint : AppColors.neoChartreuse,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
