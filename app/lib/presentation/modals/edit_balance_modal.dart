import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EditBalanceModal {
  static void show(BuildContext context, WalletEntry wallet) {
    final controller = TextEditingController(
      text: RupiahInputFormatter.format(wallet.balance),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
              Text(
                'Penyesuaian Saldo: ${wallet.name}',
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: 6),
              Text(
                'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RupiahInputFormatter(),
                ],
                autofocus: false,
                style: AppTypography.heroGreeting.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.heroGreeting.copyWith(
                    color: AppColors.neoChartreuse,
                  ),
                  filled: true,
                  fillColor: AppColors.canvasInputSearch,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neoChartreuse,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Perbarui Saldo',
                    style: AppTypography.listTitle.copyWith(
                      color: AppColors.textDarkPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final newBal = RupiahInputFormatter.parse(controller.text);
                    if (newBal > 0) {
                      context.read<FinanceBloc>().add(
                        UpdateWalletBalanceEvent(
                          walletId: wallet.id,
                          newBalance: newBal,
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.neoChartreuse,
                          content: Text(
                            'Saldo ${wallet.name} diubah menjadi Rp ${RupiahInputFormatter.format(newBal)}',
                            style: const TextStyle(
                              color: AppColors.textDarkPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
