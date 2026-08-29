import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/overlapping_deck.dart';
import '../widgets/subscription_modal.dart';

class SubscriptionScreen extends StatelessWidget {
  final AppDatabase db;
  final VoidCallback? onAddSubscription;

  const SubscriptionScreen({
    super.key,
    required this.db,
    this.onAddSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      appBar: AppBar(
        backgroundColor: AppColors.canvasBg,
        elevation: 0,
        title: Text('Tagihan & Langganan', style: AppTypography.sectionTitle),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final subscriptions = state.subscriptions;
          if (subscriptions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.canvasCardSurface,
                      ),
                      child: const Icon(Icons.receipt_long, color: AppColors.textMuted, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tagihan rutin',
                      style: AppTypography.listTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan langganan (Netflix, Spotify, Internet, Kost) agar Safe-to-Spend menghitung sisa uang amanmu secara otomatis.',
                      textAlign: TextAlign.center,
                      style: AppTypography.listSubtitle,
                    ),
                  ],
                ),
              ),
            );
          }

          double totalMonthlyBills = 0;
          for (final sub in subscriptions) {
            totalMonthlyBills += sub.cost;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.canvasCardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.canvasBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL KOMITMEN BULANAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(currencyFormatter.format(totalMonthlyBills), style: AppTypography.sectionTitle.copyWith(color: AppColors.neoCoral)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neoCoral.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${subscriptions.length} Aktif',
                        style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCoral),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('Daftar Tagihan Berulang', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),

              // Overlapping Deck View
              OverlappingDeckList(
                overlapOffset: 12,
                children: [
                  for (final sub in subscriptions)
                    OverlappingDeckItem(
                      title: sub.title,
                      category: 'JATUH TEMPO TGL ${sub.dueDay} • ${sub.billingCycle.toUpperCase()}',
                      amount: sub.cost,
                      isExpense: true,
                      categoryColor: sub.autoDeduct ? AppColors.neoChartreuse : AppColors.neoCyan,
                      iconData: Icons.subscriptions_outlined,
                      subtitle: sub.lastPaidDate != null && sub.lastPaidDate!.month == DateTime.now().month
                          ? 'Lunas Bulan Ini ✓'
                          : (sub.autoDeduct ? 'Auto-Deduct Aktif' : 'Ketuk untuk Tandai Lunas'),
                      onTap: () => _showSubscriptionDetailModal(context, sub),
                    ),
                ],
              ),
              const SizedBox(height: 140),
            ],
          );
        },
      ),
    ),
  );
}

  void _showSubscriptionDetailModal(BuildContext context, SubscriptionEntry sub) {
    final isPaidThisMonth = sub.lastPaidDate != null && sub.lastPaidDate!.month == DateTime.now().month;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(sub.title, style: AppTypography.heroGreeting),
              const SizedBox(height: 4),
              Text(
                'Biaya: Rp ${sub.cost.toStringAsFixed(0)} / bulan • Jatuh tempo tgl ${sub.dueDay}',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 24),
              if (!isPaidThisMonth) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neoChartreuse,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.textDarkPrimary),
                    label: Text(
                      'Tandai Sudah Lunas Bulan Ini',
                      style: AppTypography.listTitle.copyWith(
                        color: AppColors.textDarkPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(sub.id));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.neoMint,
                          content: Text(
                            'Tagihan ${sub.title} ditandai lunas! Saldo dompet terpotong otomatis.',
                            style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neoMint.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neoMint.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.neoMint),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tagihan ini sudah tercatat lunas untuk periode bulan ini!',
                          style: AppTypography.listTitle.copyWith(color: AppColors.neoMint),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
