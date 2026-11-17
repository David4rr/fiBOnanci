package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.ui.theme.PlusJakartaSans

private val dayLabels = listOf("Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min")
private val barInk = Color(0xFF0C0D11)

@Composable
fun MiniWeeklyBarChart(
    txDate: Long,
    weeklySpending: List<Double>? = null,
    modifier: Modifier = Modifier,
) {
    val activeDayIndex = (txDate.toLocalDate().dayOfWeek.value - 1).coerceIn(0, 6)
    val data = if (weeklySpending != null && weeklySpending.size == 7) weeklySpending else List(7) { 0.0 }
    val maxSpend = data.max()

    Row(modifier, verticalAlignment = Alignment.Bottom) {
        for (d in 0 until 7) {
            val spend = data[d]
            val isTodayOrActive = d == activeDayIndex
            val barHeight = if (maxSpend > 0) {
                if (spend > 0) (spend / maxSpend * 40.0 + 8.0).coerceIn(8.0, 48.0) else 6.0
            } else {
                if (isTodayOrActive) 24.0 else 6.0
            }
            Column(Modifier.weight(1f), horizontalAlignment = Alignment.CenterHorizontally) {
                Spacer(
                    Modifier
                        .padding(horizontal = 2.5.dp)
                        .fillMaxWidth()
                        .height(barHeight.dp)
                        .background(
                            when {
                                isTodayOrActive -> barInk
                                spend > 0 -> barInk.copy(alpha = 0.55f)
                                else -> barInk.copy(alpha = 0.18f)
                            },
                            RoundedCornerShape(3.dp),
                        ),
                )
                Spacer(Modifier.height(5.dp))
                Text(
                    dayLabels[d],
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 9.sp,
                        fontWeight = if (isTodayOrActive) FontWeight.W800 else FontWeight.W600,
                        color = barInk.copy(alpha = if (isTodayOrActive) 0.95f else 0.45f),
                        textAlign = TextAlign.Center,
                    ),
                    maxLines = 1,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }
}
