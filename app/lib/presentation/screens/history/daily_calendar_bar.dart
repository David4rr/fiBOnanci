import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';

class DailyDateHelper {
  static List<String> getAllDateKeys(Map<String, List<TransactionEntry>> dayGroups) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final keysSet = <String>{};

    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      keysSet.add('${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }

    keysSet.addAll(dayGroups.keys);
    keysSet.add(todayKey);
    return keysSet.toList()..sort((a, b) => a.compareTo(b));
  }

  static Map<String, List<TransactionEntry>> groupByDay(List<TransactionEntry> list) {
    final map = <String, List<TransactionEntry>>{};
    for (final tx in list) {
      final d = tx.transactionDate.toLocal();
      final key = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  static String formatDayTabLabel(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Hari Ini';
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) return 'Kemarin';
    if (date.year != now.year) return DateFormat('d MMM yy', 'id_ID').format(date);
    return DateFormat('d MMM', 'id_ID').format(date);
  }
}

class DailyCalendarBar extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> sortedDays;
  final int selectedIndex;
  final Map<String, List<TransactionEntry>> dayGroups;
  final ValueChanged<int> onDaySelected;

  const DailyCalendarBar({
    super.key,
    required this.scrollController,
    required this.sortedDays,
    required this.selectedIndex,
    required this.dayGroups,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedDays.length,
        itemBuilder: (context, index) {
          final dateKey = sortedDays[index];
          final isSelected = index == selectedIndex;
          final count = dayGroups[dateKey]?.length ?? 0;
          final label = DailyDateHelper.formatDayTabLabel(dateKey);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onDaySelected(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neoChartreuse.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.zero,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.neoChartreuse : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.textWhite : AppColors.textMuted,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.textWhite : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
