import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class SubscriptionDetailPayButton extends StatefulWidget {
  final SubscriptionEntry subscription;
  final WalletEntry wallet;

  const SubscriptionDetailPayButton({super.key, required this.subscription, required this.wallet});

  @override
  State<SubscriptionDetailPayButton> createState() => _SubscriptionDetailPayButtonState();
}

class _SubscriptionDetailPayButtonState extends State<SubscriptionDetailPayButton> with SingleTickerProviderStateMixin {
  static const _presets = [10, 20, 25, 50];
  late final AnimationController _morphController;
  late final TextEditingController _customAmountCtrl;
  bool _isMorphed = false;
  bool _useCustomAmount = false;
  int? _selectedPresetPct;

  @override
  void initState() {
    super.initState();
    _customAmountCtrl = TextEditingController(text: AppCurrency.formatInputOf(context, widget.subscription.cost));
    _morphController = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed || !mounted) return;
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.neoMint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text('Tagihan ${widget.subscription.title} ditandai lunas! Saldo ${widget.wallet.name} terpotong otomatis.', style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold)),
        ));
      });
  }

  @override
  void dispose() {
    _customAmountCtrl.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _applyPreset(int? pct) {
    HapticFeedback.selectionClick();
    final target = pct == null ? widget.subscription.cost : (widget.subscription.cost * (100 - pct) / 100).roundToDouble();
    setState(() {
      _selectedPresetPct = pct;
      _customAmountCtrl.text = AppCurrency.formatInputOf(context, target);
    });
  }

  void _toggleDiscount() {
    HapticFeedback.selectionClick();
    setState(() {
      _useCustomAmount = !_useCustomAmount;
      if (!_useCustomAmount) {
        _selectedPresetPct = null;
        _customAmountCtrl.text = AppCurrency.formatInputOf(context, widget.subscription.cost);
      }
    });
  }

  void _handlePay() {
    if (_isMorphed) return;
    final parsed = _useCustomAmount ? AppCurrency.parseInputOf(context, _customAmountCtrl.text) : 0.0;
    setState(() => _isMorphed = true);
    HapticFeedback.mediumImpact();
    context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(widget.subscription.id, actualAmount: parsed > 0 ? parsed : null));
    _morphController.forward();
  }

  Widget _buildPresetChip(String label, bool active, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: active ? AppColors.neoChartreuse : AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? AppColors.neoChartreuse : AppColors.canvasBorder)),
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: active ? AppColors.textDarkPrimary : AppColors.textWhite)),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sub = widget.subscription;
    final isPaidThisMonth = sub.lastPaidDate != null && sub.lastPaidDate!.year == now.year && sub.lastPaidDate!.month == now.month;
    final totalCycles = sub.totalCycles ?? 0;
    final isCompleted = sub.status == 'completed' || (sub.isInstallment && totalCycles > 0 && sub.paidCycles >= totalCycles);

    if ((isPaidThisMonth || isCompleted) && !_isMorphed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.28)),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neoChartreuse),
            child: const Icon(Icons.check_rounded, color: AppColors.textDarkPrimary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCompleted ? 'Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai.' : 'Tagihan periode bulan ini telah lunas tercatat di buku kas.',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.35),
            ),
          ),
        ]),
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _customAmountCtrl,
      builder: (context, value, _) {
        final fmt = AppCurrency.of(context);
        final parsed = _useCustomAmount ? AppCurrency.parseInputOf(context, value.text) : sub.cost;
        final effectiveCost = parsed > 0 ? parsed : sub.cost;
        final diff = sub.cost - effectiveCost;
        final hasDiscount = _useCustomAmount && diff > 0.01;
        final savedPct = (sub.cost > 0 && hasDiscount) ? ((diff / sub.cost) * 100).round().clamp(1, 99) : 0;
        final baseLabel = sub.isInstallment ? 'Bayar Cicilan Bulan Ini (${sub.paidCycles + 1}/${totalCycles > 0 ? totalCycles : "?"})' : 'Tandai Sudah Lunas Bulan Ini';
        final buttonText = (_useCustomAmount && (effectiveCost - sub.cost).abs() > 0.01) ? 'Bayar ${fmt.format(effectiveCost)} Bulan Ini' : baseLabel;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.canvasCardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _useCustomAmount ? AppColors.neoChartreuse.withValues(alpha: 0.45) : AppColors.canvasBorder),
              ),
              child: Column(children: [
                GestureDetector(
                  key: const Key('sub_pay_custom_amount_toggle'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleDiscount,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Row(children: [
                      Icon(Icons.local_offer_rounded, size: 17, color: _useCustomAmount ? AppColors.neoChartreuse : AppColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Diskon / Promo Bulan Ini', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                          Text(hasDiscount ? 'Hemat ${fmt.format(diff)} (-$savedPct%) dari harga normal' : 'Sesuaikan nominal bayar tanpa ubah tarif tetap', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: hasDiscount ? AppColors.neoMint : AppColors.textMuted)),
                        ]),
                      ),
                      Text(_useCustomAmount ? 'Tutup' : 'Pakai Promo', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: _useCustomAmount ? AppColors.neoChartreuse : AppColors.textWhite)),
                    ]),
                  ),
                ),
                if (_useCustomAmount)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Divider(color: AppColors.canvasBorder, height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          for (final pct in _presets) _buildPresetChip('-$pct%', _selectedPresetPct == pct, () => _applyPreset(pct)),
                          _buildPresetChip('Normal', _selectedPresetPct == null && (effectiveCost - sub.cost).abs() < 0.01, () => _applyPreset(null)),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      CurrencyAmountField(controller: _customAmountCtrl, labelText: 'Nominal Bayar Aktual Bulan Ini'),
                    ]),
                  ),
              ]),
            ),
            PrimaryActionButton(
              text: _isMorphed ? 'Berhasil Dibayar!' : buttonText,
              icon: _isMorphed ? Icons.check_circle_rounded : Icons.check_circle_outline,
              backgroundColor: _isMorphed ? AppColors.neoMint : AppColors.neoChartreuse,
              onPressed: _handlePay,
            ),
          ],
        );
      },
    );
  }
}
