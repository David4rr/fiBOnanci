import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/smart_input/smart_input_bridge.dart';
import '../../core/smart_input/smart_transaction_parser.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';
import 'smart_input_fallback_sheet.dart';

export '../../core/smart_input/smart_transaction_parser.dart';

Future<SmartTransactionDraft?> executeSmartTransactionCapture(
  BuildContext context, {
  required SmartInputSource source,
  required List<WalletEntry> wallets,
  required List<CategoryEntry> categories,
  String? preferredWalletId,
}) async {
  String? rawText;
  if (source == SmartInputSource.voice) {
    if (SmartInputBridge.testVoiceOverride != null) {
      rawText = await SmartInputBridge.testVoiceOverride!();
    } else if (context.mounted) {
      rawText = await SmartInputFallbackSheet.show(context, source);
    }
  } else {
    final res = await SmartInputBridge.capturePhotoAndExtractText(
      fromCamera: source == SmartInputSource.camera,
    );
    if (res.canceled) return null;
    rawText = res.ocrText;
  }
  if (rawText == null || rawText.trim().isEmpty) return null;

  return SmartTransactionParser.parse(
    rawText: rawText,
    source: source,
    wallets: wallets,
    categories: categories,
    preferredWalletId: preferredWalletId,
  );
}

class TransactionTypeToggle extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildPill(String label, String value, Color activeColor) {
    final isSelected = selectedType == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTypeChanged(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.canvasBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.listTitle.copyWith(
                color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPill('Pengeluaran', 'expense', AppColors.neoCoral),
        const SizedBox(width: 8),
        _buildPill('Pemasukan', 'income', AppColors.neoMint),
        const SizedBox(width: 8),
        _buildPill('Transfer', 'transfer', AppColors.neoCyan),
      ],
    );
  }
}

class TransactionDropdownContainer extends StatelessWidget {
  final Widget child;

  const TransactionDropdownContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}

class TransactionActionFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const TransactionActionFooter({
    super.key,
    required this.onCancel,
    required this.onSave,
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
                'Batal',
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
          child: PrimaryActionButton(
            text: 'Simpan Transaksi',
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}
