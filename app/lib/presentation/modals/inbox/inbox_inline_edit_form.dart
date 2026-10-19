import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/app_currency.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class InboxInlineEditForm extends StatefulWidget {
  final double initialAmount;
  final String initialType;
  final String initialCounterparty;
  final String? walletName;
  final ValueChanged<Map<String, dynamic>> onSave;
  final VoidCallback onCancel;

  const InboxInlineEditForm({
    super.key,
    required this.initialAmount,
    required this.initialType,
    required this.initialCounterparty,
    this.walletName,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<InboxInlineEditForm> createState() => _InboxInlineEditFormState();
}

class _InboxInlineEditFormState extends State<InboxInlineEditForm> {
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String _type;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _amountController = TextEditingController(
      text: widget.initialAmount > 0 ? widget.initialAmount.toInt().toString() : '',
    );
    _notesController = TextEditingController(text: widget.initialCounterparty);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final rawAmt = AppCurrency.parseInputOf(context, _amountController.text);
    if (rawAmt <= 0) return;
    widget.onSave({
      'amount': rawAmt,
      'type': _type,
      'counterparty': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'income';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModalHeader(
          title: 'Sesuaikan Transaksi',
          subtitle: widget.walletName != null ? 'Rekening: ${widget.walletName}' : 'Ubah nominal & tipe transaksi',
          closeIcon: Icons.keyboard_arrow_left_rounded,
          onClose: widget.onCancel,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                label: 'Pengeluaran',
                isSelected: !isIncome,
                activeColor: AppColors.neoCoral,
                onTap: () => setState(() => _type = 'expense'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTypeButton(
                label: 'Pemasukan',
                isSelected: isIncome,
                activeColor: AppColors.neoMint,
                onTap: () => setState(() => _type = 'income'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'NOMINAL TRANSAKSI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        CurrencyAmountField(
          controller: _amountController,
          prefixColor: isIncome ? AppColors.neoMint : AppColors.neoCoral,
          hintText: '0',
        ),
        const SizedBox(height: 14),
        Text(
          'MERCHANT / PENERIMA / CATATAN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        AppTextField(
          controller: _notesController,
          hintText: 'Contoh: Kopi Kenangan, Transfer Budi',
        ),
        const SizedBox(height: 18),
        PrimaryActionButton(
          text: 'Simpan Perubahan',
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.canvasBorder,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? activeColor : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
