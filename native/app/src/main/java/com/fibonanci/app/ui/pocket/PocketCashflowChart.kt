package com.fibonanci.app.ui.pocket

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ShowChart
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.delay
import java.util.Locale
import kotlin.math.roundToLong

// modular mini cashflow chart designed specifically for kantong tabungan.
@Composable
fun PocketCashflowChart(
    pocket: PocketEntry,
    transactions: List<TransactionEntry>,
    isDark: Boolean,
    primaryColor: Color,
    secondaryColor: Color,
    accentColor: Color,
    fmt: (Double) -> String,
    modifier: Modifier = Modifier,
) {
    val anim = remember { Animatable(0f) }
    var started by remember { mutableStateOf(false) }

    // the dart widget waits for the hosting route transition (340ms) before animating in
    LaunchedEffect(Unit) {
        delay(340)
        started = true
        anim.animateTo(1f, tween(550, easing = EaseOutCubic))
    }
    LaunchedEffect(pocket.currentAmount, transactions.size) {
        if (started) {
            anim.snapTo(0f)
            anim.animateTo(1f, tween(550, easing = EaseOutCubic))
        }
    }

    var totalIn = 0.0
    var totalOut = 0.0
    for (tx in transactions) {
        if (isPocketDeposit(tx)) totalIn += tx.amount else totalOut += tx.amount
    }

    val hasTx = transactions.isNotEmpty()
    val points = calculateCashflowPoints(pocket, transactions)
    val lineColor = if (isDark) accentColor else Color(0xFF0C0D11).copy(alpha = 0.85f)
    val inColor = if (isDark) AppColors.neoMint else Color(0xFF1B5E20)
    val outColor = if (isDark) AppColors.neoCoral else Color(0xFFB71C1C)
    val amountStyle = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold, fontFeatureSettings = "tnum")

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.End,
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        Box(
            modifier = Modifier.fillMaxWidth().graphicsLayer { alpha = anim.value },
            contentAlignment = Alignment.CenterEnd,
        ) {
            Row(modifier = Modifier.wrapContentWidth(), verticalAlignment = Alignment.CenterVertically) {
                if (hasTx && totalIn > 0) {
                    Text("+${formatCompact(totalIn)}", style = amountStyle.copy(color = inColor), maxLines = 1, softWrap = false)
                    if (totalOut > 0) {
                        Text(" • ", style = TextStyle(fontSize = 9.sp, color = secondaryColor.copy(alpha = 0.4f)), maxLines = 1, softWrap = false)
                        Text("-${formatCompact(totalOut)}", style = amountStyle.copy(color = outColor), maxLines = 1, softWrap = false)
                    }
                } else {
                    Icon(Icons.AutoMirrored.Rounded.ShowChart, contentDescription = null, tint = secondaryColor.copy(alpha = 0.7f), modifier = Modifier.size(12.dp))
                    Spacer(Modifier.width(4.dp))
                    Text(
                        "Arus Kas",
                        style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.Bold, color = secondaryColor),
                        maxLines = 1,
                        softWrap = false,
                    )
                }
            }
        }
        Spacer(Modifier.height(4.dp))
        Canvas(modifier = Modifier.fillMaxWidth().weight(1f).fillMaxSize()) {
            with(
                PocketCashflowSplinePainter(
                    values = points,
                    lineColor = lineColor,
                    fillColor = lineColor.copy(alpha = if (isDark) 0.22f else 0.12f),
                    progress = anim.value,
                    hasTransactions = hasTx,
                ),
            ) { paint() }
        }
    }
}

private fun isPocketDeposit(tx: TransactionEntry): Boolean {
    val n = (tx.notes ?: "").lowercase()
    return n.contains("setoran") || tx.type == "transfer"
}

private fun fixed(v: Double, digits: Int): String = String.format(Locale.US, "%.${digits}f", v)

private fun formatCompact(amt: Double): String {
    if (amt >= 1_000_000_000) return "${fixed(amt / 1_000_000_000, if ((amt / 1_000_000_000) % 1 == 0.0) 0 else 1)}M"
    if (amt >= 1_000_000) return "${fixed(amt / 1_000_000, if ((amt / 1_000_000) % 1 == 0.0) 0 else 1)}jt"
    if (amt >= 1000) return "${fixed(amt / 1000, 0)}rb"
    return fixed(amt, 0)
}

private fun calculateCashflowPoints(pocket: PocketEntry, transactions: List<TransactionEntry>): List<Double> {
    val numPoints = 7
    val current = pocket.currentAmount
    if (transactions.isEmpty()) return List(numPoints) { current }

    val sorted = transactions.sortedBy { it.transactionDate }
    val now = nowMillis()
    val firstTx = sorted.first().transactionDate
    val totalSpanDays = (now - firstTx) / 86_400_000L

    val sampleDates = mutableListOf<Long>()
    if (totalSpanDays > 7) {
        for (i in 0 until numPoints) {
            sampleDates.add((firstTx + ((now - firstTx) * (i.toDouble() / (numPoints - 1)))).roundToLong())
        }
    } else {
        val today = now.toLocalDate()
        for (i in numPoints - 1 downTo 0) {
            // end of day (23:59:59.999)
            sampleDates.add(today.minusDays(i.toLong()).plusDays(1).toEpochMillis() - 1)
        }
    }
    val vals = MutableList(numPoints) { current }
    for (i in numPoints - 2 downTo 0) {
        val after = sampleDates[i]
        val next = sampleDates[i + 1]
        var netDelta = 0.0
        for (tx in sorted) {
            val d = tx.transactionDate
            if (d > after && d <= next) {
                netDelta += if (isPocketDeposit(tx)) tx.amount else -tx.amount
            }
        }
        vals[i] = (vals[i + 1] - netDelta).coerceAtLeast(0.0)
    }
    return vals
}
