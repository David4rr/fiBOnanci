package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowForward
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.ui.dashboard.MiniWeeklyBarChart
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlin.math.abs

private val ink = Color(0xFF0C0D11)

@Composable
fun OverlappingDeckExpandedInsight(
    category: String,
    categoryColor: Color,
    transactionDate: Long,
    weeklySpending: List<Double>?,
    currencyFormatter: (Double) -> String,
    onManage: (() -> Unit)? = null,
    subtitle: String? = null,
) {
    val activeDayIndex = (transactionDate.toLocalDate().dayOfWeek.value - 1).coerceIn(0, 6)
    val dailyTotal = if (weeklySpending != null && weeklySpending.size > activeDayIndex) abs(weeklySpending[activeDayIndex]) else 0.0
    Column(Modifier.fillMaxWidth()) {
        Spacer(Modifier.height(14.dp))
        Box(Modifier.fillMaxWidth().height(1.dp).background(ink.copy(alpha = 0.14f)))
        Spacer(Modifier.height(10.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text(
                "Tren ${category.lowercase()} (Sen–Min)",
                modifier = Modifier.weight(1f),
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.SemiBold, color = ink.copy(alpha = 0.65f)),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.width(8.dp))
            Text(
                currencyFormatter(dailyTotal),
                style = TextStyle(
                    fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.ExtraBold,
                    color = ink.copy(alpha = 0.8f), fontFeatureSettings = "tnum",
                ),
            )
        }
        Spacer(Modifier.height(8.dp))
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.Bottom) {
            Box(Modifier.weight(1f)) {
                MiniWeeklyBarChart(txDate = transactionDate, weeklySpending = weeklySpending)
            }
            if (onManage != null) {
                Spacer(Modifier.width(14.dp))
                Row(
                    Modifier
                        .shadow(3.dp, RoundedCornerShape(18.dp), ambientColor = Color.Black.copy(alpha = 0.2f), spotColor = Color.Black.copy(alpha = 0.2f))
                        .background(ink, RoundedCornerShape(18.dp))
                        .clickable(remember { MutableInteractionSource() }, null, onClick = onManage)
                        .padding(horizontal = 16.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text("Kelola", style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold, color = categoryColor))
                    Spacer(Modifier.width(6.dp))
                    Icon(Icons.AutoMirrored.Rounded.ArrowForward, null, Modifier.size(15.dp), tint = categoryColor)
                }
            }
        }
        if (subtitle != null) {
            Spacer(Modifier.height(14.dp))
            Row(
                Modifier
                    .background(ink.copy(alpha = 0.08f), RoundedCornerShape(10.dp))
                    .padding(horizontal = 12.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Outlined.AccountBalanceWallet, null, Modifier.size(14.dp), tint = ink)
                Spacer(Modifier.width(6.dp))
                Text(
                    subtitle,
                    modifier = Modifier.weight(1f, fill = false),
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.5.sp, fontWeight = FontWeight.Bold, color = ink.copy(alpha = 0.85f)),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}
