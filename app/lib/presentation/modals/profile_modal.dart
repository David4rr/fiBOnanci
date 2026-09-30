import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'health/financial_health_tab.dart';
import 'profile/profile_actions.dart';
import 'profile/profile_edit_tab.dart';
import 'profile/profile_general_data_card.dart';
import 'profile/profile_card_carousel.dart';
import 'profile/profile_header_card.dart';

export 'health/financial_health_tab.dart';
export 'profile/profile_actions.dart';
export 'profile/profile_edit_tab.dart';
export 'profile/profile_card_carousel.dart';
export 'profile/profile_header_card.dart';
export 'profile/profile_menu_modal.dart';
export 'profile/profile_morphing_menu.dart';

class ProfileModal extends StatefulWidget {
  final int walletCount;
  final int txCount;

  const ProfileModal({super.key, required this.walletCount, required this.txCount});
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
        pageBuilder: (ctx, _, _) => BlocProvider.value(
          value: bloc, child: ProfileModal(walletCount: walletCount, txCount: txCount),
        ),
        transitionsBuilder: (ctx, animation, _, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.0, 0.18), end: Offset.zero).animate(curved),
            child: FadeTransition(opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved), child: child),
          );
        },
      ),
    );
  }

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  late final PageController _pageController;
  int _currentTab = 0;
  ProfileEntry? _editingProfile;
  double _dragOffset = 0.0;

  void _onHeaderDragUpdate(DragUpdateDetails details) {
    if (_currentTab != 0) return;
    final delta = details.primaryDelta ?? 0.0;
    if (delta > 0 || _dragOffset > 0) setState(() => _dragOffset = math.max(0.0, _dragOffset + delta));
  }

  void _onHeaderDragEnd(DragEndDetails details) {
    if (_currentTab != 0) return;
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity > 180.0 || _dragOffset > 60.0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffset = 0.0);
    }
  }
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToEdit(ProfileEntry? target) {
    setState(() { _editingProfile = target; _currentTab = 1; });
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }
  void _goToHealthDetails() {
    setState(() { _currentTab = 2; _editingProfile = null; });
    _pageController.animateToPage(2, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }
  void _goToSummary() {
    setState(() { _currentTab = 0; _editingProfile = null; });
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  String get _headerTitle => _currentTab == 1 ? (_editingProfile != null ? 'Edit Profil' : 'Tambah Profil Baru') : (_currentTab == 2 ? 'Audit Kesehatan Finansial' : 'Profil Pengguna');
  String get _headerSubtitle => _currentTab == 1 ? (_editingProfile != null ? 'Perbarui informasi dan identitas profil' : 'Tambah akun profil baru di perangkat') : (_currentTab == 2 ? 'Berdasarkan rasio arus kas, aset, & tagihan riil' : 'Ringkasan identitas & performa finansial');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final profile = state.profile;
        final profiles = state.profiles;

        return PopScope(
          canPop: _currentTab == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _goToSummary();
          },
          child: Scaffold(
            backgroundColor: AppColors.canvasBg,
            body: SafeArea(
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: _onHeaderDragUpdate,
                      onVerticalDragEnd: _onHeaderDragEnd,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentTab == 0)
                            const Padding(padding: EdgeInsets.only(top: 8, bottom: 4), child: Center(child: ModalGrabHandle()))
                          else
                            const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                            child: ModalHeader(
                              title: _headerTitle,
                              subtitle: _headerSubtitle,
                              closeIcon: _currentTab == 0 ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded,
                              padding: EdgeInsets.zero,
                              onClose: () => _currentTab == 0 ? Navigator.of(context).pop() : _goToSummary(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                          children: [
                            ProfileCardCarousel(
                              profiles: profiles,
                              currentProfileId: profile.id,
                              walletCount: state.wallets.length,
                              txCount: state.transactions.length,
                              onEditProfile: () => _goToEdit(profile),
                              onNewProfile: () => _goToEdit(null),
                              onHealthDetails: _goToHealthDetails,
                            ),
                            const SizedBox(height: 16),
                            ProfileGeneralDataCard(profile: profile, walletCount: state.wallets.length, txCount: state.transactions.length),
                            ProfileActions(profile: profile, profiles: profiles),
                          ],
                        ),
                        ProfileEditTab(
                          key: ValueKey(_editingProfile?.id ?? 'new_profile'),
                          initialProfile: _editingProfile,
                          onSaved: _goToSummary,
                        ),
                        FinancialHealthTab(
                          report: state.healthReport,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        );
      },
    );
  }
}
