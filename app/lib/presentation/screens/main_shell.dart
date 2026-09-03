import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_dock.dart';
import '../widgets/subscription_modal.dart';
import '../widgets/transaction_modal.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';
import 'wallet_add_options_sheet.dart';
import 'wallet_screen.dart';

export 'settings_screen.dart';
export 'wallet_add_options_sheet.dart';

class MainShell extends StatefulWidget {
  final AppDatabase db;

  const MainShell({super.key, required this.db});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _walletSegment = 0;
  bool _isWalletDetailOpen = false;
  final _bridge = NotificationBridge();

  @override
  void initState() {
    super.initState();
    _bridge.startListening(
      widget.db,
      onAutoLogged: (msg) {
        if (mounted) {
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
      },
    );
  }

  @override
  void dispose() {
    _bridge.stopListening();
    super.dispose();
  }

  void _onAddAction() {
    switch (_currentIndex) {
      case 0:
        TransactionModal.show(context);
        break;
      case 1:
        AddSubscriptionModal.show(context);
        break;
      case 2:
        if (_walletSegment == 1) {
          WalletScreen.showAddPocketModal(context);
        } else {
          WalletAddOptionsSheet.show(context);
        }
        break;
      default:
        TransactionModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToWallets: () => setState(() => _currentIndex = 2),
        onNavigateToSubscriptions: () => setState(() => _currentIndex = 1),
      ),
      SubscriptionScreen(onAddSubscription: () => AddSubscriptionModal.show(context)),
      WalletScreen(
        initialSegment: _walletSegment,
        onSegmentChanged: (seg) => _walletSegment = seg,
        onDetailViewChanged: (isOpen) => setState(() => _isWalletDetailOpen = isOpen),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      extendBody: true,
      body: screens[_currentIndex < screens.length ? _currentIndex : 0],
      bottomNavigationBar: AnimatedSlide(
        offset: _isWalletDetailOpen ? const Offset(0, 1.8) : Offset.zero,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isWalletDetailOpen ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: IgnorePointer(
            ignoring: _isWalletDetailOpen,
            child: BottomNavDock(
              currentIndex: _currentIndex,
              onTapIndex: (index) => setState(() => _currentIndex = index),
              onAddAction: _onAddAction,
            ),
          ),
        ),
      ),
    );
  }
}
