import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'installed_app_picker_modal.dart';
class WalletBindingSelector extends StatelessWidget {
  final String? selectedPackage;
  final bool isCustomPackage;
  final TextEditingController customPackageController;
  final void Function(String? package, bool isCustom) onPackageChanged;
  final VoidCallback? onOpenAppPicker;

  const WalletBindingSelector({
    super.key,
    required this.selectedPackage,
    required this.isCustomPackage,
    required this.customPackageController,
    required this.onPackageChanged,
    this.onOpenAppPicker,
  });

  Future<void> _openPicker(BuildContext context) async {
    if (onOpenAppPicker != null) {
      onOpenAppPicker!();
      return;
    }
    final picked = await InstalledAppPickerModal.show(context);
    if (picked != null) {
      customPackageController.text = picked;
      onPackageChanged(picked, true);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Hubungkan Notifikasi Aplikasi (Opsional)',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openPicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded, size: 14, color: AppColors.neoCyan),
                    const SizedBox(width: 4),
                    Text(
                      'Cari App',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neoCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                      Expanded(
                        child: Text(
                          'Cari / Input Package Lain...',
                          style: TextStyle(color: AppColors.neoCyan),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
              suffixIcon: IconButton(
                icon: const Icon(Icons.apps_rounded, size: 18, color: AppColors.neoCyan),
                tooltip: 'Pilih dari Aplikasi Terpasang',
                onPressed: () => _openPicker(context),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ],
    );
  }
}
