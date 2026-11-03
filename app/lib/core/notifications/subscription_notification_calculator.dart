class ScheduledBillReminder {
  final int id;
  final String subscriptionId;
  final DateTime scheduledTime;
  final String title;
  final String body;
  final String payload;
  final int daysBefore;

  const ScheduledBillReminder({
    required this.id,
    required this.subscriptionId,
    required this.scheduledTime,
    required this.title,
    required this.body,
    required this.payload,
    required this.daysBefore,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledBillReminder &&
          id == other.id &&
          subscriptionId == other.subscriptionId &&
          scheduledTime == other.scheduledTime &&
          daysBefore == other.daysBefore;

  @override
  int get hashCode => Object.hash(id, subscriptionId, scheduledTime, daysBefore);
}

class SubscriptionNotificationCalculator {
  static int getBaseId(String id) => (id.hashCode & 0x7FFFFFFF) % 10000000;
  static int getH3Id(String id) => getBaseId(id) * 10 + 3;
  static int getH1Id(String id) => getBaseId(id) * 10 + 1;
  static int getH0Id(String id) => getBaseId(id) * 10 + 0;
  static int getAutoDeductId(String id) => getBaseId(id) * 10 + 9;

  static List<int> getAllReminderIds(String id) => [getH3Id(id), getH1Id(id), getH0Id(id)];

  static String formatRupiah(double amount) {
    final isNegative = amount < 0;
    final rounded = amount.abs().round().toString();
    final buffer = StringBuffer();
    final len = rounded.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(rounded[i]);
    }
    return isNegative ? '-Rp $buffer' : 'Rp $buffer';
  }

  static DateTime computeNextDueDate({
    required int dueDay,
    String billingCycle = 'monthly',
    DateTime? lastPaidDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    if (billingCycle == 'weekly') {
      final targetWeekday = dueDay.clamp(1, 7);
      int daysAhead = (targetWeekday - now.weekday) % 7;
      final isPaidThisCycle = lastPaidDate != null && now.difference(lastPaidDate).inDays < 7;
      if (daysAhead == 0 && isPaidThisCycle) daysAhead = 7;
      final nextDate = now.add(Duration(days: daysAhead));
      return DateTime(nextDate.year, nextDate.month, nextDate.day);
    }
    if (billingCycle == 'yearly') {
      final isPaidThisYear = lastPaidDate != null && lastPaidDate.year == now.year;
      int targetYear = now.year;
      final targetMonth = lastPaidDate?.month ?? now.month;
      if (isPaidThisYear || (now.month > targetMonth || (now.month == targetMonth && now.day > dueDay))) {
        targetYear += 1;
      }
      final maxDays = DateTime(targetYear, targetMonth + 1, 0).day;
      final clampedDay = dueDay.clamp(1, maxDays);
      return DateTime(targetYear, targetMonth, clampedDay);
    }


    final isPaidCurrentMonth = lastPaidDate != null &&
        lastPaidDate.year == now.year &&
        lastPaidDate.month == now.month;

    int targetYear = now.year;
    int targetMonth = now.month;

    if (isPaidCurrentMonth || now.day > dueDay) {
      targetMonth += 1;
      if (targetMonth > 12) {
        targetMonth = 1;
        targetYear += 1;
      }
    }

    final maxDays = DateTime(targetYear, targetMonth + 1, 0).day;
    final clampedDay = dueDay.clamp(1, maxDays);
    return DateTime(targetYear, targetMonth, clampedDay);
  }

  static List<ScheduledBillReminder> calculateReminders({
    required String subscriptionId,
    required String title,
    required double cost,
    required int dueDay,
    String billingCycle = 'monthly',
    bool isInstallment = false,
    int? totalCycles,
    int paidCycles = 0,
    DateTime? deadlineDate,
    DateTime? lastPaidDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    if (isInstallment && totalCycles != null && paidCycles >= totalCycles) {
      return const [];
    }
    if (isInstallment && deadlineDate != null && now.isAfter(deadlineDate)) {
      return const [];
    }

    final nextDueDate = computeNextDueDate(
      dueDay: dueDay,
      billingCycle: billingCycle,
      lastPaidDate: lastPaidDate,
      referenceDate: now,
    );

    final formattedCost = formatRupiah(cost);
    final reminders = <ScheduledBillReminder>[];

    final h3Time = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day - 3, 9, 0);
    if (h3Time.isAfter(now)) {
      reminders.add(ScheduledBillReminder(
        id: getH3Id(subscriptionId),
        subscriptionId: subscriptionId,
        scheduledTime: h3Time,
        title: 'Pengingat Tagihan: $title',
        body: 'Tagihan $formattedCost akan jatuh tempo 3 hari lagi (Tgl ${nextDueDate.day}).',
        payload: subscriptionId,
        daysBefore: 3,
      ));
    }

    final h1Time = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day - 1, 9, 0);
    if (h1Time.isAfter(now)) {
      reminders.add(ScheduledBillReminder(
        id: getH1Id(subscriptionId),
        subscriptionId: subscriptionId,
        scheduledTime: h1Time,
        title: 'Besok Jatuh Tempo: $title',
        body: 'Besok batas pembayaran $formattedCost. Pastikan saldo mencukupi.',
        payload: subscriptionId,
        daysBefore: 1,
      ));
    }

    final h0Time = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day, 8, 0);
    if (h0Time.isAfter(now)) {
      reminders.add(ScheduledBillReminder(
        id: getH0Id(subscriptionId),
        subscriptionId: subscriptionId,
        scheduledTime: h0Time,
        title: 'Jatuh Tempo Hari Ini: $title',
        body: 'Hari ini batas pembayaran $formattedCost. Ketuk untuk menandai lunas.',
        payload: subscriptionId,
        daysBefore: 0,
      ));
    }

    return reminders;
  }
}
