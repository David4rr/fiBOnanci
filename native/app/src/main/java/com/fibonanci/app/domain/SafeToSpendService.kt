package com.fibonanci.app.domain

import androidx.compose.ui.graphics.Color
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import java.time.LocalDate

enum class FinancialHealthStatus {
    comfortable, // >= 30% buffer
    caution, // 0% - 30% buffer
    deficit, // <= 0% buffer
}

data class SafeToSpendMetrics(
    val totalRealBalance: Double,
    val pendingBills: Double,
    val safeToSpendMonthly: Double,
    val safeToSpendDaily: Double,
    val daysRemainingInMonth: Int,
    val healthStatus: FinancialHealthStatus,
    val selectedWalletIds: Set<String> = emptySet(), // empty = all wallets
    val isAllWallets: Boolean = true,
    val selectedWalletsCount: Int = 0,
) {
    val statusColor: Color
        get() = when (healthStatus) {
            FinancialHealthStatus.comfortable -> AppColors.statusComfortable
            FinancialHealthStatus.caution -> AppColors.statusCaution
            FinancialHealthStatus.deficit -> AppColors.statusDeficit
        }

    val statusLabel: String
        get() = when (healthStatus) {
            FinancialHealthStatus.comfortable -> "Sangat Aman"
            FinancialHealthStatus.caution -> "Waspada"
            FinancialHealthStatus.deficit -> "Defisit Tagihan"
        }
}

// dart Duration.inDays between two instants: elapsed time truncated toward zero
internal fun inDays(fromMillis: Long, toMillis: Long): Int = ((toMillis - fromMillis) / 86_400_000L).toInt()

object SafeToSpendService {
    // pure deterministic calculation of safe-to-spend metrics
    fun calculate(
        wallets: List<WalletEntry>,
        subscriptions: List<SubscriptionEntry>,
        selectedWalletIds: Set<String>? = null,
        referenceDate: Long? = null,
        cycleDay: Int = 1,
    ): SafeToSpendMetrics {
        val nowMs = referenceDate ?: nowMillis()
        val now = nowMs.toLocalDateTime()

        val activeWallets = wallets.filter { !it.isDeleted }
        val isAll = selectedWalletIds == null ||
            selectedWalletIds.isEmpty() ||
            selectedWalletIds.size >= activeWallets.size

        val targetWalletIds: Set<String> = if (isAll) emptySet() else selectedWalletIds!!.toSet()

        // 1. real balance across selected or all active wallets
        var totalBalance = 0.0
        var count = 0
        for (wallet in activeWallets) {
            if (isAll || targetWalletIds.contains(wallet.id)) {
                totalBalance += wallet.balance
                count++
            }
        }

        // 2. pending bills for the current month
        var pendingBills = 0.0
        val currentMonthStart = LocalDate.of(now.year, now.monthValue, 1).toEpochMillis()

        for (sub in subscriptions) {
            if (sub.isDeleted || sub.status != "active") continue
            if (sub.isInstallment && sub.totalCycles != null && sub.paidCycles >= sub.totalCycles) continue
            if (sub.isInstallment && sub.deadlineDate != null && nowMs > sub.deadlineDate) continue

            val lastPaid = sub.lastPaidDate
            val isPaidThisCycle = lastPaid != null && lastPaid > currentMonthStart

            if (!isPaidThisCycle) {
                if (isAll || targetWalletIds.contains(sub.walletId)) {
                    pendingBills += sub.cost
                }
            }
        }
        // 3. monthly safe-to-spend
        val safeToSpendMonthly = totalBalance - pendingBills

        // 4. days remaining in current budget cycle
        val daysRemaining: Int
        val monthStart = LocalDate.of(now.year, now.monthValue, 1)
        if (cycleDay <= 1) {
            val lastDayOfMonth = monthStart.lengthOfMonth()
            daysRemaining = (lastDayOfMonth - now.dayOfMonth) + 1
        } else {
            val today = now.toLocalDate()
            val curMax = monthStart.lengthOfMonth()
            val curCut = if (cycleDay > curMax) curMax else cycleDay
            val nextMonth = monthStart.plusMonths(1)
            val nxtMax = nextMonth.lengthOfMonth()
            val nxtCut = if (cycleDay > nxtMax) nxtMax else cycleDay
            val nextCutoff = if (now.dayOfMonth < curCut) monthStart.withDayOfMonth(curCut) else nextMonth.withDayOfMonth(nxtCut)
            daysRemaining = inDays(today.toEpochMillis(), nextCutoff.toEpochMillis())
        }
        val divisor = if (daysRemaining > 0) daysRemaining else 1

        // 5. daily allowance
        val safeToSpendDaily = if (safeToSpendMonthly > 0) safeToSpendMonthly / divisor else 0.0

        // 6. health status
        val status = if (totalBalance <= 0 || safeToSpendMonthly <= 0) {
            FinancialHealthStatus.deficit
        } else {
            val ratio = safeToSpendMonthly / totalBalance
            if (ratio >= 0.30) FinancialHealthStatus.comfortable else FinancialHealthStatus.caution
        }

        return SafeToSpendMetrics(
            totalRealBalance = totalBalance,
            pendingBills = pendingBills,
            safeToSpendMonthly = safeToSpendMonthly,
            safeToSpendDaily = safeToSpendDaily,
            daysRemainingInMonth = daysRemaining,
            healthStatus = status,
            selectedWalletIds = targetWalletIds,
            isAllWallets = isAll,
            selectedWalletsCount = if (isAll) activeWallets.size else count,
        )
    }
}
