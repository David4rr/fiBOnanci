import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

void showProfileDeleteDialog(BuildContext context, ProfileEntry profile, int totalProfiles) {
  final bloc = context.read<FinanceBloc>();
  AppConfirmationDialog.show(
    context,
    title: totalProfiles > 1 ? 'Hapus Profil?' : 'Reset Profil?',
    content: totalProfiles > 1
        ? 'Profil "${profile.username}" akan dihapus. Anda dapat beralih ke profil lain yang masih tersimpan.'
        : 'Profil "${profile.username}" adalah satu-satunya profil. Profil akan direset ke pengaturan default.',
    confirmText: totalProfiles > 1 ? 'Hapus' : 'Reset',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(totalProfiles > 1 ? 'Profil "${profile.username}" berhasil dihapus' : 'Profil berhasil direset'),
          backgroundColor: AppColors.neoCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    },
  );
}
