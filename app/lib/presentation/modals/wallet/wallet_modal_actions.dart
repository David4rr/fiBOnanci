import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletModalActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final String cancelLabel;
  final bool isSaveEnabled;

  const WalletModalActions({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.saveLabel = 'Simpan Rekening',
    this.cancelLabel = 'Batal',
    this.isSaveEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.canvasBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onCancel,
              child: Text(
                cancelLabel,
                style: AppTypography.listTitle.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaveEnabled ? AppColors.neoChartreuse : AppColors.canvasBorder,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: isSaveEnabled ? onSave : null,
              child: Text(
                saveLabel,
                style: AppTypography.listTitle.copyWith(
                  color: isSaveEnabled ? AppColors.textDarkPrimary : AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
