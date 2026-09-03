import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/wallet_card_deck.dart';

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PressableScale({super.key, required this.child, this.onTap});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = true);
          HapticFeedback.selectionClick();
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class TactileHeroCard extends StatefulWidget {
  final WalletEntry wallet;
  final int cardIndex;
  final NumberFormat fmt;
  final Color cardColor;
  final List<WalletEntry>? allWallets;

  const TactileHeroCard({
    super.key,
    required this.wallet,
    required this.cardIndex,
    required this.fmt,
    required this.cardColor,
    this.allWallets,
  });

  @override
  State<TactileHeroCard> createState() => _TactileHeroCardState();
}

class _TactileHeroCardState extends State<TactileHeroCard> {
  bool _isCopied = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();
    setState(() => _isCopied = true);
    final accNum = widget.wallet.accountNumber?.trim();
    final textToCopy = (accNum != null && accNum.isNotEmpty) ? accNum : widget.wallet.name;
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        backgroundColor: AppColors.canvasCardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: widget.cardColor.withValues(alpha: 0.45))),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: widget.cardColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                accNum != null && accNum.isNotEmpty ? 'Nomor rekening $accNum disalin' : 'Nama rekening ${widget.wallet.name} disalin',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        final cardH = cardW * WalletCardDeck.atmRatio;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(context),
          child: Container(
            width: cardW,
            height: cardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: widget.cardColor.withValues(alpha: 0.26), blurRadius: 28, offset: const Offset(0, 14), spreadRadius: -4),
                BoxShadow(color: Colors.black.withValues(alpha: 0.60), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: 'wallet_card_${widget.wallet.id}',
                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                      final Hero toHero = toHeroContext.widget as Hero;
                      return Material(color: Colors.transparent, child: toHero.child);
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: WalletCard(
                        wallet: widget.wallet,
                        index: widget.cardIndex,
                        allWallets: widget.allWallets,
                        fmt: widget.fmt,
                        cardH: cardH,
                        isLifted: true,
                        showBottomLayout: true,
                      ),
                    ),
                  ),
                ),
                if (_isCopied)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.canvasBg.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: widget.cardColor.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: widget.cardColor, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Disalin', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
