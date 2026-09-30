import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/folder_tab_card.dart';
import '../../widgets/profile_avatar.dart';
import '../edit_profile_modal.dart';
import 'profile_active_card_body.dart';
import 'profile_inactive_card_body.dart';
import 'profile_morphing_menu.dart';

export 'profile_active_card_body.dart';
export 'profile_card_carousel.dart';
export 'profile_delete_dialog.dart';
export 'profile_inactive_card_body.dart';
export 'profile_morphing_menu.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileEntry profile;
  final int totalProfiles;
  final int? walletCount, txCount;
  final VoidCallback? onEditProfile, onNewProfile, onHealthDetails;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.totalProfiles,
    this.walletCount,
    this.txCount,
    this.onEditProfile,
    this.onNewProfile,
    this.onHealthDetails,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanceBloc>().state;
    final isActive = profile.id == state.profile.id;
    final metrics = state.metrics;
    final healthScore = state.healthReport.overallScore;
    final wallets = walletCount ?? state.wallets.length;
    final txs = txCount ?? state.transactions.length;
    final subs = state.subscriptions.length;
    final burnFormatted = NumberFormat('#,###', 'id_ID').format(metrics.safeToSpendDaily.toInt());

    const clipper = FolderTabClipper(tabWidthFactor: 0.58, cornerRadius: 24.0, stepDepth: 18.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final tabW = w * 0.58;
        final dotCenterX = (tabW + 24.0) + ((w - 24.0) - (tabW + 24.0)) * 0.44;
        final rightOffset = (w - dotCenterX - 22.0).clamp(16.0, w);
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: CustomPaint(
                foregroundPainter: const FolderTabBorderPainter(
                  clipper: clipper,
                  borderColor: Color(0xFF2E3244),
                  borderWidth: 1.2,
                ),
                child: ClipPath(
                  clipper: clipper,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.carbonBlack,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onEditProfile ?? () => EditProfileModal.show(context, profile: profile),
                              child: Hero(
                                tag: 'profile_avatar_hero_${profile.id}',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1E212D),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.5),
                                    ),
                                    child: Center(
                                      child: ProfileAvatar(avatarPath: profile.avatarPath, name: profile.username, size: 50, iconSize: 26),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.4,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(profile.email?.isNotEmpty == true ? profile.email! : '—', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 1),
                                  Text('@${profile.username}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isActive)
                          ProfileActiveCardBody(
                            metrics: metrics,
                            healthReport: state.healthReport,
                            wallets: wallets,
                            txs: txs,
                            subs: subs,
                            burnFormatted: burnFormatted,
                            healthScore: healthScore,
                            onHealthDetails: onHealthDetails,
                          )
                        else
                          ProfileInactiveCardBody(
                            profile: profile,
                            onActivate: () => context.read<FinanceBloc>().add(SetActiveProfileEvent(profile.id)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: rightOffset,
              child: ProfileMorphingMenu(
                profile: profile,
                totalProfiles: totalProfiles,
                onEditProfile: onEditProfile,
                onNewProfile: onNewProfile,
                onHealthDetails: onHealthDetails,
              ),
            ),
          ],
        );
      },
    );
  }
}
