import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/subscription_modal.dart';

class SubscriptionCardDetailSheet {
  static void show(BuildContext context, SubscriptionEntry sub, WalletEntry wallet) {
    final now = DateTime.now();
    final isPaidThisMonth = sub.lastPaidDate != null &&
        sub.lastPaidDate!.year == now.year &&
        sub.lastPaidDate!.month == now.month;

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (modalCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: AppColors.canvasBorder, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub.title, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textWhite)),
                        const SizedBox(height: 4),
                        Text('Jatuh tempo setiap tanggal ${sub.dueDay} • ${sub.billingCycle == 'monthly' ? 'Bulanan' : 'Tahunan'}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(currencyFormatter.format(sub.cost), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.neoCoral, fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.canvasCardSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.canvasBorder)),
                child: Column(
                  children: [
                    _buildDetailRow('Rekening Pembayaran', wallet.name, Icons.account_balance_wallet_outlined),
                    const Divider(color: AppColors.canvasBorder, height: 18),
                    _buildDetailRow('Saldo Rekening Saat Ini', currencyFormatter.format(wallet.balance), Icons.account_balance_outlined),
                    const Divider(color: AppColors.canvasBorder, height: 18),
                    _buildDetailRow('Metode Pembayaran', sub.autoDeduct ? 'Auto-Deduct Aktif' : 'Manual Transfer / QRIS', Icons.sync_rounded),
                    const Divider(color: AppColors.canvasBorder, height: 18),
                    _buildDetailRow(
                      'Status Periode Ini',
                      isPaidThisMonth ? 'Sudah Lunas ✓' : 'Belum Dibayar',
                      isPaidThisMonth ? Icons.verified_rounded : Icons.pending_actions_rounded,
                      valueColor: isPaidThisMonth ? AppColors.neoMint : AppColors.neoCoral,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!isPaidThisMonth)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.textDarkPrimary),
                    label: Text('Tandai Sudah Lunas Bulan Ini', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800)),
                    onPressed: () {
                      context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(sub.id));
                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.neoMint,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          content: Text('Tagihan ${sub.title} ditandai lunas! Saldo ${wallet.name} terpotong otomatis.', style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.neoMint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.neoMint.withValues(alpha: 0.3))),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.neoMint, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Tagihan periode bulan ini telah lunas tercatat di buku kas.', style: GoogleFonts.plusJakartaSans(color: AppColors.neoMint, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textWhite),
                      label: const Text('Edit Tagihan', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(modalCtx);
                        AddSubscriptionModal.show(context, subscription: sub);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.neoCoral.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.neoCoral),
                      label: const Text('Hapus', style: TextStyle(color: AppColors.neoCoral, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(modalCtx);
                        _confirmDelete(context, sub);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.listSubtitle),
        const Spacer(),
        Text(value, style: AppTypography.listTitle.copyWith(color: valueColor ?? AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  static void _confirmDelete(BuildContext context, SubscriptionEntry sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvasCardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Tagihan?', style: AppTypography.sectionTitle),
        content: Text('Tagihan "${sub.title}" akan dihapus dari daftar monitoring komitmen bulanan.', style: AppTypography.listSubtitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoCoral, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              context.read<FinanceBloc>().add(DeleteSubscriptionEvent(sub.id));
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
