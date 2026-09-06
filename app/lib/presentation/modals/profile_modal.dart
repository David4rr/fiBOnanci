import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'profile/profile_actions.dart';
import 'profile/profile_general_data_card.dart';
import 'profile/profile_header_card.dart';

export 'profile/profile_actions.dart';
export 'profile/profile_general_data_card.dart';
export 'profile/profile_header_card.dart';
export 'profile/profile_menu_modal.dart';

class ProfileModal extends StatefulWidget {
  final int walletCount;
  final int txCount;

  const ProfileModal({
    super.key,
    required this.walletCount,
    required this.txCount,
  });

  static void show(BuildContext context, {required int walletCount, required int txCount}) {
    final bloc = context.read<FinanceBloc>();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        barrierLabel: 'Tutup',
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, animation, secondaryAnimation) => BlocProvider.value(
          value: bloc,
          child: ProfileModal(
            walletCount: walletCount,
            txCount: txCount,
          ),
        ),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.18),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final profile = state.profile;
        final profiles = state.profiles;

        return Scaffold(
          backgroundColor: AppColors.canvasBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: Center(child: ModalGrabHandle()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: ModalHeader(
                    title: 'Profil Pengguna',
                    subtitle: 'Ringkasan identitas & performa finansial',
                    padding: EdgeInsets.zero,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                    children: [
                      ProfileHeaderCard(
                        profile: profile,
                        totalProfiles: profiles.length,
                        walletCount: widget.walletCount,
                        txCount: widget.txCount,
                      ),
                      const SizedBox(height: 16),
                      ProfileGeneralDataCard(profile: profile, walletCount: widget.walletCount, txCount: widget.txCount),
                      ProfileActions(profile: profile, profiles: profiles),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
