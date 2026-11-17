package com.fibonanci.app.domain

import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.TransactionEntry
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

// stock-like historical balance trajectory for kantong tabungan
data class PocketStockTrendResult(
    val values: List<Double>,
    val labels: List<String>,
    val initialBalance: Double,
    val currentBalance: Double,
    val delta: Double,
    val percentChange: Double,
    val isUpward: Boolean,
)

object PocketTrendService {
    private val idLocale = Locale.forLanguageTag("id-ID")

    private fun format(pattern: String, millis: Long): String =
        DateTimeFormatter.ofPattern(pattern, idLocale).format(millis.toLocalDateTime())

    private fun endOfDay(day: LocalDate): Long = day.atTime(23, 59, 59, 999_000_000).toEpochMillis()

    // computes historical stock-like balance trajectory for kantong tabungan
    fun computePocketTrendSeries(
        currentTotal: Double,
        transactions: List<TransactionEntry>,
        filter: String, // '1M', '1B', '1T', 'Semua'
        referenceDate: Long? = null,
    ): PocketStockTrendResult {
        val nowMs = referenceDate ?: nowMillis()
        val today = nowMs.toLocalDateTime().toLocalDate()
        val endOfToday = endOfDay(today)

        // pocket-related transactions
        val pocketTxs = transactions.filter { t ->
            val n = (t.notes ?: "").lowercase()
            n.contains("kantong") || n.contains("pocket")
        }

        val numPoints: Int
        val sampleDates = mutableListOf<Long>()
        val labels: List<String>

        when (filter) {
            "1M" -> {
                numPoints = 7
                for (i in numPoints - 1 downTo 0) sampleDates.add(endOfDay(today.minusDays(i.toLong())))
                labels = sampleDates.map { format("E", it) }
            }
            "1B" -> {
                numPoints = 30
                for (i in numPoints - 1 downTo 0) sampleDates.add(endOfDay(today.minusDays(i.toLong())))
                // 5 evenly spaced labels
                labels = List(numPoints) { index ->
                    if (index == 0 || index == 7 || index == 14 || index == 21 || index == 29) {
                        format("d MMM", sampleDates[index])
                    } else {
                        ""
                    }
                }
            }
            "1T" -> {
                numPoints = 12
                val monthStart = today.withDayOfMonth(1)
                for (i in numPoints - 1 downTo 0) {
                    if (i == 0) {
                        sampleDates.add(endOfToday)
                    } else {
                        // last day of the month i months back
                        sampleDates.add(endOfDay(monthStart.minusMonths((i - 1).toLong()).minusDays(1)))
                    }
                }
                labels = sampleDates.map { format("MMM", it) }
            }
            else -> {
                numPoints = 14
                var earliest = nowMs - 90L * 86_400_000L
                if (pocketTxs.isNotEmpty()) {
                    val firstTxDate = pocketTxs.minOf { it.transactionDate }
                    if (firstTxDate < earliest) {
                        earliest = firstTxDate.toLocalDateTime().toLocalDate().toEpochMillis()
                    }
                }
                val startMillis = earliest.toLocalDateTime().toLocalDate().toEpochMillis()
                val totalSpan = endOfToday - startMillis

                for (i in 0 until numPoints) {
                    if (i == numPoints - 1) {
                        sampleDates.add(endOfToday)
                    } else {
                        sampleDates.add((startMillis + (totalSpan * (i.toDouble() / (numPoints - 1)))).dartRound())
                    }
                }
                labels = List(numPoints) { i ->
                    if (i == 0 || i == numPoints / 2 || i == numPoints - 1) format("d/M/yy", sampleDates[i]) else ""
                }
            }
        }

        // backward reconstruction from currentTotal
        val values = MutableList(numPoints) { currentTotal }

        if (pocketTxs.isNotEmpty()) {
            for (i in numPoints - 2 downTo 0) {
                val dateAfter = sampleDates[i]
                val dateNext = sampleDates[i + 1]

                var netDelta = 0.0
                for (tx in pocketTxs) {
                    val txDate = tx.transactionDate
                    if (txDate > dateAfter && txDate <= dateNext) {
                        val n = (tx.notes ?: "").lowercase()
                        val isDeposit = n.contains("setoran") || tx.type == "transfer"
                        if (isDeposit) netDelta += tx.amount else netDelta -= tx.amount
                    }
                }
                values[i] = (values[i + 1] - netDelta).coerceAtLeast(0.0)
            }
        }

        val initial = values.first()
        val current = values.last()
        val delta = current - initial
        val percentChange = if (initial > 0) (delta / initial) * 100 else if (current > 0) 100.0 else 0.0
        val isUpward = delta >= 0

        return PocketStockTrendResult(
            values = values,
            labels = labels,
            initialBalance = initial,
            currentBalance = current,
            delta = delta,
            percentChange = percentChange,
            isUpward = isUpward,
        )
    }
}
