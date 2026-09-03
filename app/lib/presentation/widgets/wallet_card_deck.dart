import 'dart:async';
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
  final FutureOr<void> Function(WalletEntry wallet) onSelectWallet;
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
  String? _expandedWalletId;
  Timer? _autoCloseTimer;

  void _startAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && _expandedWalletId != null) {
        setState(() {
          _expandedWalletId = null;
        });
      }
    });
  }

  void _cancelAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  @override
  void dispose() {
    _cancelAutoCloseTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(WalletCardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_expandedWalletId != null && !widget.wallets.any((w) => w.id == _expandedWalletId)) {
      _cancelAutoCloseTimer();
      _expandedWalletId = null;
    }
  }

  Future<void> _handleCardTap(WalletEntry wallet) async {
    HapticFeedback.selectionClick();
    final isBottomCard = widget.wallets.isNotEmpty && widget.wallets.last.id == wallet.id;
    if (widget.wallets.length == 1 || isBottomCard || _expandedWalletId == wallet.id) {
      // Unstacked card (single card or bottom card of deck) or second tap on already expanded card:
      // Open Detail Screen directly with Hero morph!
      _cancelAutoCloseTimer();
      final wasExpanded = _expandedWalletId == wallet.id;
      await widget.onSelectWallet(wallet);
      if (mounted && wasExpanded) {
        // Auto-close card on account detail view exit!
        setState(() {
          _expandedWalletId = null;
        });
      }
    } else {
      // First tap on a stacked card: Expand this card to full layout and start 6s auto-close timer!
      setState(() {
        _expandedWalletId = wallet.id;
      });
      _startAutoCloseTimer();
    }
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
        final cardW = constraints.maxWidth;
        final cardH = cardW * WalletCardDeck.atmRatio;
        final expandedIndex = _expandedWalletId != null
            ? wallets.indexWhere((w) => w.id == _expandedWalletId)
            : -1;

        final double baseStackH = (wallets.length - 1) * WalletCardDeck.peekHeight + cardH + 16.0;
        final double expansionShift = (cardH - WalletCardDeck.peekHeight).clamp(0.0, double.infinity);
        final double stackH = expandedIndex != -1
            ? baseStackH + expansionShift + 12.0
            : baseStackH;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: const Cubic(0.16, 1.0, 0.3, 1.0),
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

                  final isBottomCard = i == wallets.length - 1;
                  final isSingleCard = wallets.length == 1;
                  final isExpanded = isSingleCard || isBottomCard || expandedIndex == i;
                  final shouldAnimate = !isSingleCard && !isBottomCard;
                  final double topPos = (expandedIndex != -1 && i > expandedIndex)
                      ? i * WalletCardDeck.peekHeight + expansionShift + 12.0
                      : i * WalletCardDeck.peekHeight;
                  return AnimatedPositioned(
                    key: ValueKey('deck_card_${wallet.id}'),
                    duration: const Duration(milliseconds: 320),
                    curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                    top: topPos,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleCardTap(wallet),
                      child: Hero(
                        tag: 'wallet_card_${wallet.id}',
                        flightShuttleBuilder: (
                          flightContext,
                          animation,
                          flightDirection,
                          fromHeroContext,
                          toHeroContext,
                        ) {
                          final Hero toHero = toHeroContext.widget as Hero;
                          return Material(
                            color: Colors.transparent,
                            child: toHero.child,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: WalletCard(
                            wallet: wallet,
                            index: i,
                            allWallets: wallets,
                            fmt: fmt,
                            cardH: cardH,
                            isLifted: isExpanded,
                            showBottomLayout: isExpanded,
                            animate: shouldAnimate,
                          ),
                        ),
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
