import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TransactionDetailComponents {
  static Widget buildWalletDropdown({
    required List<WalletEntry> wallets,
    required String? selectedId,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.6), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          dropdownColor: AppColors.canvasCardSurface,
          style: AppTypography.listTitle,
          items: wallets.map((w) {
            return DropdownMenuItem<String>(
              value: w.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(int.parse(w.colorHex.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(w.balance),
                    style: AppTypography.listSubtitle,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  static Widget buildActionButtons({
    required BuildContext context,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppTypography.listTitle.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              onPressed: onSave,
              child: Text('Simpan Perubahan', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }

  static void showDeleteDialog(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.canvasCardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Transaksi?', style: AppTypography.sectionTitle),
        content: Text('Transaksi ini akan dihapus permanen dan saldo dompet akan dikembalikan.', style: AppTypography.listSubtitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoCoral, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              context.read<FinanceBloc>().add(DeleteTransactionEvent(transactionId));
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.neoCoral,
                  content: Text('Transaksi dihapus & saldo dompet dikembalikan semula!', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
