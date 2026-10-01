import 'package:flutter/material.dart';

import '../../../core/notification_parser/notification_parser.dart';
import '../../theme/app_colors.dart';
import 'inbox_notification_card.dart';
import 'spring_swipeable_card.dart';

class InboxStackedDeck extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final ValueChanged<Map<String, dynamic>> onReject;
  final ValueChanged<Map<String, dynamic>>? onReassign;

  const InboxStackedDeck({
    super.key,
    required this.items,
    required this.onConfirm,
    required this.onReject,
    this.onReassign,
  });

  @override
  State<InboxStackedDeck> createState() => _InboxStackedDeckState();
}

class _InboxStackedDeckState extends State<InboxStackedDeck> {
  final ValueNotifier<double> _dragProgress = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _dragProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;
    if (count == 0) return const SizedBox.shrink();

    // Minimalist clean: at most 1 subtle hint card behind active card
    final hasBackCard = count >= 2;
    final bottomPad = hasBackCard ? 10.0 : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          if (hasBackCard) _buildBackCard(1, count),
          _buildTopCard(0, count),
        ],
      ),
    );
  }

  Widget _buildBackCard(int index, int totalCount) {
    final item = widget.items[index];
    const baseScale = 0.96;
    const targetScale = 1.0;
    const baseTranslate = 10.0;
    const targetTranslate = 0.0;
    const baseOpacity = 0.65;
    const targetOpacity = 1.0;

    return Positioned.fill(
      child: ValueListenableBuilder<double>(
        valueListenable: _dragProgress,
        builder: (context, progress, child) {
          final scale = baseScale + (targetScale - baseScale) * progress;
          final translateY = baseTranslate + (targetTranslate - baseTranslate) * progress;
          final opacity = (baseOpacity + (targetOpacity - baseOpacity) * progress).clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0.0, translateY),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          );
        },
        child: IgnorePointer(
          child: _buildCardContent(item, index, totalCount, isTopCard: false),
        ),
      ),
    );
  }

  Widget _buildTopCard(int index, int totalCount) {
    final item = widget.items[index];
    final pkg = (item['package'] ?? '').toString();
    final text = (item['text'] ?? '').toString();
    final cardAccent = _resolveAccentColor(item);

    return SpringSwipeableCard(
      key: ValueKey(item['transactionId'] ?? '${pkg}_${text}_$index'),
      accentColor: cardAccent,
      onConfirmed: () => widget.onConfirm(item),
      onRejected: () => widget.onReject(item),
      onDragOffsetChanged: (offset) {
        if (!mounted) return;
        final threshold = MediaQuery.sizeOf(context).width * 0.50;
        _dragProgress.value = (offset.abs() / threshold).clamp(0.0, 1.0);
      },
      child: _buildCardContent(item, index, totalCount, isTopCard: true),
    );
  }

  Widget _buildCardContent(
    Map<String, dynamic> item,
    int index,
    int totalCount, {
    required bool isTopCard,
  }) {
    final pkg = (item['package'] ?? '').toString();
    final title = (item['title'] ?? '').toString();
    final text = (item['text'] ?? '').toString();
    final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

    final amount = (item['amount'] as num?)?.toDouble() ?? parsed?.amount ?? 0.0;
    final type = (item['type'] as String?) ?? parsed?.type ?? 'expense';
    final counterparty = (item['counterparty'] as String?) ?? parsed?.counterparty ?? '';
    final bankLabel = _resolveBankLabel(pkg, title);
    final cardAccent = _resolveAccentColor(item, type);
    final walletName = item['walletName'] as String?;
    final profileName = item['profileName'] as String?;
    return InboxNotificationCard(
      bankLabel: bankLabel,
      type: type,
      amount: amount,
      counterparty: counterparty,
      walletName: walletName,
      profileName: profileName,
      onSwitchWallet: isTopCard && widget.onReassign != null ? () => widget.onReassign!(item) : null,
      text: text,
      cardAccent: cardAccent,
      currentIndex: index,
      totalCount: totalCount,
      isTopCard: isTopCard,
    );
  }

  String _resolveBankLabel(String pkg, String title) {
    final p = pkg.toLowerCase();
    if (p.contains('bca')) return 'BCA';
    if (p.contains('mandiri') || p.contains('livin')) return 'Mandiri';
    if (p.contains('bri') || p.contains('brimo')) return 'BRI';
    if (p.contains('bni')) return 'BNI';
    if (p.contains('jago')) return 'Bank Jago';
    if (p.contains('seabank')) return 'SeaBank';
    if (p.contains('gopay')) return 'GoPay';
    if (p.contains('ovo')) return 'OVO';
    if (p.contains('dana')) return 'DANA';
    if (p.contains('shopee')) return 'ShopeePay';
    return title.isNotEmpty ? title : 'Bank';
  }

  Color _resolveAccentColor(Map<String, dynamic> item, [String? typeHint]) {
    final type = (item['type'] as String?) ?? typeHint ?? 'expense';
    if (type == 'income') return AppColors.neoMint;
    final pkg = (item['package'] ?? '').toString().toLowerCase();
    if (pkg.contains('bca')) return const Color(0xFF005E9E);
    if (pkg.contains('mandiri')) return const Color(0xFFFFB300);
    if (pkg.contains('bri')) return const Color(0xFF00529C);
    if (pkg.contains('bni')) return const Color(0xFFF15A24);
    if (pkg.contains('jago')) return const Color(0xFFFF7A00);
    if (pkg.contains('seabank')) return const Color(0xFFFF5722);
    if (pkg.contains('gopay')) return const Color(0xFF00AED6);
    if (pkg.contains('ovo')) return const Color(0xFF4C2A86);
    if (pkg.contains('dana')) return const Color(0xFF118EEA);
    return AppColors.neoCoral;
  }
}
