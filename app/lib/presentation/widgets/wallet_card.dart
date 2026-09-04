import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'modernist_card_painter.dart';
import 'wallet_card_atm_components.dart';
import 'wallet_card_rows.dart';
import 'wallet_card_theme.dart';

export 'wallet_card_atm_components.dart';
export 'wallet_card_rows.dart';
export 'wallet_card_theme.dart';

/// Standalone ATM Physical Card Component matching the Swiss-editorial modernist card design.
class WalletCard extends StatelessWidget {
  final WalletEntry wallet;
  final int index;
  final NumberFormat fmt;
  final double cardH;
  final bool isLifted;
  final bool showBottomLayout;
  final bool animate;
  final ModernistCardTheme? theme;
  final List<WalletEntry>? allWallets;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.index,
    required this.fmt,
    required this.cardH,
    this.isLifted = false,
    this.showBottomLayout = false,
    this.animate = true,
    this.theme,
    this.allWallets,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = resolveWalletTheme(
      wallet,
      index,
      allWallets: allWallets,
      explicitTheme: theme,
    );
    final config = ModernistCardConfig.forTheme(resolvedTheme);
    final badgeText = resolveWalletNetworkBadge(wallet, resolvedTheme);
    final accountNumberDisplay = WalletCardAtmComponents.formatAccountNumber(wallet);
    final isDark = config.backgroundColor.computeLuminance() < 0.35;

    final headerRow = WalletCardRows.buildHeaderRow(wallet.name, badgeText, config);
    final peekBalanceRow = WalletCardRows.buildPeekBalanceRow(wallet.balance, fmt, config);
    final chipRow = Row(children: [WalletCardAtmComponents.buildChip(config.textColor, isDark)]);
    final bottomRow = WalletCardRows.buildBottomRow(
      balance: wallet.balance,
      fmt: fmt,
      accountNumberDisplay: accountNumberDisplay,
      config: config,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      height: cardH,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.14 : 0.08),
          width: 0.9,
        ),
        boxShadow: isLifted
            ? [
                BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 26, offset: const Offset(0, 14), spreadRadius: 2),
                BoxShadow(color: config.backgroundColor.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 6)),
              ]
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 8), spreadRadius: 1),
              ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ModernistCardPainter(
                theme: resolvedTheme,
                primaryColor: config.primaryGraphicColor,
                secondaryColor: config.secondaryGraphicColor,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, right: 0, child: headerRow),
                  Positioned.fill(
                    top: 26,
                    child: () {
                      final bodyWidget = showBottomLayout
                          ? SizedBox.expand(
                              key: const ValueKey('expanded_card_body'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(flex: 3),
                                  chipRow,
                                  const Spacer(flex: 4),
                                  bottomRow,
                                ],
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('compact_card_body'),
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: peekBalanceRow,
                              ),
                            );

                      if (!animate) return bodyWidget;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: const Cubic(0.16, 1.0, 0.3, 1.0),
                        switchOutCurve: Curves.easeOut,
                        layoutBuilder: (current, prev) => Stack(alignment: Alignment.topLeft, children: [...prev, ?current]),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: CurvedAnimation(parent: animation, curve: const Interval(0.15, 1.0, curve: Curves.easeOut)),
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(
                              CurvedAnimation(parent: animation, curve: const Cubic(0.16, 1.0, 0.3, 1.0)),
                            ),
                            child: child,
                          ),
                        ),
                        child: bodyWidget,
                      );
                    }(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
