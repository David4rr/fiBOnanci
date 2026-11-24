import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/notifications/in_app_notification_storage.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'inbox_reminder_card.dart';

class InboxRemindersView extends StatefulWidget {
  const InboxRemindersView({super.key});

  @override
  State<InboxRemindersView> createState() => _InboxRemindersViewState();
}

class _InboxRemindersViewState extends State<InboxRemindersView> {
  String _selectedCategory = 'all';

  List<InAppNotificationItem> _getFilteredItems(List<InAppNotificationItem> all) {
    if (_selectedCategory == 'all') return all;
    return all.where((i) => i.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: InAppNotificationStorage.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        final allItems = InAppNotificationStorage.notifications;
        final items = _getFilteredItems(allItems);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterChips(allItems),
            if (allItems.isNotEmpty) _buildActionsBar(context, unreadCount),
            Divider(height: 1, color: AppColors.canvasBorder),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InboxReminderCard(
                          item: item,
                          onTap: () => InAppNotificationStorage.markAsRead(item.id),
                          onDelete: () => InAppNotificationStorage.deleteNotification(item.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(List<InAppNotificationItem> all) {
    final categories = [
      {'key': 'all', 'label': 'Semua', 'count': all.length},
      {'key': 'bill', 'label': 'Tagihan', 'count': all.where((i) => i.category == 'bill').length},
      {'key': 'streak', 'label': 'Peringatan', 'count': all.where((i) => i.category == 'streak').length},
      {'key': 'system', 'label': 'Sistem', 'count': all.where((i) => i.category == 'system').length},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppChoiceChip(
              label: '${cat['label']} (${cat['count']})',
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat['key'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionsBar(BuildContext context, int unreadCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => InAppNotificationStorage.markAllAsRead(),
              child: Text(
                'Tandai Semua Dibaca',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          GestureDetector(
            onTap: () => _handleClearAll(context),
            child: Text(
              'Hapus Semua',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red.withAlpha(200),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClearAll(BuildContext context) async {
    final confirm = await AppConfirmationDialog.show(
      context,
      title: 'Hapus Semua Pengingat?',
      content: 'Semua riwayat pengingat akan dihapus secara permanen.',
      confirmText: 'Hapus',
    );
    if (confirm == true) {
      await InAppNotificationStorage.clearAll();
      if (mounted) setState(() {});
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.canvasCardSurface,
                border: Border.all(color: AppColors.canvasBorder),
              ),
              child: Icon(Icons.notifications_none_rounded, color: AppColors.textMuted, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada pengingat atau tagihan tercatat.',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}
