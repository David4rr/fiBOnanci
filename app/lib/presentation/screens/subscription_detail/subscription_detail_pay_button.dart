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

  const SubscriptionDetailPayButton({
    super.key,
    required this.subscription,
    required this.wallet,
  });

  @override
  State<SubscriptionDetailPayButton> createState() => _SubscriptionDetailPayButtonState();
}

class _SubscriptionDetailPayButtonState extends State<SubscriptionDetailPayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _morphController;
  late final TextEditingController _customAmountCtrl;
  bool _isMorphed = false;
  bool _useCustomAmount = false;

  @override
  void initState() {
    super.initState();
    _customAmountCtrl = TextEditingController(
      text: AppCurrency.formatInputOf(context, widget.subscription.cost),
    );
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).maybePop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.neoMint,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              content: Text(
                'Tagihan ${widget.subscription.title} ditandai lunas! Saldo ${widget.wallet.name} terpotong otomatis.',
                style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      });
  }

  @override
  void dispose() {
    _customAmountCtrl.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _handlePay() {
    if (_isMorphed) return;
    double? customAmount;
    if (_useCustomAmount) {
      final parsed = AppCurrency.parseInputOf(context, _customAmountCtrl.text);
      if (parsed > 0) customAmount = parsed;
    }
    setState(() => _isMorphed = true);
    HapticFeedback.mediumImpact();
    context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(widget.subscription.id, actualAmount: customAmount));
    _morphController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPaidThisMonth = widget.subscription.lastPaidDate != null &&
        widget.subscription.lastPaidDate!.year == now.year &&
        widget.subscription.lastPaidDate!.month == now.month;
    final isInstallment = widget.subscription.isInstallment;
    final totalCycles = widget.subscription.totalCycles ?? 0;
    final isCompleted = widget.subscription.status == 'completed' ||
        (isInstallment && totalCycles > 0 && widget.subscription.paidCycles >= totalCycles);

    if ((isPaidThisMonth || isCompleted) && !_isMorphed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neoMint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neoMint.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.neoMint, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCompleted
                    ? 'Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai.'
                    : 'Tagihan periode bulan ini telah lunas tercatat di buku kas.',
                style: GoogleFonts.plusJakartaSans(color: AppColors.neoMint, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final buttonText = isInstallment
        ? 'Bayar Cicilan Bulan Ini (${widget.subscription.paidCycles + 1}/${totalCycles > 0 ? totalCycles : "?"})'
        : 'Tandai Sudah Lunas Bulan Ini';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: const Key('sub_pay_custom_amount_toggle'),
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _useCustomAmount = !_useCustomAmount),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(_useCustomAmount ? Icons.check_box_rounded : Icons.discount_outlined, size: 15, color: AppColors.neoChartreuse),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ada diskon / potongan bulan ini? Sesuaikan nominal bayar',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neoChartreuse),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_useCustomAmount) ...[
          CurrencyAmountField(
            controller: _customAmountCtrl,
            labelText: 'Nominal Bayar Aktual Bulan Ini (Harga normal tetap terjaga)',
          ),
          const SizedBox(height: 12),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _isMorphed ? AppColors.neoMint : AppColors.neoChartreuse,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handlePay,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isMorphed ? Icons.check_circle_rounded : Icons.check_circle_outline, color: AppColors.textDarkPrimary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _isMorphed ? 'Berhasil Dibayar!' : buttonText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
