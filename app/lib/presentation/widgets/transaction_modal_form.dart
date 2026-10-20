import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';
import 'transaction_cross_profile_selector.dart';
import 'transaction_modal_selectors.dart';

class TransactionModalHeaderView extends StatelessWidget {
  final String type;
  final VoidCallback onClose;

  const TransactionModalHeaderView({super.key, required this.type, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
        ModalHeader(
          title: 'Catat Transaksi',
          subtitle: type == 'expense'
              ? 'Pengeluaran kas atau mutasi keluar'
              : (type == 'income' ? 'Pemasukan gaji atau dana masuk' : 'Transfer antar rekening & profil'),
          titleStyle: AppTypography.modalTitle,
          subtitleStyle: AppTypography.modalSubtitle,
          onClose: onClose,
        ),
      ],
    );
  }
}

class TransactionCategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final List<CategoryEntry> categories;
  final ValueChanged<String?> onChanged;

  const TransactionCategoryDropdown({
    super.key, required this.selectedCategoryId, required this.categories, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TransactionDropdownContainer(
      child: DropdownButton<String>(
        value: selectedCategoryId,
        isExpanded: true,
        dropdownColor: AppColors.canvasCardSurface,
        hint: Text('Pilih Kategori', style: AppTypography.listSubtitle),
        items: categories
            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: AppTypography.listTitle)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class TransactionFormInputs extends StatelessWidget {
  final String type;
  final ValueChanged<String> onTypeChanged;
  final TextEditingController amountController;
  final String? selectedWalletId;
  final List<WalletEntry> wallets;
  final ValueChanged<String?> onWalletChanged;
  final List<ProfileEntry> profiles;
  final ProfileEntry currentProfile;
  final String selectedTargetProfileId;
  final ValueChanged<String> onTargetProfileChanged;
  final String? selectedDestinationWalletId;
  final List<WalletEntry> destWallets;
  final ValueChanged<String?> onDestinationWalletChanged;
  final String? selectedCategoryId;
  final List<CategoryEntry> matchingCats;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController notesController;
  final VoidCallback onCancel, onSave;

  const TransactionFormInputs({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.amountController,
    required this.selectedWalletId,
    required this.wallets,
    required this.onWalletChanged,
    required this.profiles,
    required this.currentProfile,
    required this.selectedTargetProfileId,
    required this.onTargetProfileChanged,
    required this.selectedDestinationWalletId,
    required this.destWallets,
    required this.onDestinationWalletChanged,
    required this.selectedCategoryId,
    required this.matchingCats,
    required this.onCategoryChanged,
    required this.notesController,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionTypeToggle(selectedType: type, onTypeChanged: onTypeChanged),
        const SizedBox(height: 16),
        CurrencyAmountField(controller: amountController),
        const SizedBox(height: 12),
        TransactionDropdownContainer(
          child: DropdownButton<String>(
            value: selectedWalletId, isExpanded: true, dropdownColor: AppColors.canvasCardSurface,
            hint: Text(type == 'transfer' ? 'Pilih Rekening Asal' : 'Pilih Rekening', style: AppTypography.listSubtitle),
            items: wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: AppTypography.listTitle))).toList(),
            onChanged: onWalletChanged,
          ),
        ),
        const SizedBox(height: 12),
        if (type == 'transfer')
          TransactionTransferDestinationSelector(
            profiles: profiles, currentProfile: currentProfile,
            selectedTargetProfileId: selectedTargetProfileId,
            onTargetProfileChanged: onTargetProfileChanged,
            selectedDestinationWalletId: selectedDestinationWalletId,
            destinationWallets: destWallets,
            onDestinationWalletChanged: onDestinationWalletChanged,
          )
        else
          TransactionCategoryDropdown(
            selectedCategoryId: selectedCategoryId, categories: matchingCats, onChanged: onCategoryChanged,
          ),
        const SizedBox(height: 12),
        AppTextField(controller: notesController, hintText: 'Catatan (Opsional)'),
        const SizedBox(height: 24),
        TransactionActionFooter(onCancel: onCancel, onSave: onSave),
      ],
    );
  }
}
