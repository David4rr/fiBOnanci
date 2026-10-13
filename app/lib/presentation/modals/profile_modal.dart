import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'health/financial_health_tab.dart';
import 'profile/profile_edit_tab.dart';
import 'profile/profile_general_data_card.dart';
import 'profile/profile_card_carousel.dart';
import 'profile/profile_header_card.dart';
import 'report/financial_report_tab.dart';
import 'settings/profile_settings_tab.dart';

export 'health/financial_health_tab.dart';
export 'profile/profile_edit_tab.dart';
export 'profile/profile_card_carousel.dart';
export 'profile/profile_header_card.dart';
export 'profile/profile_menu_modal.dart';
export 'profile/profile_morphing_menu.dart';
export 'report/financial_report_tab.dart';
export 'settings/profile_settings_tab.dart';
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
  int _currentTab = 0, _subTab = 4;
  ProfileEntry? _editingProfile;
  SettingsSubRoute? _settingsRoute;
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

  void _goToTab(int tab, [ProfileEntry? target]) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (tab != 0) { _subTab = tab; _editingProfile = target; _settingsRoute = null; }
      _currentTab = tab;
    });
    SmoothPageView.animateTo(_pageController, tab == 0 ? 0 : 1);
  }
  void _goToSummary() => _goToTab(0);

  void _handleBack() {
    if (_currentTab == 4 && _settingsRoute != null) {
      setState(() => _settingsRoute = null);
    } else if (_currentTab != 0) {
      _goToSummary();
    } else {
      Navigator.of(context).pop();
    }
  }

  String get _headerTitle => switch (_currentTab) {
    1 => _editingProfile != null ? 'Edit Profil' : 'Tambah Profil Baru',
    2 => 'Audit Kesehatan Finansial',
    3 => 'Laporan Keuangan',
    4 => _settingsRoute?.title ?? 'Pengaturan',
    _ => 'Profil Pengguna',
  };
  String get _headerSubtitle => switch (_currentTab) {
    1 => _editingProfile != null ? 'Perbarui informasi dan identitas profil' : 'Tambah akun profil baru di perangkat',
    2 => 'Berdasarkan rasio arus kas, aset, & tagihan riil',
    3 => 'Analisis arus kas, kategori, & distribusi rekening',
    4 => _settingsRoute?.subtitle ?? 'Preferensi finansial, kategori, otomasi, & data lokal',
    _ => 'Ringkasan identitas & performa finansial',
  };
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final profile = state.profile;
        final profiles = state.profiles.isNotEmpty ? state.profiles : [profile];

        return PopScope(
          canPop: _currentTab == 0,
          onPopInvokedWithResult: (didPop, _) { if (!didPop) _handleBack(); },
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
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        _currentTab == 0
                            ? const Padding(padding: EdgeInsets.only(top: 8, bottom: 4), child: Center(child: ModalGrabHandle()))
                            : const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                          child: ModalHeader(
                            title: _headerTitle, subtitle: _headerSubtitle, padding: EdgeInsets.zero,
                            closeIcon: _currentTab == 0 ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded,
                            onClose: _handleBack,
                          ),
                        ),
                      ]),
                    ),
                  Expanded(
                    child: SmoothPageView(
                      controller: _pageController,
                      children: [
                        ListView(
                          physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                          children: [
                              ProfileCardCarousel(
                                profiles: profiles, currentProfileId: profile.id, walletCount: state.wallets.length, txCount: state.transactions.length,
                                onEditProfile: () => _goToTab(1, profile), onNewProfile: () => _goToTab(1),
                                onHealthDetails: () => _goToTab(2), onFinancialReport: () => _goToTab(3), onSettings: () => _goToTab(4),
                              ),
                              const SizedBox(height: 16),
                              ProfileGeneralDataCard(profile: profile, walletCount: state.wallets.length, txCount: state.transactions.length),
                          ],
                        ),
                        switch (_subTab) {
                          1 => ProfileEditTab(key: ValueKey(_editingProfile?.id ?? 'new_profile'), initialProfile: _editingProfile, onSaved: _goToSummary),
                          2 => FinancialHealthTab(report: state.healthReport),
                            3 => FinancialReportTab(state: state),
                            _ => ProfileSettingsTab(state: state, activeRoute: _settingsRoute, onNavigate: (route) => setState(() => _settingsRoute = route)),
                        },
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
