import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';

void showProfileDeleteDialog(BuildContext context, ProfileEntry profile, int totalProfiles) {
  final bloc = context.read<FinanceBloc>();
  final l10n = AppL10n.of(context);
  AppConfirmationDialog.show(
    context,
    title: totalProfiles > 1 ? l10n.profileDeleteTitle : l10n.profileResetTitle,
    content: totalProfiles > 1
        ? l10n.profileDeleteMsg(profile.username)
        : l10n.profileResetMsg(profile.username),
    confirmText: totalProfiles > 1 ? l10n.txDeleteConfirm : 'Reset',
    confirmColor: const Color(0xFFEF4444),
    titleLeading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
    ),
    onConfirm: () {
      bloc.add(DeleteProfileEvent(profile.id));
      AppSnackBar.showError(
        context,
        totalProfiles > 1 ? l10n.profileDeletedTitle : l10n.profileResetDoneTitle,
        message: totalProfiles > 1 ? l10n.profileDeletedMsg(profile.username) : l10n.profileResetDoneMsg,
        tag: 'HAPUS',
      );
    },
  );
}
