package com.fibonanci.app.core.reminders

import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.core.toLocalDateTime
import java.time.Duration
import java.time.LocalDate
import java.time.YearMonth
import kotlin.math.abs
import kotlin.math.roundToLong

data class ScheduledBillReminder(
    val id: Int,
    val subscriptionId: String,
    val scheduledTime: Long,
    val title: String,
    val body: String,
    val payload: String,
    val daysBefore: Int,
)

object SubscriptionNotificationCalculator {
    fun getBaseId(id: String): Int = (id.hashCode() and 0x7FFFFFFF) % 10000000
    fun getH3Id(id: String): Int = getBaseId(id) * 10 + 3
    fun getH1Id(id: String): Int = getBaseId(id) * 10 + 1
    fun getH0Id(id: String): Int = getBaseId(id) * 10 + 0
    fun getAutoDeductId(id: String): Int = getBaseId(id) * 10 + 9

    fun getAllReminderIds(id: String): List<Int> = listOf(getH3Id(id), getH1Id(id), getH0Id(id))

    fun formatRupiah(amount: Double): String {
        val isNegative = amount < 0
        val rounded = abs(amount).roundToLong().toString()
        val buffer = StringBuilder()
        val len = rounded.length
        for (i in 0 until len) {
            if (i > 0 && (len - i) % 3 == 0) buffer.append('.')
            buffer.append(rounded[i])
        }
        return if (isNegative) "-Rp $buffer" else "Rp $buffer"
    }

    // whole 24h days between two instants, like dart's Duration.inDays
    internal fun daysBetween(from: Long, to: Long): Long = Duration.ofMillis(to - from).toDays()

    fun computeNextDueDate(
        dueDay: Int,
        billingCycle: String = "monthly",
        lastPaidDate: Long? = null,
        referenceDate: Long? = null,
    ): Long {
        val nowMillis = referenceDate ?: nowMillis()
        val now = nowMillis.toLocalDateTime()
        if (billingCycle == "weekly") {
            val targetWeekday = dueDay.coerceIn(1, 7)
            var daysAhead = Math.floorMod(targetWeekday - now.dayOfWeek.value, 7)
            val isPaidThisCycle = lastPaidDate != null && daysBetween(lastPaidDate, nowMillis) < 7
            if (daysAhead == 0 && isPaidThisCycle) daysAhead = 7
            return now.toLocalDate().plusDays(daysAhead.toLong()).toEpochMillis()
        }
        val lastPaid = lastPaidDate?.toLocalDate()
        if (billingCycle == "yearly") {
            val isPaidThisYear = lastPaid != null && lastPaid.year == now.year
            var targetYear = now.year
            val targetMonth = lastPaid?.monthValue ?: now.monthValue
            if (isPaidThisYear || now.monthValue > targetMonth || (now.monthValue == targetMonth && now.dayOfMonth > dueDay)) {
                targetYear += 1
            }
            val maxDays = YearMonth.of(targetYear, targetMonth).lengthOfMonth()
            return LocalDate.of(targetYear, targetMonth, dueDay.coerceIn(1, maxDays)).toEpochMillis()
        }

        val isPaidCurrentMonth = lastPaid != null &&
            lastPaid.year == now.year &&
            lastPaid.monthValue == now.monthValue

        var targetYear = now.year
        var targetMonth = now.monthValue
        if (isPaidCurrentMonth || now.dayOfMonth > dueDay) {
            targetMonth += 1
            if (targetMonth > 12) {
                targetMonth = 1
                targetYear += 1
            }
        }
        val maxDays = YearMonth.of(targetYear, targetMonth).lengthOfMonth()
        return LocalDate.of(targetYear, targetMonth, dueDay.coerceIn(1, maxDays)).toEpochMillis()
    }

    fun calculateReminders(
        subscriptionId: String,
        title: String,
        cost: Double,
        dueDay: Int,
        billingCycle: String = "monthly",
        isInstallment: Boolean = false,
        totalCycles: Int? = null,
        paidCycles: Int = 0,
        deadlineDate: Long? = null,
        lastPaidDate: Long? = null,
        referenceDate: Long? = null,
    ): List<ScheduledBillReminder> {
        val now = referenceDate ?: nowMillis()

        if (isInstallment && totalCycles != null && paidCycles >= totalCycles) return emptyList()
        if (isInstallment && deadlineDate != null && now > deadlineDate) return emptyList()

        val nextDueDate = computeNextDueDate(
            dueDay = dueDay,
            billingCycle = billingCycle,
            lastPaidDate = lastPaidDate,
            referenceDate = now,
        ).toLocalDate()

        val formattedCost = formatRupiah(cost)
        val reminders = mutableListOf<ScheduledBillReminder>()

        val h3Time = nextDueDate.minusDays(3).atTime(9, 0).toEpochMillis()
        if (h3Time > now) {
            reminders.add(
                ScheduledBillReminder(
                    id = getH3Id(subscriptionId),
                    subscriptionId = subscriptionId,
                    scheduledTime = h3Time,
                    title = "Pengingat Tagihan: $title",
                    body = "Tagihan $formattedCost akan jatuh tempo 3 hari lagi (Tgl ${nextDueDate.dayOfMonth}).",
                    payload = subscriptionId,
                    daysBefore = 3,
                )
            )
        }

        val h1Time = nextDueDate.minusDays(1).atTime(9, 0).toEpochMillis()
        if (h1Time > now) {
            reminders.add(
                ScheduledBillReminder(
                    id = getH1Id(subscriptionId),
                    subscriptionId = subscriptionId,
                    scheduledTime = h1Time,
                    title = "Besok Jatuh Tempo: $title",
                    body = "Besok batas pembayaran $formattedCost. Pastikan saldo mencukupi.",
                    payload = subscriptionId,
                    daysBefore = 1,
                )
            )
        }

        val h0Time = nextDueDate.atTime(8, 0).toEpochMillis()
        if (h0Time > now) {
            reminders.add(
                ScheduledBillReminder(
                    id = getH0Id(subscriptionId),
                    subscriptionId = subscriptionId,
                    scheduledTime = h0Time,
                    title = "Jatuh Tempo Hari Ini: $title",
                    body = "Hari ini batas pembayaran $formattedCost. Ketuk untuk menandai lunas.",
                    payload = subscriptionId,
                    daysBefore = 0,
                )
            )
        }

        return reminders
    }
}
