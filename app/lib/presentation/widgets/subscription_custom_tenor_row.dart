import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Tactile obsidian input row for custom installment tenor (months) with steppers.
class SubscriptionCustomTenorRow extends StatelessWidget {
  final TextEditingController controller;
  final int totalCycles;
  final ValueChanged<int> onChanged;

  const SubscriptionCustomTenorRow({
    super.key,
    required this.controller,
    required this.totalCycles,
    required this.onChanged,
  });

  void _step(int delta) {
    final next = (totalCycles + delta).clamp(1, 120);
    controller.text = next.toString();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 16, color: AppColors.neoCoral),
          const SizedBox(width: 8),
          Text(
            'Durasi Tenor',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          _buildStepperButton(Icons.remove_rounded, () => _step(-1)),
          SizedBox(
            width: 48,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) {
                  onChanged(n.clamp(1, 120));
                }
              },
            ),
          ),
          _buildStepperButton(Icons.add_rounded, () => _step(1)),
          const SizedBox(width: 6),
          Text(
            'Bln',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.neoCoral,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Icon(icon, size: 15, color: AppColors.textWhite),
      ),
    );
  }
}

/// Tactile button for installment tenor presets or custom toggle.
class SubscriptionTenorPresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionTenorPresetButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neoCoral : AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.neoCoral : AppColors.canvasBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }
}
