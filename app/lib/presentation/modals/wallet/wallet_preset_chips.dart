import 'package:flutter/material.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletPresetChips extends StatelessWidget {
  final String? selectedPackage;
  final String? selectedType;
  final ValueChanged<BankAppPreset> onPresetSelected;
  final VoidCallback onCashSelected;

  const WalletPresetChips({
    super.key,
    required this.selectedPackage,
    required this.selectedType,
    required this.onPresetSelected,
    required this.onCashSelected,
  });

  static Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    final val = int.tryParse('FF$clean', radix: 16) ?? 0xFF10B981;
    return Color(val);
  }

  static const List<String> _kTopPackages = [
    'com.bca',
    'com.bankmandiri.livin',
    'id.co.bri.brimo',
    'id.co.bni.wondr',
    'com.bankjago.app',
    'com.seabank.id',
    'com.gojek.app',
    'id.dana',
    'ovo.id',
    'com.shopee.id',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.neoChartreuse),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'PILIH CEPAT BANK & E-WALLET',
                style: AppTypography.badgeLabel.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              ..._kTopPackages.map((pkg) {
                final preset = kPopularBankAppPresets.firstWhere((p) => p.packageName == pkg);
                final isSelected = selectedPackage != null &&
                    expandPackageAliases(preset.packageName).contains(selectedPackage);
                final color = _hexToColor(preset.colorHex);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onPresetSelected(preset),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.22) : AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : AppColors.canvasBorder,
                          width: isSelected ? 1.6 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            preset.shortName,
                            style: AppTypography.listSubtitle.copyWith(
                              color: isSelected ? AppColors.textWhite : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              _buildCashChip(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashChip() {
    final isCash = selectedType == 'cash';
    const cashColor = Color(0xFF10B981);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onCashSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCash ? cashColor.withValues(alpha: 0.22) : AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCash ? cashColor : AppColors.canvasBorder,
              width: isCash ? 1.6 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wallet_rounded, size: 13, color: cashColor),
              const SizedBox(width: 6),
              Text(
                'Kas Tunai',
                style: AppTypography.listSubtitle.copyWith(
                  color: isCash ? AppColors.textWhite : AppColors.textMuted,
                  fontWeight: isCash ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
