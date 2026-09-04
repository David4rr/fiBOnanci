import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import '../theme/app_typography.dart';
import 'profile/profile_actions.dart';
import 'profile/profile_general_data_card.dart';
import 'profile/profile_header_card.dart';

export 'profile/profile_actions.dart';
export 'profile/profile_general_data_card.dart';
export 'profile/profile_header_card.dart';

class ProfileModal extends StatelessWidget {
  final int walletCount;
  final int txCount;

  const ProfileModal({
    super.key,
    required this.walletCount,
    required this.txCount,
  });

  static void show(BuildContext context, {required int walletCount, required int txCount}) {
    final bloc = context.read<FinanceBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: ProfileModal(
          walletCount: walletCount,
          txCount: txCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final profile = state.profile;
        final profiles = state.profiles;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    const ModalGrabHandle(),
                    ModalHeader(
                      title: 'Profil Pengguna',
                      titleStyle: AppTypography.heroGreeting.copyWith(fontSize: 20),
                      closeIconColor: AppColors.textMuted,
                      closeIconSize: 20,
                      padding: EdgeInsets.zero,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.canvasBorder, height: 16),
              Flexible(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    ProfileHeaderCard(profile: profile, totalProfiles: profiles.length),
                    const SizedBox(height: 20),
                    ProfileGeneralDataCard(profile: profile, walletCount: walletCount, txCount: txCount),
                    ProfileActions(profile: profile, profiles: profiles),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
