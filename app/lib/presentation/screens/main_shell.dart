import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../core/storage/kofi_prompt_storage.dart';
import '../../core/storage/profile_preferences_storage.dart';
import '../../core/update/app_update_service.dart';
import '../../domain/services/subscription_auto_deduct_runner.dart';
import '../../data/database/app_database.dart';
import '../modals/app_update_modal.dart';
import '../modals/kofi_support_modal.dart';
import '../modals/notification_permission_modal.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/bottom_nav_dock.dart';
import '../widgets/subscription_modal.dart';
import '../widgets/quick_transaction_input_sheet.dart';
import 'dashboard_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';
import 'wallet_screen.dart';

class MainShell extends StatefulWidget {
  final AppDatabase db;

  const MainShell({super.key, required this.db});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  double _slideDirection = 1.0;
  int _walletSegment = 0;
  bool _isOnboarding = false;
  final _bridge = NotificationBridge();

  void _switchTab(int newIndex) {
    if (newIndex == _currentIndex) return;
    setState(() {
      _slideDirection = newIndex > _currentIndex ? 1.0 : -1.0;
      _currentIndex = newIndex;
    });
  }

  void _showAutoLoggedSnackBar(String msg) {
    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Notifikasi Otomatis Tercatat!', message: msg, tag: 'OTO-LOG');
  }

  @override
  void initState() {
    super.initState();
    _isOnboarding = !ProfilePreferencesStorage.isOnboardingCompleted();
    WidgetsBinding.instance.addObserver(this);
    LocalNotificationService.instance.initialize();
    NotificationInbox.init();
    _bridge.startListening(widget.db, onAutoLogged: _showAutoLoggedSnackBar);
    SubscriptionAutoDeductRunner.runAutoDeduct(db: widget.db);
    _checkPermissionsAndUpdates();
  }

  bool _hasCheckedPermissions = false;

  Future<void> _checkPermissionsAndUpdates() async {
    if (_hasCheckedPermissions || _isOnboarding) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _hasCheckedPermissions = true;
    await KofiPromptStorage.recordAppOpen();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted || _isOnboarding) return;
    var showedBlockingModal = false;
    await LocalNotificationService.instance.requestPermissions();
    if (Platform.isAndroid && !await NotificationBridge.isPermissionGranted() && mounted) {
      showedBlockingModal = true;
      await NotificationPermissionModal.show(context);
    }
    if (!mounted) return;
    if (ProfilePreferencesStorage.getAutoUpdateCheck()) {
      try {
        final update = await AppUpdateService.checkForUpdate();
        if (update != null && update.hasUpdate && mounted) {
          showedBlockingModal = true;
          await AppUpdateModal.show(context, update);
        }
      } catch (_) {}
    }
    if (!showedBlockingModal && mounted && KofiPromptStorage.shouldShowPrompt()) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted && !_isOnboarding) await KofiSupportModal.show(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bridge.onAppResumed(widget.db, onAutoLogged: _showAutoLoggedSnackBar);
      SubscriptionAutoDeductRunner.runAutoDeduct(db: widget.db);
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bridge.stopListening();
    super.dispose();
  }

  void _onAddAction() {
    if (_currentIndex == 0) {
      QuickTransactionInputSheet.show(context);
    } else if (_currentIndex == 1) {
      AddSubscriptionModal.show(context);
    } else if (_currentIndex == 2) {
      _walletSegment == 1 ? WalletScreen.showAddPocketModal(context) : WalletScreen.showAddWalletModal(context);
    } else {
      QuickTransactionInputSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeState = context.watch<FinanceBloc>().state;
    if (_isOnboarding && (ProfilePreferencesStorage.isOnboardingCompleted() ||
        (financeState.status == FinanceStatus.success && financeState.wallets.isNotEmpty))) {
      _isOnboarding = false;
      if (!ProfilePreferencesStorage.isOnboardingCompleted()) {
        ProfilePreferencesStorage.setOnboardingCompleted(true);
      }
    }

    if (_isOnboarding) {
      return IPhoneViewportContainer(
        child: OnboardingScreen(
          onComplete: () {
            setState(() => _isOnboarding = false);
            _checkPermissionsAndUpdates();
          },
        ),
      );
    }

    final screens = [
      DashboardScreen(onNavigateToWallets: () => _switchTab(2), onNavigateToSubscriptions: () => _switchTab(1)),
      SubscriptionScreen(onAddSubscription: () => AddSubscriptionModal.show(context)),
      WalletScreen(initialSegment: _walletSegment, onSegmentChanged: (s) => _walletSegment = s),
      const SettingsScreen(),
    ];

    return IPhoneViewportContainer(
      child: AppLockGate(
        child: Scaffold(
          backgroundColor: AppColors.canvasBg,
          extendBody: true,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: SmoothPageView.defaultCurve,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey<int>(_currentIndex);
              final offset = isIncoming ? Offset(_slideDirection * 0.05, 0) : Offset(-_slideDirection * 0.05, 0);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: offset, end: Offset.zero).animate(animation),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.985, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: screens[_currentIndex < screens.length ? _currentIndex : 0],
            ),
          ),
          bottomNavigationBar: BottomNavDock(
            currentIndex: _currentIndex,
            onTapIndex: _switchTab,
            onAddAction: _onAddAction,
            onAddLongPress: () => QuickTransactionInputSheet.show(context),
          ),
        ),
      ),
    );
  }
}
