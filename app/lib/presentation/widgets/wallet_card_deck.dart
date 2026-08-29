import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'wallet_card.dart';

/// Clean tactile stacked card view with uniform peeking cards.
/// When a card is lifted, its placeholder in the deck is hidden (zero duplicate cards),
/// and the deck below never expands downwards.
class WalletCardDeck extends StatelessWidget {
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
    required this.liftedWalletId,
    required this.onSelectWallet,
  });

  @override
  Widget build(BuildContext context) {
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
        final cardH  = cardW * atmRatio;
        final stackH = (wallets.length - 1) * peekHeight + cardH + 16.0;

        return SizedBox(
          height: stackH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < wallets.length; i++) ...[
                Builder(builder: (context) {
                  final wallet = wallets[i];
                  final isLifted = liftedWalletId == wallet.id;
                  if (isLifted) {
                    return const SizedBox.shrink();
                  }

                  final double topPos = i * peekHeight;

                  return Positioned(
                    key: ValueKey('deck_card_${wallet.id}'),
                    top: topPos,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelectWallet(wallet),
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
