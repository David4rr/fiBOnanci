import 'dart:ui';
import 'package:flutter/material.dart';

import 'nav_dock_animated_row.dart';
import 'nav_dock_components.dart';

export 'nav_dock_animated_row.dart';
export 'nav_dock_components.dart';
export 'pod_clipper.dart';

class BottomNavDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTapIndex;
  final VoidCallback? onAddAction;
  final VoidCallback? onCenterAction;

  const BottomNavDock({
    super.key,
    required this.currentIndex,
    required this.onTapIndex,
    this.onAddAction,
    this.onCenterAction,
  }) : assert(
          onAddAction != null || onCenterAction != null,
          'Either onAddAction or onCenterAction must be provided',
        );

  VoidCallback get _action => onAddAction ?? onCenterAction!;

  static const _navItems = [
    DockItemData(
      index: 0,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Home',
    ),
    DockItemData(
      index: 1,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Tagihan',
    ),
    DockItemData(
      index: 2,
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Wallets',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xB813141C),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0x33FFFFFF),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedNavDockRow(
                                currentIndex: currentIndex,
                                onTapIndex: onTapIndex,
                                items: _navItems,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AddActionButton(onPressed: _action),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
