import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/folder_tab_card.dart';
import '../../widgets/profile_avatar.dart';
import '../edit_profile_modal.dart';
import 'profile_card_painters.dart';
import 'profile_morphing_menu.dart';

export 'profile_delete_dialog.dart';
export 'profile_morphing_menu.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileEntry profile;
  final int totalProfiles;
  final int? walletCount, txCount;
  final VoidCallback? onEditProfile, onNewProfile, onHealthDetails;

  const ProfileHeaderCard({
    super.key, required this.profile, required this.totalProfiles,
    this.walletCount, this.txCount, this.onEditProfile, this.onNewProfile, this.onHealthDetails,
  });

  Widget _buildStat(IconData icon, String val, String unit) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: AppColors.neoChartreuse, size: 14.5), const SizedBox(width: 4), Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()]))]),
      Text(unit, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanceBloc>().state;
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onEditProfile ?? () => EditProfileModal.show(context, profile: profile),
                            child: Hero(
                              tag: 'profile_avatar_hero',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  width: 58, height: 58,
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
                                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.4),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '@${profile.username}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ProfileFinancialTimelinePill(realBalance: metrics.totalRealBalance, pendingBills: metrics.pendingBills, safeToSpend: metrics.safeToSpendMonthly),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(burnFormatted, style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w800, color: const Color(0xFFEEEEEE), letterSpacing: -0.8, fontFeatures: const [FontFeature.tabularFigures()])),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CustomPaint(size: Size(15, 14), painter: FinancialShieldPainter()),
                                    const SizedBox(height: 2),
                                    Text('Aman', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                    Text('Harian', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                                Text('$healthScore', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
                                const SizedBox(width: 2),
                                Text('SKOR', style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                              ]),
                              const SizedBox(height: 2),
                              SizedBox(width: 64, height: 24, child: CustomPaint(painter: ProfileWaveChartPainter(scores: [state.healthReport.emergencyRunway.score, state.healthReport.fixedCommitment.score, state.healthReport.savingsMargin.score, state.healthReport.spendPacing.score, healthScore.toDouble()]))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStat(Icons.account_balance_wallet_outlined, '$wallets', 'Rekening'),
                          _buildStat(Icons.swap_horiz_rounded, '$txs', 'Transaksi'),
                          _buildStat(Icons.event_repeat_rounded, '$subs', 'Tagihan Rutin'),
                        ],
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
