import 'package:flutter/material.dart';
import '../../../core/notification_parser/notification_parser.dart';
import '../../theme/app_colors.dart';
import 'inbox_notification_card.dart';
import 'spring_swipeable_card.dart';

class InboxCardsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final ValueChanged<Map<String, dynamic>> onReject;
  final ValueChanged<Map<String, dynamic>>? onReassign;

  const InboxCardsList({
    super.key,
    required this.items,
    required this.onConfirm,
    required this.onReject,
    this.onReassign,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.58),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final pkg = item['package'] as String? ?? '';
          final title = item['title'] as String? ?? '';
          final text = item['text'] as String? ?? '';
          final walletName = item['walletName'] as String?;
          final profileName = item['profileName'] as String?;
          final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

          final double amount = (item['amount'] as num?)?.toDouble() ?? parsed?.amount ?? 0.0;
          final String type = (item['type'] as String?) ?? parsed?.type ?? 'expense';
          final String counterparty = (item['counterparty'] as String?) ?? parsed?.counterparty ?? '';
          final String bankLabel = pkg.contains('seabank')
              ? 'SeaBank'
              : (pkg.contains('shopee') ? 'ShopeePay' : (title.isNotEmpty ? title : 'Notifikasi Bank'));
          final Color cardAccent = type == 'income' ? AppColors.neoMint : AppColors.neoCoral;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SpringSwipeableCard(
              key: ValueKey(item['transactionId'] ?? '${pkg}_${text}_$index'),
              accentColor: cardAccent,
              onConfirmed: () => onConfirm(item),
              onRejected: () => onReject(item),
              child: InboxNotificationCard(
                bankLabel: bankLabel,
                type: type,
                amount: amount,
                counterparty: counterparty,
                walletName: walletName,
                profileName: profileName,
                onSwitchWallet: onReassign != null ? () => onReassign!(item) : null,
                text: text,
                cardAccent: cardAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
