import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'pocket_transfer_dialog.dart';

IconData getPocketIcon(String type) {
  switch (type) {
    case 'savings':
      return Icons.savings_outlined;
    case 'retirement':
      return Icons.elderly_outlined;
    case 'emergency':
      return Icons.shield_outlined;
    case 'goal':
    default:
      return Icons.flag_outlined;
  }
}

String getPocketTypeLabel(String type) {
  switch (type) {
    case 'savings':
      return 'Simpanan';
    case 'retirement':
      return 'Masa Tua';
    case 'emergency':
      return 'Dana Darurat';
    case 'goal':
    default:
      return 'Target / Impian';
  }
}

class PocketDetailHeader extends StatelessWidget {
  final PocketEntry pocket;
  final Color pocketColor;
  final NumberFormat currencyFormatter;

  const PocketDetailHeader({
    super.key,
    required this.pocket,
    required this.pocketColor,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final double? target = pocket.targetAmount;
    final latestCurrent = pocket.currentAmount;
    final latestProgress = (target != null && target > 0) ? (latestCurrent / target).clamp(0.0, 1.0) : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: pocketColor.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Icon(getPocketIcon(pocket.type), color: pocketColor, size: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pocket.name, style: AppTypography.sectionTitle),
                  const SizedBox(height: 2),
                  Text(getPocketTypeLabel(pocket.type), style: TextStyle(color: pocketColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Terkumpul di Kantong', style: AppTypography.listSubtitle),
              const SizedBox(height: 6),
              Text(
                currencyFormatter.format(latestCurrent),
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textWhite, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              if (target != null && target > 0) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target: ${currencyFormatter.format(target)}', style: AppTypography.listSubtitle),
                    Text('${(latestProgress * 100).toStringAsFixed(0)}%', style: TextStyle(color: pocketColor, fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: latestProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(pocketColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PocketDetailActions extends StatelessWidget {
  final PocketEntry pocket;
  final Color pocketColor;

  const PocketDetailActions({
    super.key,
    required this.pocket,
    required this.pocketColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: pocketColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.add_rounded, color: AppColors.canvasBg, size: 20),
              label: Text('Isi Dana', style: GoogleFonts.plusJakartaSans(color: AppColors.canvasBg, fontWeight: FontWeight.w800, fontSize: 13.5)),
              onPressed: () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: true),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.canvasBorder, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.textWhite, size: 18),
              label: Text('Tarik Dana', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 13.5)),
              onPressed: pocket.currentAmount > 0 ? () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: false) : null,
            ),
          ),
        ),
      ],
    );
  }
}

void showPocketDeleteDialog(BuildContext context, PocketEntry pocket) {
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: AppColors.canvasCardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Kantong?', style: AppTypography.sectionTitle),
      content: Text('Kantong "${pocket.name}" akan dihapus. Riwayat transaksi tetap tersimpan di buku kas.', style: AppTypography.listSubtitle),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            context.read<FinanceBloc>().add(DeletePocketEvent(pocket.id));
            Navigator.of(dialogCtx).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
