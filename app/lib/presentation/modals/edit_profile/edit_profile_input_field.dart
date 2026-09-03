import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class EditProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const EditProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters != null ? List.from(inputFormatters!) : null,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 13),
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 18),
            filled: true,
            fillColor: AppColors.canvasInputSearch,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.canvasBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.canvasBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.neoChartreuse, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          ),
        ),
      ],
    );
  }
}

class EditProfileCurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const EditProfileCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    const currencies = ['IDR', 'USD', 'EUR', 'SGD'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mata Uang Utama',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 12.5),
        ),
        const SizedBox(height: 6),
        Row(
          children: currencies.map((c) {
            final isSelected = selectedCurrency == c;
            return Expanded(
              child: GestureDetector(
                onTap: () => onCurrencyChanged(c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder),
                  ),
                  child: Center(
                    child: Text(
                      c,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
