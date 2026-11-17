package com.fibonanci.app.domain

import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import java.time.LocalDate
import kotlin.math.max

enum class ReportPeriod(val label: String) {
    thisMonth("Bulan Ini"),
    lastMonth("Bulan Lalu"),
    threeMonths("3 Bulan"),
    allTime("Semua"),
}

data class CategorySpendItem(
    val categoryId: String,
    val name: String,
    val colorHex: String,
    val amount: Double,
    val percentage: Double,
    val txCount: Int,
)

data class WalletReportItem(
    val walletId: String,
    val name: String,
    val colorHex: String,
    val balance: Double,
    val income: Double,
    val expense: Double,
)

data class FinancialReportData(
    val period: ReportPeriod,
    val totalIncome: Double,
    val totalExpense: Double,
    val netCashflow: Double,
    val savingsRate: Double,
    val dailyAverageExpense: Double,
    val totalTxCount: Int,
    val totalWalletBalance: Double,
    val totalPocketBalance: Double,
    val totalNetWorth: Double,
    val monthlyCommittedBills: Double,
    val expenseByCategory: List<CategorySpendItem>,
    val incomeByCategory: List<CategorySpendItem>,
    val walletBreakdown: List<WalletReportItem>,
)

object FinancialReportService {
    fun generate(
        wallets: List<WalletEntry>,
        pockets: List<PocketEntry>,
        categories: List<CategoryEntry>,
        transactions: List<TransactionEntry>,
        subscriptions: List<SubscriptionEntry>,
        period: ReportPeriod = ReportPeriod.thisMonth,
        referenceDate: Long? = null,
    ): FinancialReportData {
        val nowMs = referenceDate ?: nowMillis()
        val now = nowMs.toLocalDateTime()
        val activeWallets = wallets.filter { !it.isDeleted }
        val activePockets = pockets.filter { !it.isDeleted }
        val catMap = categories.associateBy { it.id }

        val totalWalletBalance = activeWallets.fold(0.0) { s, w -> s + w.balance }
        val totalPocketBalance = activePockets.fold(0.0) { s, p -> s + p.currentAmount }
        val monthlyCommitted = subscriptions
            .filter { !it.isDeleted && it.status == "active" }
            .fold(0.0) { sum, s -> sum + s.cost }

        val monthStart = LocalDate.of(now.year, now.monthValue, 1)
        val prev = monthStart.minusMonths(1)
        val threeStart = monthStart.minusMonths(2)
        val threeStartMs = threeStart.toEpochMillis()

        val filteredTxs = transactions.filter { tx ->
            if (tx.isDeleted) return@filter false
            if (tx.externalRef?.startsWith("pocket_") == true) return@filter false
            val d = tx.transactionDate.toLocalDateTime()
            when (period) {
                ReportPeriod.thisMonth -> d.year == now.year && d.monthValue == now.monthValue
                ReportPeriod.lastMonth -> d.year == prev.year && d.monthValue == prev.monthValue
                ReportPeriod.threeMonths -> tx.transactionDate >= threeStartMs
                ReportPeriod.allTime -> true
            }
        }

        var totalIncome = 0.0
        var totalExpense = 0.0
        val expCatSum = mutableMapOf<String, Double>()
        val expCatCount = mutableMapOf<String, Int>()
        val incCatSum = mutableMapOf<String, Double>()
        val incCatCount = mutableMapOf<String, Int>()
        val walletInc = mutableMapOf<String, Double>()
        val walletExp = mutableMapOf<String, Double>()

        for (tx in filteredTxs) {
            if (tx.type == "income") {
                totalIncome += tx.amount
                incCatSum[tx.categoryId] = (incCatSum[tx.categoryId] ?: 0.0) + tx.amount
                incCatCount[tx.categoryId] = (incCatCount[tx.categoryId] ?: 0) + 1
                walletInc[tx.walletId] = (walletInc[tx.walletId] ?: 0.0) + tx.amount
            } else if (tx.type == "expense" || tx.type == "transfer") {
                totalExpense += tx.amount
                expCatSum[tx.categoryId] = (expCatSum[tx.categoryId] ?: 0.0) + tx.amount
                expCatCount[tx.categoryId] = (expCatCount[tx.categoryId] ?: 0) + 1
                walletExp[tx.walletId] = (walletExp[tx.walletId] ?: 0.0) + tx.amount
                val dest = tx.destinationWalletId
                if (tx.type == "transfer" && dest != null) {
                    totalIncome += tx.amount
                    walletInc[dest] = (walletInc[dest] ?: 0.0) + tx.amount
                }
            }
        }

        val netCashflow = totalIncome - totalExpense
        val savingsRate = if (totalIncome > 0) ((netCashflow / totalIncome) * 100.0).coerceIn(-100.0, 100.0) else 0.0

        val daysCount = resolveActiveDays(period, nowMs, filteredTxs)
        val dailyAvg = if (daysCount > 0) totalExpense / daysCount else 0.0

        fun buildCatList(sums: Map<String, Double>, counts: Map<String, Int>, total: Double): List<CategorySpendItem> =
            sums.entries.map { e ->
                val cat = catMap[e.key]
                CategorySpendItem(
                    categoryId = e.key,
                    name = cat?.name ?: "Lainnya",
                    colorHex = cat?.colorHex ?: "#64748B",
                    amount = e.value,
                    percentage = if (total > 0) (e.value / total) * 100.0 else 0.0,
                    txCount = counts[e.key] ?: 0,
                )
            }.sortedByDescending { it.amount }

        val walletItems = activeWallets.map { w ->
            WalletReportItem(
                walletId = w.id,
                name = w.name,
                colorHex = w.colorHex,
                balance = w.balance,
                income = walletInc[w.id] ?: 0.0,
                expense = walletExp[w.id] ?: 0.0,
            )
        }.sortedByDescending { it.expense + it.income }

        return FinancialReportData(
            period = period,
            totalIncome = totalIncome,
            totalExpense = totalExpense,
            netCashflow = netCashflow,
            savingsRate = savingsRate,
            dailyAverageExpense = dailyAvg,
            totalTxCount = filteredTxs.size,
            totalWalletBalance = totalWalletBalance,
            totalPocketBalance = totalPocketBalance,
            totalNetWorth = totalWalletBalance + totalPocketBalance,
            monthlyCommittedBills = monthlyCommitted,
            expenseByCategory = buildCatList(expCatSum, expCatCount, totalExpense),
            incomeByCategory = buildCatList(incCatSum, incCatCount, totalIncome),
            walletBreakdown = walletItems,
        )
    }

    private fun resolveActiveDays(period: ReportPeriod, nowMs: Long, txs: List<TransactionEntry>): Int {
        val now = nowMs.toLocalDateTime()
        val monthStart = LocalDate.of(now.year, now.monthValue, 1)
        return when (period) {
            ReportPeriod.thisMonth -> max(1, now.dayOfMonth)
            ReportPeriod.lastMonth -> monthStart.minusMonths(1).lengthOfMonth()
            ReportPeriod.threeMonths -> max(1, inDays(monthStart.minusMonths(2).toEpochMillis(), nowMs) + 1)
            ReportPeriod.allTime -> {
                if (txs.isEmpty()) return 1
                val earliest = txs.minOf { it.transactionDate }
                max(1, inDays(earliest, nowMs) + 1)
            }
        }
    }
}
