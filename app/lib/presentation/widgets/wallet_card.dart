import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../theme/app_typography.dart';

const kWalletColors = [
  Color(0xFFD4F442), // neoChartreuse
  Color(0xFFFF7052), // neoCoral
  Color(0xFF26D9D9), // neoCyan
  Color(0xFF7DF24E), // neoMint
  Color(0xFFA855F7), // neoPurple
  Color(0xFFF59E0B), // amber
  Color(0xFF60A5FA), // blue
  Color(0xFFF472B6), // pink
];

Color getWalletColor(int index, String colorHex) {
  if (colorHex != '#10B981' && colorHex != '#10b981') {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}
  }
  return kWalletColors[index % kWalletColors.length];
}

/// Standalone ATM Physical Card Component.
/// showBottomLayout = false: Compact top-pinned header row for peeking stack cards.
/// showBottomLayout = true: Full physical ATM card layout with chip and bottom balance.
class WalletCard extends StatelessWidget {
  final WalletEntry wallet;
  final int index;
  final NumberFormat fmt;
  final double cardH;
  final bool isLifted;
  final bool showBottomLayout;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.index,
    required this.fmt,
    required this.cardH,
    this.isLifted = false,
    this.showBottomLayout = false,
  });

  String get _typeLabel {
    switch (wallet.type) {
      case 'ewallet': return 'E-Wallet';
      case 'cash':    return 'Kas Tunai';
      default:        return 'Bank';
    }
  }

  IconData get _typeIcon {
    switch (wallet.type) {
      case 'ewallet': return Icons.smartphone_outlined;
      case 'cash':    return Icons.payments_outlined;
      default:        return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg            = getWalletColor(index, wallet.colorHex);
    final isDark        = bg.computeLuminance() > 0.4;
    final textPrimary   = isDark ? const Color(0xFF0A0B0E) : Colors.white;
    final textSecondary = isDark ? const Color(0xFF2C303E) : Colors.white70;

    final iconBadge = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: textSecondary.withValues(alpha: 0.18),
      ),
      child: Icon(_typeIcon, color: textPrimary, size: 17),
    );

    final nameBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _typeLabel.toUpperCase(),
          style: AppTypography.badgeLabel.copyWith(
            color: textSecondary,
            fontSize: 9,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          wallet.name,
          style: AppTypography.listTitle.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final balanceBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Saldo',
          style: AppTypography.badgeLabel.copyWith(color: textSecondary, fontSize: 9),
        ),
        const SizedBox(height: 2),
        Text(
          fmt.format(wallet.balance),
          style: AppTypography.listTitle.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    // ── Top layout: icon + name + balance row pinned at VERY TOP of card ──
    final topLayout = Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconBadge,
            const SizedBox(width: 12),
            Expanded(child: nameBlock),
            const SizedBox(width: 10),
            balanceBlock,
          ],
        ),
      ),
    );

    // ── Bottom layout: full physical ATM card view ──
    final bottomLayout = Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              iconBadge,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: textSecondary.withValues(alpha: 0.18),
                ),
                child: Text(
                  _typeLabel.toUpperCase(),
                  style: AppTypography.badgeLabel.copyWith(
                    color: textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),

          // EMV Card Chip & Contactless indicator
          Row(
            children: [
              Container(
                width: 36,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: textSecondary.withValues(alpha: 0.20),
                  border: Border.all(color: textSecondary.withValues(alpha: 0.35), width: 1),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: textSecondary.withValues(alpha: 0.4), width: 0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.wifi, color: textSecondary.withValues(alpha: 0.5), size: 18),
            ],
          ),

          // Account Name & Real Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NAMA REKENING',
                      style: AppTypography.badgeLabel.copyWith(
                        color: textSecondary,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      wallet.name,
                      style: AppTypography.listTitle.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL SALDO',
                    style: AppTypography.badgeLabel.copyWith(
                      color: textSecondary,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(wallet.balance),
                    style: AppTypography.listTitle.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      height: cardH,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isLifted
            ? [
                BoxShadow(color: bg.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 12)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
              ]
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 4)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: showBottomLayout
              ? SizedBox(
                  key: const ValueKey('bottom_layout'),
                  height: cardH,
                  width: double.infinity,
                  child: bottomLayout,
                )
              : SizedBox(
                  key: const ValueKey('top_layout'),
                  height: cardH,
                  width: double.infinity,
                  child: topLayout,
                ),
        ),
      ),
    );
  }
}
