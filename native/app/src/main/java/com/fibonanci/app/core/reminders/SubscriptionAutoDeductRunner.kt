package com.fibonanci.app.core.reminders

import android.content.Context
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.FinanceRepository
import com.fibonanci.app.data.db.SubscriptionEntry
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.min

object SubscriptionAutoDeductRunner {
    private val running = AtomicBoolean(false)

    val isRunning: Boolean get() = running.get()

    fun isDueForAutoDeduct(sub: SubscriptionEntry, referenceDate: Long? = null): Boolean {
        if (sub.isDeleted || sub.status != "active" || !sub.autoDeduct) return false

        val nowMillis = referenceDate ?: nowMillis()
        val now = nowMillis.toLocalDate()

        if (sub.isInstallment) {
            if (sub.totalCycles != null && sub.paidCycles >= sub.totalCycles) return false
            if (sub.deadlineDate != null && nowMillis > sub.deadlineDate) return false
        }

        val lastPaid = sub.lastPaidDate
        when (sub.billingCycle) {
            "yearly" -> {
                val isCycleDue = lastPaid == null ||
                    (lastPaid.toLocalDate().year < now.year &&
                        SubscriptionNotificationCalculator.daysBetween(lastPaid, nowMillis) >= 365)
                if (!isCycleDue) return false
            }
            "weekly" -> {
                return lastPaid == null || SubscriptionNotificationCalculator.daysBetween(lastPaid, nowMillis) >= 7
            }
            else -> {
                val lastPaidDay = lastPaid?.toLocalDate()
                val isPaidThisMonth = lastPaidDay != null &&
                    lastPaidDay.year == now.year &&
                    lastPaidDay.monthValue == now.monthValue
                if (isPaidThisMonth) return false
            }
        }

        val clampedDueDay = min(sub.dueDay, now.lengthOfMonth())
        return now.dayOfMonth >= clampedDueDay
    }

    suspend fun runAutoDeduct(
        context: Context,
        repository: FinanceRepository,
        referenceDate: Long? = null,
        onDeducted: ((SubscriptionEntry) -> Unit)? = null,
    ): List<SubscriptionEntry> {
        if (!running.compareAndSet(false, true)) return emptyList()

        try {
            val now = referenceDate ?: nowMillis()
            val activeSubs = repository.getAutoDeductSubscriptions()
            val deducted = mutableListOf<SubscriptionEntry>()

            for (sub in activeSubs) {
                if (!isDueForAutoDeduct(sub, referenceDate = now)) continue
                try {
                    repository.markSubscriptionAsPaid(sub.id, paymentDate = now)
                    deducted.add(sub)
                    onDeducted?.invoke(sub)

                    val receiptId = SubscriptionNotificationCalculator.getAutoDeductId(sub.id)
                    val formattedAmount = SubscriptionNotificationCalculator.formatRupiah(sub.cost)
                    LocalNotificationService.showInstantReceipt(
                        context,
                        id = receiptId,
                        title = "Tagihan Berhasil Didebet: ${sub.title}",
                        body = "Pembayaran $formattedAmount telah otomatis dipotong dari dompet.",
                        payload = sub.id,
                    )
                } catch (_: Exception) {
                }
            }
            return deducted
        } finally {
            running.set(false)
        }
    }
}
