import 'package:flutter/material.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletBindingSelector extends StatelessWidget {
  final String? selectedPackage;
  final bool isCustomPackage;
  final TextEditingController customPackageController;
  final void Function(String? package, bool isCustom) onPackageChanged;

  const WalletBindingSelector({
    super.key,
    required this.selectedPackage,
    required this.isCustomPackage,
    required this.customPackageController,
    required this.onPackageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hubungkan Notifikasi Aplikasi (Opsional)',
          style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: isCustomPackage ? '__custom__' : selectedPackage,
              isExpanded: true,
              dropdownColor: AppColors.canvasCardSurface,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              style: AppTypography.listTitle,
              hint: Text('Tidak Terhubung (Input Manual)', style: AppTypography.listSubtitle),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tidak Terhubung (Input Manual)', style: AppTypography.listSubtitle),
                ),
                ...kPopularBankAppPresets.map((p) => DropdownMenuItem<String?>(
                  value: p.packageName,
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.neoChartreuse),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${p.name} (${p.packageName})',
                          style: AppTypography.listTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
                const DropdownMenuItem<String?>(
                  value: '__custom__',
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, size: 18, color: AppColors.neoCyan),
                      SizedBox(width: 8),
                      Text('Input Package Name Lainnya...', style: TextStyle(color: AppColors.neoCyan)),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val == '__custom__') {
                  onPackageChanged(null, true);
                } else {
                  onPackageChanged(val, false);
                }
              },
            ),
          ),
        ),
        if (isCustomPackage) ...[
          const SizedBox(height: 8),
          TextField(
            controller: customPackageController,
            style: AppTypography.listTitle,
            decoration: InputDecoration(
              hintText: 'Package Name (contoh: id.krom.bank)',
              hintStyle: AppTypography.listSubtitle,
              filled: true,
              fillColor: AppColors.canvasInputSearch,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ],
    );
  }
}
