import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import 'wallet_card.dart';
import 'common/common_widgets.dart';

/// Clean tactile stacked card deck view with fluid spring physics and uniform peeking.
class WalletCardDeck extends StatefulWidget {
  final List<WalletEntry> wallets;
  final NumberFormat fmt;
  final String? liftedWalletId;
  final FutureOr<void> Function(WalletEntry wallet) onSelectWallet;
  static const double atmRatio = 53.98 / 85.60;
  static const double peekHeight = 78.0;

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
        setState(() => _expandedWalletId = null);
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
    final isCurrentlyExpanded = _expandedWalletId == wallet.id || (_expandedWalletId == null && isBottomCard);
    if (widget.wallets.length == 1 || isCurrentlyExpanded) {
      _cancelAutoCloseTimer();
      final wasUpperExpanded = _expandedWalletId == wallet.id;
      await widget.onSelectWallet(wallet);
      if (mounted && wasUpperExpanded) {
        setState(() => _expandedWalletId = null);
      }
    } else if (isBottomCard) {
      _cancelAutoCloseTimer();
      setState(() => _expandedWalletId = null);
    } else {
      setState(() => _expandedWalletId = wallet.id);
      _startAutoCloseTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = widget.wallets;
    final fmt = widget.fmt;

    if (wallets.isEmpty) {
      return const CardlessEmptyView(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Belum Ada Rekening',
        description: 'Belum ada rekening atau dompet digital yang terhubung.',
        hint: 'Ketuk tombol + di bawah untuk menambahkan',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        final cardH = cardW * WalletCardDeck.atmRatio;
        final rawExpandedIdx = _expandedWalletId != null ? wallets.indexWhere((w) => w.id == _expandedWalletId) : -1;
        final expandedIndex = (rawExpandedIdx >= 0 && rawExpandedIdx < wallets.length - 1) ? rawExpandedIdx : -1;
        final activeIndex = expandedIndex >= 0 ? expandedIndex : wallets.length - 1;
        final deckH = wallets.length == 1
            ? cardH
            : (expandedIndex >= 0
                ? (2 * cardH) + (wallets.length - 2) * WalletCardDeck.peekHeight + 16.0
                : cardH + (wallets.length - 1) * WalletCardDeck.peekHeight);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: deckH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < wallets.length; i++) ...[
                Builder(builder: (context) {
                  final wallet = wallets[i];
                  final isBottomCard = i == wallets.length - 1;
                  final isSingleCard = wallets.length == 1;
                  final isExpanded = isSingleCard || i == activeIndex;
                  final shouldAnimate = !isSingleCard && (!isBottomCard || expandedIndex >= 0);
                  double topOffset;
                  if (expandedIndex == -1 || i <= expandedIndex) {
                    topOffset = i * WalletCardDeck.peekHeight;
                  } else {
                    topOffset = (i * WalletCardDeck.peekHeight) + (cardH - WalletCardDeck.peekHeight) + 16.0;
                  }

                  return AnimatedPositioned(
                    key: ValueKey('deck_card_${wallet.id}'),
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    top: topOffset,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleCardTap(wallet),
                      child: Hero(
                        tag: 'wallet_card_${wallet.id}',
                        createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
                        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                          final Hero toHero = toHeroContext.widget as Hero;
                          return Material(color: Colors.transparent, child: toHero.child);
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
