import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SubscriptionDueDaySlider extends StatelessWidget {
  final int dueDay;
  final ValueChanged<int> onDayChanged;

  const SubscriptionDueDaySlider({
    super.key,
    required this.dueDay,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TANGGAL JATUH TEMPO', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            Text('Setiap Tgl $dueDay', style: AppTypography.cardMetricLabel.copyWith(color: AppColors.neoChartreuse)),
          ],
        ),
        Slider(
          value: dueDay.toDouble(),
          min: 1,
          max: 31,
          divisions: 30,
          activeColor: AppColors.neoChartreuse,
          inactiveColor: AppColors.canvasInputSearch,
          onChanged: (val) => onDayChanged(val.round()),
        ),
      ],
    );
  }
}

class SubscriptionWalletDropdown extends StatelessWidget {
  final List<WalletEntry> wallets;
  final String? selectedWalletId;
  final ValueChanged<String?> onWalletChanged;

  const SubscriptionWalletDropdown({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.onWalletChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SUMBER DANA PEMBAYARAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedWalletId,
              isExpanded: true,
              dropdownColor: AppColors.canvasCardSurface,
              style: AppTypography.listTitle,
              items: wallets.map((w) => DropdownMenuItem<String>(value: w.id, child: Text(w.name))).toList(),
              onChanged: onWalletChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class SubscriptionAutoDeductSwitch extends StatelessWidget {
  final bool autoDeduct;
  final ValueChanged<bool> onToggle;

  const SubscriptionAutoDeductSwitch({
    super.key,
    required this.autoDeduct,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto-Deduct Saldo', style: AppTypography.listTitle),
                const SizedBox(height: 2),
                Text('Potong saldo otomatis saat tgl jatuh tempo', style: AppTypography.listSubtitle, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: autoDeduct,
            activeThumbColor: AppColors.neoChartreuse,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

void showSubscriptionDeleteDialog(BuildContext context, String subscriptionId) {
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: AppColors.canvasCardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Tagihan?', style: AppTypography.sectionTitle),
      content: Text('Tagihan ini akan dihapus dari daftar monitoring komitmen bulanan.', style: AppTypography.listSubtitle),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoCoral, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            context.read<FinanceBloc>().add(DeleteSubscriptionEvent(subscriptionId));
            Navigator.pop(dialogCtx);
            Navigator.pop(context);
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
