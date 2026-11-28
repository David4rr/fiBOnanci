import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/formatters/app_currency.dart';
import '../../core/l10n/locale_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';
import 'pocket/pocket_type_selector.dart';

export 'pocket/pocket_type_selector.dart';

class AddPocketModal {
  static void show(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();
    final currencyFormatter = AppCurrency.read(context);
    String selectedType = 'savings';
    String? selectedWalletId;
    String? nameError;
    String? initialError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final activeWallets = state.wallets.where((w) => !w.isDeleted).toList();
            selectedWalletId = activeWallets.any((w) => w.id == selectedWalletId) ? selectedWalletId : (activeWallets.isNotEmpty ? activeWallets.first.id : null);

            return StatefulBuilder(
              builder: (modalContext, setModalState) {
                final currentType = kPocketTypes.firstWhere((t) => t['id'] == selectedType, orElse: () => kPocketTypes.first);
                final Color activeColor = AppColors.fromHex(currentType['color'] as String);

                return Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
                        ModalHeader(
                          title: AppL10n.of(context).addPocketTitle,
                          subtitle: AppL10n.of(context).addPocketSubtitle,
                          onClose: () => Navigator.pop(modalContext),
                        ),
                        const SizedBox(height: 16),
                        Text(AppL10n.of(context).addPocketTypeHeader, style: AppTypography.listSubtitle),
                        const SizedBox(height: 8),
                        PocketTypeSelector(selectedType: selectedType, onSelectType: (id) => setModalState(() => selectedType = id)),
                        const SizedBox(height: 16),
                        PocketTypeSelector.buildTextField(
                          controller: nameController,
                          label: AppL10n.of(context).addPocketNameLabel,
                          hintText: AppL10n.of(context).hintPocketName,
                          errorText: nameError,
                          onChanged: (_) {
                            if (nameError != null) setModalState(() => nameError = null);
                          },
                        ),
                        const SizedBox(height: 12),
                        CurrencyAmountField(
                          controller: targetController,
                          labelText: AppL10n.of(context).addPocketTargetLabel,
                          hintText: '0',
                          prefixColor: AppColors.neoChartreuse,
                        ),
                        const SizedBox(height: 12),
                        CurrencyAmountField(
                          controller: initialController,
                          labelText: AppL10n.of(context).addPocketInitialLabel,
                          hintText: '0',
                          errorText: initialError,
                          prefixColor: AppColors.neoMint,
                          onChanged: (_) {
                            if (initialError != null) setModalState(() => initialError = null);
                          },
                        ),
                        if (activeWallets.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(AppL10n.of(context).addPocketSourceAccount, style: AppTypography.listSubtitle),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedWalletId,
                                isExpanded: true,
                                dropdownColor: AppColors.canvasCardSurface,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                                items: activeWallets.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${currencyFormatter.format(w.balance)})', style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite), overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedWalletId = val);
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(AppL10n.of(ctx).catCancelBtn, style: AppTypography.listTitle.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: activeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                                  onPressed: () {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) {
                                      setModalState(() => nameError = AppL10n.of(ctx).pocketNameRequired);
                                      return;
                                    }
                                    final target = AppCurrency.parseInputOf(context, targetController.text);
                                    final initial = AppCurrency.parseInputOf(context, initialController.text);
                                    if (initial > 0 && selectedWalletId != null && activeWallets.isNotEmpty) {
                                      final wallet = activeWallets.firstWhere((w) => w.id == selectedWalletId, orElse: () => activeWallets.first);
                                      if (initial > wallet.balance) {
                                        setModalState(() => initialError = AppL10n.of(ctx).pocketInsufficientBalance(currencyFormatter.format(wallet.balance)));
                                        return;
                                      }
                                    }
                                    context.read<FinanceBloc>().add(AddPocketEvent(
                                      name: name, type: selectedType,
                                      targetAmount: target > 0 ? target : null, initialAmount: initial,
                                      colorHex: currentType['color'] as String, iconName: 'flag',
                                      linkedWalletId: selectedWalletId,
                                    ));
                                    Navigator.pop(ctx);
                                  },
                                  child: Text(AppL10n.of(ctx).pocketCreateNow, style: GoogleFonts.plusJakartaSans(color: AppColors.canvasBg, fontWeight: FontWeight.w800, fontSize: 15)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
