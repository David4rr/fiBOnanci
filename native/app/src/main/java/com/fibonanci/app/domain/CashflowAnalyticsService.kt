package com.fibonanci.app.domain

import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import java.math.BigDecimal
import kotlin.math.abs

// aggregated income & expense for the current month
data class MonthlyCashflow(
    val income: Double = 0.0,
    val expense: Double = 0.0,
)

// dart double.toString for plain amounts (no exponent below 1e21, always keeps ".0")
private fun Double.dartToString(): String {
    if (isNaN() || isInfinite() || abs(this) >= 1e21 || (this != 0.0 && abs(this) < 1e-6)) return toString()
    val plain = BigDecimal(toString()).toPlainString()
    return if (plain.contains('.')) plain else "$plain.0"
}

// pure domain service for transaction analytics and cashflow calculations
object CashflowAnalyticsService {
    // aggregates total income and expense for the current month
    fun calculateMonthlyCashflow(
        transactions: List<TransactionEntry>,
        referenceDate: Long? = null,
    ): MonthlyCashflow {
        val now = (referenceDate ?: nowMillis()).toLocalDateTime()
        var income = 0.0
        var expense = 0.0

        for (tx in transactions) {
            val localTx = tx.transactionDate.toLocalDateTime()
            if (localTx.year == now.year && localTx.monthValue == now.monthValue) {
                if (tx.type == "income") {
                    income += tx.amount
                } else if (tx.type == "expense" || tx.type == "transfer") {
                    expense += tx.amount
                    if (tx.type == "transfer" && tx.destinationWalletId != null) income += tx.amount
                }
            }
        }

        return MonthlyCashflow(income = income, expense = expense)
    }

    // 30-day daily aggregation series for income or expense
    fun compute30DaySeries(
        transactions: List<TransactionEntry>,
        type: String,
        walletId: String? = null,
        referenceDate: Long? = null,
    ): List<Double> {
        val today = (referenceDate ?: nowMillis()).toLocalDateTime().toLocalDate().toEpochMillis()
        val dailyValues = MutableList(30) { 0.0 }

        for (tx in transactions) {
            if (walletId != null) {
                val isOutTransfer = tx.type == "transfer" && tx.walletId == walletId
                val isInTransfer = tx.type == "transfer" && tx.destinationWalletId == walletId
                if (type == "expense" && !(tx.type == "expense" && tx.walletId == walletId) && !isOutTransfer) continue
                if (type == "income" && !(tx.type == "income" && tx.walletId == walletId) && !isInTransfer) continue
                if (type != "expense" && type != "income" && tx.type != type) continue
            } else {
                if (type == "expense" && tx.type != "expense" && tx.type != "transfer") continue
                if (type == "income" && tx.type != "income" && !(tx.type == "transfer" && tx.destinationWalletId != null)) continue
                if (type != "expense" && type != "income" && tx.type != type) continue
            }
            val txDay = tx.transactionDate.toLocalDateTime().toLocalDate().toEpochMillis()
            val diff = inDays(txDay, today)

            if (diff in 0..29) {
                dailyValues[29 - diff] += tx.amount
            } else if (diff == -1) {
                dailyValues[29] += tx.amount
            }
        }

        return dailyValues
    }

    // real 7-day daily spending/income (sen–min) for the week of referenceDate
    fun computeWeeklySpending(
        transactions: List<TransactionEntry>,
        referenceDate: Long? = null,
        walletId: String? = null,
        categoryId: String? = null,
        type: String? = null,
    ): List<Double> {
        val ref = (referenceDate ?: nowMillis()).toLocalDateTime().toLocalDate()
        val monday = ref.minusDays((ref.dayOfWeek.value - 1).toLong()).toEpochMillis()
        val dailySpend = MutableList(7) { 0.0 }

        for (tx in transactions) {
            if (walletId != null) {
                if (type == "income") {
                    val isIn = (tx.type == "income" && tx.walletId == walletId) || (tx.type == "transfer" && tx.destinationWalletId == walletId)
                    if (!isIn) continue
                } else if (type == "transfer") {
                    if (tx.type != "transfer" || (tx.walletId != walletId && tx.destinationWalletId != walletId)) continue
                } else {
                    val isOut = (tx.type == "expense" || tx.type == "transfer") && tx.walletId == walletId
                    if (!isOut) continue
                }
            } else {
                if (type == "income") {
                    if (tx.type != "income" && !(tx.type == "transfer" && tx.destinationWalletId != null)) continue
                } else if (type == "transfer") {
                    if (tx.type != "transfer") continue
                } else if (tx.type != "expense" && tx.type != "transfer") {
                    continue
                }
            }
            if (categoryId != null && tx.categoryId != categoryId) continue

            val txDate = tx.transactionDate.toLocalDateTime().toLocalDate().toEpochMillis()
            // dart: (difference.inHours / 24).round()
            val inHours = (txDate - monday) / 3_600_000L
            val diff = (inHours / 24.0).dartRound()
            if (diff in 0..6) {
                dailySpend[diff.toInt()] += abs(tx.amount)
            }
        }

        return dailySpend
    }

    // 30 labels with 5 evenly spaced date interval markers
    fun compute30DayLabels(referenceDate: Long? = null): List<String> {
        val now = referenceDate ?: nowMillis()
        return List(30) { i ->
            if (i == 0 || i == 7 || i == 14 || i == 21 || i == 29) {
                val d = (now - (29 - i) * 86_400_000L).toLocalDateTime()
                "${d.dayOfMonth}/${d.monthValue}"
            } else {
                ""
            }
        }
    }

    // pure filtering and searching logic for transaction list views
    fun filterTransactions(
        transactions: List<TransactionEntry>,
        wallets: List<WalletEntry>,
        query: String = "",
        typeFilter: String = "all",
        walletFilter: String? = null,
    ): List<TransactionEntry> {
        val cleanQuery = query.trim().lowercase()

        return transactions.filter { tx ->
            if (cleanQuery.isNotEmpty()) {
                val notes = (tx.notes ?: "").lowercase()
                val type = tx.type.lowercase()
                val amt = tx.amount.dartToString()
                val walletName = (wallets.firstOrNull { it.id == tx.walletId } ?: wallets.firstOrNull())?.name?.lowercase() ?: ""
                val destWalletName = if (tx.destinationWalletId != null) {
                    wallets.firstOrNull { it.id == tx.destinationWalletId }?.name?.lowercase() ?: ""
                } else {
                    ""
                }
                val typeIndo = if (tx.type == "income") "pemasukan masuk" else if (tx.type == "expense") "pengeluaran keluar" else "transfer mutasi"
                val match = notes.contains(cleanQuery) ||
                    type.contains(cleanQuery) ||
                    typeIndo.contains(cleanQuery) ||
                    amt.contains(cleanQuery) ||
                    walletName.contains(cleanQuery) ||
                    destWalletName.contains(cleanQuery)
                if (!match) return@filter false
            }

            if (typeFilter != "all" && tx.type != typeFilter) return@filter false
            if (walletFilter != null && tx.walletId != walletFilter && tx.destinationWalletId != walletFilter) return@filter false

            true
        }
    }

    // historical stock-like balance trajectory for kantong tabungan
    fun computePocketTrendSeries(
        currentTotal: Double,
        transactions: List<TransactionEntry>,
        filter: String,
        referenceDate: Long? = null,
    ): PocketStockTrendResult = PocketTrendService.computePocketTrendSeries(
        currentTotal = currentTotal,
        transactions = transactions,
        filter = filter,
        referenceDate = referenceDate,
    )
}
