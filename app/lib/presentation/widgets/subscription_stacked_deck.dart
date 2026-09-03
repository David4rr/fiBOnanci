import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import 'subscription_card.dart';

/// Tactile vertical card deck matching the physical ATM card reference.
class SubscriptionStackedDeck extends StatefulWidget {
  final List<SubscriptionEntry> subscriptions;
  final List<WalletEntry> wallets;
  final void Function(SubscriptionEntry, WalletEntry) onTapCard;

  const SubscriptionStackedDeck({
    super.key,
    required this.subscriptions,
    required this.wallets,
    required this.onTapCard,
  });

  @override
  State<SubscriptionStackedDeck> createState() => _SubscriptionStackedDeckState();
}

class _SubscriptionStackedDeckState extends State<SubscriptionStackedDeck> with SingleTickerProviderStateMixin {
  double _currentPage = 0.0;
  late AnimationController _animController;
  Animation<double>? _snapAnimation;

  static const double _cardHeight = 215.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
    _animController.addListener(() {
      if (_snapAnimation != null) {
        setState(() => _currentPage = _snapAnimation!.value);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SubscriptionStackedDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subscriptions.isNotEmpty && _currentPage >= widget.subscriptions.length) {
      _snapTo((widget.subscriptions.length - 1).toDouble());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _snapTo(double targetPage) {
    final clamped = targetPage.clamp(0.0, (widget.subscriptions.length - 1).toDouble());
    _snapAnimation = Tween<double>(begin: _currentPage, end: clamped).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.duration = const Duration(milliseconds: 280);
    _animController.forward(from: 0.0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) _animController.stop();
    setState(() {
      final delta = -details.primaryDelta! / 160.0;
      _currentPage = (_currentPage + delta).clamp(-0.2, widget.subscriptions.length - 0.8);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = -details.primaryVelocity! / 1000.0;
    final target = (_currentPage + velocity * 0.4).roundToDouble();
    _snapTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.subscriptions;
    if (list.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 340.0;
        final centerY = (totalHeight - _cardHeight) / 2;

        final sortedIndices = List<int>.generate(list.length, (i) => i);
        sortedIndices.sort((a, b) {
          final distA = (a - _currentPage).abs();
          final distB = (b - _currentPage).abs();
          return distB.compareTo(distA);
        });

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final i in sortedIndices)
                      Builder(builder: (context) {
                        final sub = list[i];
                        final wallet = widget.wallets.firstWhere((w) => w.id == sub.walletId, orElse: () => widget.wallets.first);
                        final diff = i - _currentPage;
                        final absDiff = diff.abs();

                        double top;
                        double scale;
                        if (diff < 0) {
                          top = centerY + (diff * 22.0).clamp(-centerY + 10.0, 0.0);
                          scale = (1.0 + diff * 0.05).clamp(0.85, 1.0);
                        } else {
                          top = centerY + math.min(diff * 40.0, centerY + 60.0);
                          scale = (1.0 - diff * 0.04).clamp(0.88, 1.0);
                        }

                        return Positioned(
                          top: top,
                          left: 0,
                          right: 0,
                          child: Transform.scale(
                            scale: scale,
                            alignment: Alignment.center,
                            child: SubscriptionCard(
                              subscription: sub,
                              wallet: wallet,
                              indexOverride: i,
                              isFocused: absDiff < 0.35,
                              onTap: () {
                                if (absDiff < 0.35) {
                                  widget.onTapCard(sub, wallet);
                                } else {
                                  _snapTo(i.toDouble());
                                }
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              if (list.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13151D).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Text(
                        '${(_currentPage.round().clamp(0, list.length - 1) + 1)} / ${list.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
