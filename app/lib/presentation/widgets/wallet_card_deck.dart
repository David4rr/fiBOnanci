import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'wallet_card.dart';

/// Clean tactile stacked card deck view with fluid spring physics and uniform peeking.
///
/// Features:
/// - Tactile card selection lift transition with spring physics and parting background cards.
/// - Dynamic elevation, scale, and tactile shadow response.
/// - Zero duplicate cards during focus transitions.
class WalletCardDeck extends StatefulWidget {
  final List<WalletEntry> wallets;
  final NumberFormat fmt;
  final String? liftedWalletId;
  final ValueChanged<WalletEntry> onSelectWallet;

  static const double atmRatio   = 53.98 / 85.60; // ≈ 0.631
  static const double peekHeight = 78.0;          // 78px per peek

  const WalletCardDeck({
    super.key,
    required this.wallets,
    required this.fmt,
    this.liftedWalletId,
    required this.onSelectWallet,
  });

  @override
  State<WalletCardDeck> createState() => _WalletCardDeckState();
}

class _WalletCardDeckState extends State<WalletCardDeck> {
  void _handleSelectCard(WalletEntry wallet) {
    HapticFeedback.selectionClick();
    widget.onSelectWallet(wallet);
  }
  @override
  Widget build(BuildContext context) {
    final wallets = widget.wallets;
    final fmt = widget.fmt;

    if (wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Center(
          child: Text(
            'Belum ada rekening. Ketuk + untuk menambahkan.',
            textAlign: TextAlign.center,
            style: AppTypography.listSubtitle,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW  = constraints.maxWidth;
        final cardH  = cardW * WalletCardDeck.atmRatio;
        final stackH = (wallets.length - 1) * WalletCardDeck.peekHeight + cardH + 16.0;

        return SizedBox(
          height: stackH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < wallets.length; i++) ...[
                Builder(builder: (context) {
                  final wallet = wallets[i];
                  final isLifted = widget.liftedWalletId == wallet.id;
                  if (isLifted) {
                    return const SizedBox.shrink();
                  }
                  final double topPos = i * WalletCardDeck.peekHeight;

                  return Positioned(
                    key: ValueKey('deck_card_${wallet.id}'),
                    top: topPos,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleSelectCard(wallet),
                      child: WalletCard(
                        wallet: wallet,
                        index: i,
                        fmt: fmt,
                        cardH: cardH,
                        isLifted: false,
                        showBottomLayout: i == wallets.length - 1,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
