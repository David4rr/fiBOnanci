import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/bottom_nav_dock.dart';
import '../widgets/subscription_modal.dart';
import '../widgets/quick_transaction_input_sheet.dart';
import 'dashboard_screen.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.neoMint,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.textDarkPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Notifikasi Otomatis Tercatat!\n$msg', style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bridge.startListening(widget.db, onAutoLogged: _showAutoLoggedSnackBar);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bridge.onAppResumed(widget.db, onAutoLogged: _showAutoLoggedSnackBar);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bridge.stopListening();
    super.dispose();
  }

  void _onAddAction() {
    switch (_currentIndex) {
      case 0:
        QuickTransactionInputSheet.show(context);
        break;
      case 1:
        AddSubscriptionModal.show(context);
        break;
      case 2:
        if (_walletSegment == 1) {
          WalletScreen.showAddPocketModal(context);
        } else {
          WalletScreen.showAddWalletModal(context);
        }
        break;
      default:
        QuickTransactionInputSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToWallets: () => _switchTab(2),
        onNavigateToSubscriptions: () => _switchTab(1),
      ),
      SubscriptionScreen(onAddSubscription: () => AddSubscriptionModal.show(context)),
      WalletScreen(
        initialSegment: _walletSegment,
        onSegmentChanged: (seg) => _walletSegment = seg,
      ),
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
