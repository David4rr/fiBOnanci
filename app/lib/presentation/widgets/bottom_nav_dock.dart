import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/l10n/locale_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import 'nav_dock_animated_row.dart';
import 'nav_dock_components.dart';

export 'nav_dock_animated_row.dart';
export 'nav_dock_components.dart';

class BottomNavDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTapIndex;
  final VoidCallback? onAddAction;
  final VoidCallback? onCenterAction;
  final VoidCallback? onAddLongPress;

  const BottomNavDock({
    super.key,
    required this.currentIndex,
    required this.onTapIndex,
    this.onAddAction,
    this.onCenterAction,
    this.onAddLongPress,
  }) : assert(
          onAddAction != null || onCenterAction != null,
          'Either onAddAction or onCenterAction must be provided',
        );

  VoidCallback get _action => onAddAction ?? onCenterAction!;

  List<DockItemData> _buildNavItems(AppLocalizations l10n) => [
    DockItemData(index: 0, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: l10n.navDashboard),
    DockItemData(index: 1, icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: l10n.navSubscriptions),
    DockItemData(index: 2, icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: l10n.navWallets),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final navItems = _buildNavItems(l10n);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final effectiveBottom = bottomInset > 0 ? bottomInset : 12.0;
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: effectiveBottom),
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
                              color: AppColors.canvasCardSurface.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppColors.canvasBorder,
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
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedNavDockRow(currentIndex: currentIndex, onTapIndex: onTapIndex, items: navItems),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AddActionButton(onPressed: _action, onLongPress: onAddLongPress),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
