import 'package:flutter/material.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../widgets/common/common_widgets.dart';

class AddWalletHeader extends StatelessWidget {
  final bool isForm;
  final VoidCallback onBack;

  const AddWalletHeader({
    super.key,
    required this.isForm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isForm ? const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)) : const SizedBox(height: 18),
          ModalHeader(
            title: isForm ? l10n.addWalletTitle : l10n.pickAppTitle,
            subtitle: isForm ? l10n.addWalletSubtitle : l10n.pickAppSubtitle,
            closeIcon: isForm ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded,
            onClose: onBack,
          ),
        ],
      ),
    );
  }
}

class AddWalletFormBody extends StatelessWidget {
  final Widget presetChips;
  final Widget formInputs;
  final Widget bindingSelector;
  final Widget actions;

  const AddWalletFormBody({
    super.key,
    required this.presetChips,
    required this.formInputs,
    required this.bindingSelector,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          presetChips,
          const SizedBox(height: 14),
          formInputs,
          const SizedBox(height: 16),
          bindingSelector,
          const SizedBox(height: 24),
          actions,
        ],
      ),
    );
  }
}
