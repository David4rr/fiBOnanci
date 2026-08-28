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

class WalletScreen extends StatelessWidget {
  final AppDatabase db;

  const WalletScreen({super.key, required this.db});

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
        title: Text('Rekening & Dompet', style: AppTypography.sectionTitle),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          final wallets = state.wallets;

          double totalRealBalance = 0;
          for (final w in wallets) {
            totalRealBalance += w.balance;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Total Balance Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.canvasCardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.canvasBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL SALDO TERVERIFIKASI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(totalRealBalance),
                      style: AppTypography.heroGreeting.copyWith(color: AppColors.neoMint),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tersimpan di ${wallets.length} rekening bank & e-wallet offline lokal',
                      style: AppTypography.listSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Daftar Rekening Aktif', style: AppTypography.sectionTitle),
              const SizedBox(height: 12),

              // Overlapping Wallets Stack (Loaded from RAM)
              OverlappingDeckList(
                overlapOffset: 12,
                children: [
                  for (final wallet in wallets)
                    OverlappingDeckItem(
                      title: wallet.name,
                      category: wallet.type.toUpperCase(),
                      amount: wallet.balance,
                      isExpense: false,
                      categoryColor: Color(int.parse(wallet.colorHex.replaceFirst('#', '0xFF'))),
                      iconData: wallet.type == 'ewallet' ? Icons.smartphone : Icons.account_balance,
                      subtitle: 'Ketuk untuk ubah saldo',
                      onTap: () => _showEditBalanceModal(context, wallet),
                    ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  void _showEditBalanceModal(BuildContext context, WalletEntry wallet) {
    final controller = TextEditingController(text: wallet.balance.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Text('Penyesuaian Saldo: ${wallet.name}', style: AppTypography.sectionTitle),
              const SizedBox(height: 6),
              Text('Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.', style: AppTypography.listSubtitle),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.heroGreeting.copyWith(color: AppColors.neoMint),
                  filled: true,
                  fillColor: AppColors.canvasInputSearch,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neoMint,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Perbarui Saldo',
                    style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final raw = controller.text.replaceAll(RegExp(r'[^\d]'), '');
                    final newBal = double.tryParse(raw);
                    if (newBal != null) {
                      context.read<FinanceBloc>().add(
                        UpdateWalletBalanceEvent(walletId: wallet.id, newBalance: newBal),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.neoMint,
                          content: Text(
                            'Saldo ${wallet.name} diubah menjadi Rp ${newBal.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
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

  static void showAddWalletModal(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String type = 'bank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Tambah Dompet / Rekening Baru', style: AppTypography.sectionTitle),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    style: AppTypography.listTitle,
                    decoration: InputDecoration(
                      hintText: 'Nama Rekening (cth: Kas Tunai, Bank Jago Saving)',
                      hintStyle: AppTypography.listSubtitle,
                      filled: true,
                      fillColor: AppColors.canvasInputSearch,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.listTitle,
                    decoration: InputDecoration(
                      hintText: 'Saldo Awal (Rp)',
                      hintStyle: AppTypography.listSubtitle,
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: AppColors.canvasInputSearch,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypePill(
                        label: 'Bank',
                        isSelected: type == 'bank',
                        onTap: () => setModalState(() => type = 'bank'),
                      ),
                      const SizedBox(width: 8),
                      _buildTypePill(
                        label: 'E-Wallet',
                        isSelected: type == 'ewallet',
                        onTap: () => setModalState(() => type = 'ewallet'),
                      ),
                      const SizedBox(width: 8),
                      _buildTypePill(
                        label: 'Kas Tunai',
                        isSelected: type == 'cash',
                        onTap: () => setModalState(() => type = 'cash'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neoMint,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Simpan Rekening',
                        style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final raw = balanceController.text.replaceAll(RegExp(r'[^\d]'), '');
                        final bal = double.tryParse(raw) ?? 0.0;

                        if (name.isNotEmpty) {
                          context.read<FinanceBloc>().add(
                            AddWalletEvent(
                              name: name,
                              type: type,
                              initialBalance: bal,
                              colorHex: '#10B981',
                              iconName: 'wallet',
                            ),
                          );
                          Navigator.pop(modalContext);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTypePill({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neoMint : AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.badgeLabel.copyWith(
            color: isSelected ? AppColors.textDarkPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
