import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import 'wallet_type_selector.dart';

class WalletFormInputs extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final TextEditingController accountNumberController;
  final String symbol;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const WalletFormInputs({
    super.key,
    required this.nameController,
    required this.balanceController,
    required this.accountNumberController,
    required this.symbol,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: nameController,
          hintText: 'Nama Rekening (cth: BCA, Kas Tunai, Jago)',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: balanceController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            RupiahInputFormatter(),
          ],
          style: AppTypography.listTitle,
          decoration: InputDecoration(
            hintText: 'Saldo Awal (${symbol.trim()})',
            prefixText: symbol,
            filled: true,
            fillColor: AppColors.canvasInputSearch,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: accountNumberController,
          hintText: 'Nomor Rekening (Opsional, cth: 5410982341)',
        ),
        const SizedBox(height: 12),
        WalletTypeSelector(
          selectedType: selectedType,
          onTypeChanged: onTypeChanged,
        ),
      ],
    );
  }
}
