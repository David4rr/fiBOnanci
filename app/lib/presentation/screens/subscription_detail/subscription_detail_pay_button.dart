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
import 'subscription_promo_card.dart';

class SubscriptionDetailPayButton extends StatefulWidget {
  final SubscriptionEntry subscription;
  final WalletEntry wallet;

  const SubscriptionDetailPayButton({super.key, required this.subscription, required this.wallet});

  @override
  State<SubscriptionDetailPayButton> createState() => _SubscriptionDetailPayButtonState();
}

class _SubscriptionDetailPayButtonState extends State<SubscriptionDetailPayButton> with SingleTickerProviderStateMixin {
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
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).maybePop();
        AppSnackBar.showWithMessenger(
          messenger,
          title: 'Tagihan ${widget.subscription.title} Lunas',
          message: 'Saldo ${widget.wallet.name} terpotong otomatis.',
          tag: 'LUNAS',
        );
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
    final target = pct == null
        ? widget.subscription.cost
        : (widget.subscription.cost * (100 - pct) / 100).roundToDouble();
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
    context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(
          widget.subscription.id,
          actualAmount: parsed > 0 ? parsed : null,
        ));
    _morphController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sub = widget.subscription;
    final isPaidThisMonth = sub.lastPaidDate != null &&
        sub.lastPaidDate!.year == now.year &&
        sub.lastPaidDate!.month == now.month;
    final totalCycles = sub.totalCycles ?? 0;
    final isCompleted = sub.status == 'completed' ||
        (sub.isInstallment && totalCycles > 0 && sub.paidCycles >= totalCycles);

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
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.neoChartreuse),
            child: const Icon(Icons.check_rounded, color: AppColors.textDarkPrimary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCompleted
                  ? 'Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai.'
                  : 'Tagihan periode bulan ini telah lunas tercatat di buku kas.',
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textWhite, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.35),
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
        final baseLabel = sub.isInstallment
            ? 'Bayar Cicilan Bulan Ini (${sub.paidCycles + 1}/${totalCycles > 0 ? totalCycles : "?"})'
            : 'Tandai Sudah Lunas Bulan Ini';
        final buttonText = (_useCustomAmount && (effectiveCost - sub.cost).abs() > 0.01)
            ? 'Bayar ${fmt.format(effectiveCost)} Bulan Ini'
            : baseLabel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubscriptionPromoCard(
              subscription: sub,
              controller: _customAmountCtrl,
              isExpanded: _useCustomAmount,
              onToggle: _toggleDiscount,
              selectedPresetPct: _selectedPresetPct,
              onSelectPreset: _applyPreset,
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
