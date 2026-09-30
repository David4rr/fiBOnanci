import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class PocketTransferForm extends StatefulWidget {
  final PocketEntry pocket;
  final bool isDeposit;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const PocketTransferForm({
    super.key,
    required this.pocket,
    required this.isDeposit,
    required this.onSuccess,
    this.onCancel,
  });

  @override
  State<PocketTransferForm> createState() => _PocketTransferFormState();
}

class _PocketTransferFormState extends State<PocketTransferForm> {
  final _amountController = TextEditingController();
  final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String? _selectedWalletId;
  String? _errorMessage;
  @override
  void didUpdateWidget(PocketTransferForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDeposit != widget.isDeposit || oldWidget.pocket.id != widget.pocket.id) {
      _amountController.clear();
      _errorMessage = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final activeWallets = state.wallets.where((w) => !w.isDeleted).toList();
        final linked = widget.pocket.linkedWalletId;
        final defaultId = (linked != null && activeWallets.any((w) => w.id == linked))
            ? linked
            : (activeWallets.isNotEmpty ? activeWallets.first.id : null);
        _selectedWalletId = activeWallets.any((w) => w.id == _selectedWalletId) ? _selectedWalletId : defaultId;
        final actionColor = widget.isDeposit ? AppColors.neoMint : AppColors.neoCoral;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeWallets.isNotEmpty) ...[
              Text(widget.isDeposit ? 'Rekening Sumber' : 'Rekening Tujuan', style: AppTypography.listSubtitle),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.canvasBorder)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWalletId,
                    isExpanded: true,
                    dropdownColor: AppColors.canvasCardSurface,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                    items: activeWallets.map((w) => DropdownMenuItem<String>(
                      value: w.id,
                      child: Text('${w.name} (${_currencyFormatter.format(w.balance)})', style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() { _selectedWalletId = val; _errorMessage = null; });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.neoCoral.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Text('Belum ada rekening aktif untuk transaksi.', style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontSize: 12)),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.isDeposit ? 'Nominal Setoran' : 'Nominal Penarikan', style: AppTypography.listSubtitle),
                if (!widget.isDeposit)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _amountController.text = RupiahInputFormatter.format(widget.pocket.currentAmount);
                      if (_errorMessage != null) setState(() => _errorMessage = null);
                    },
                    child: Text(
                      'Tarik Semua (${_currencyFormatter.format(widget.pocket.currentAmount)})',
                      style: GoogleFonts.plusJakartaSans(color: actionColor, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  Text(
                    'Saldo: ${_currencyFormatter.format(widget.pocket.currentAmount)}',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            CurrencyAmountField(
              controller: _amountController,
              labelText: 'Nominal',
              prefixColor: actionColor,
              hintText: '0',
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.neoCoral.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.neoCoral, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_errorMessage!, style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryActionButton(
              text: 'Konfirmasi',
              backgroundColor: actionColor,
              foregroundColor: AppColors.canvasBg,
              onPressed: activeWallets.isEmpty
                  ? null
                  : () {
                      final amount = RupiahInputFormatter.parse(_amountController.text);
                      if (amount <= 0) return setState(() => _errorMessage = 'Masukkan nominal lebih dari Rp 0');
                      if (_selectedWalletId == null) return setState(() => _errorMessage = 'Pilih rekening terlebih dahulu');
                      final selectedWallet = activeWallets.firstWhere((w) => w.id == _selectedWalletId);
                      if (widget.isDeposit && amount > selectedWallet.balance) {
                        return setState(() => _errorMessage = 'Saldo ${selectedWallet.name} tidak cukup (${_currencyFormatter.format(selectedWallet.balance)})');
                      }
                      if (!widget.isDeposit && amount > widget.pocket.currentAmount) {
                        return setState(() => _errorMessage = 'Saldo kantong tidak cukup (${_currencyFormatter.format(widget.pocket.currentAmount)})');
                      }
                      context.read<FinanceBloc>().add(TransferPocketFundsEvent(
                        pocketId: widget.pocket.id,
                        walletId: _selectedWalletId!,
                        amount: amount,
                        isDepositToPocket: widget.isDeposit,
                      ));
                      _amountController.clear();
                      _errorMessage = null;
                      widget.onSuccess();
                    },
            ),
          ],
        );
      },
    );
  }
}
