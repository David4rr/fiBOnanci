package com.fibonanci.app.ui.transaction

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

object DailyDateHelper {
    private val idLocale = Locale.forLanguageTag("id-ID")

    private fun keyOf(d: LocalDate): String =
        "${d.year.toString().padStart(4, '0')}-${d.monthValue.toString().padStart(2, '0')}-${d.dayOfMonth.toString().padStart(2, '0')}"

    fun getAllDateKeys(dayGroups: Map<String, List<TransactionEntry>>): List<String> {
        val today = LocalDate.now()
        val keysSet = linkedSetOf<String>()
        for (i in 6 downTo 0) keysSet.add(keyOf(today.minusDays(i.toLong())))
        keysSet.addAll(dayGroups.keys)
        keysSet.add(keyOf(today))
        return keysSet.sorted()
    }

    fun groupByDay(list: List<TransactionEntry>): Map<String, List<TransactionEntry>> {
        val map = linkedMapOf<String, MutableList<TransactionEntry>>()
        for (tx in list) map.getOrPut(keyOf(tx.transactionDate.toLocalDate())) { mutableListOf() }.add(tx)
        return map
    }

    fun formatDayTabLabel(dateKey: String): String {
        val parts = dateKey.split("-")
        if (parts.size != 3) return dateKey
        val date = LocalDate.of(parts[0].toInt(), parts[1].toInt(), parts[2].toInt())
        val now = LocalDate.now()
        if (date == now) return "Hari Ini"
        if (date == now.minusDays(1)) return "Kemarin"
        if (date.year != now.year) return date.format(DateTimeFormatter.ofPattern("d MMM yy", idLocale))
        return date.format(DateTimeFormatter.ofPattern("d MMM", idLocale))
    }
}

@Composable
fun DailyCalendarBar(
    scrollController: LazyListState,
    sortedDays: List<String>,
    selectedIndex: Int,
    dayGroups: Map<String, List<TransactionEntry>>,
    onDaySelected: (Int) -> Unit,
) {
    val haptic = LocalHapticFeedback.current
    LazyRow(
        state = scrollController,
        modifier = Modifier.fillMaxWidth().height(48.dp).padding(vertical = 4.dp),
        contentPadding = PaddingValues(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        itemsIndexed(sortedDays) { index, dateKey ->
            val isSelected = index == selectedIndex
            val count = dayGroups[dateKey]?.size ?: 0
            val label = DailyDateHelper.formatDayTabLabel(dateKey)
            val bg by animateColorAsState(
                if (isSelected) AppColors.neoChartreuse.copy(alpha = 0.12f) else Color.Transparent, tween(180), label = "dayBg",
            )
            val border by animateColorAsState(
                if (isSelected) AppColors.neoChartreuse else Color.Transparent, tween(180), label = "dayBorder",
            )
            Box(
                Modifier
                    .padding(horizontal = 4.dp)
                    .fillMaxHeight()
                    .clickable(remember { MutableInteractionSource() }, null) {
                        haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                        onDaySelected(index)
                    }
                    .background(bg)
                    .drawBehind {
                        val w = 2.dp.toPx()
                        drawLine(border, Offset(0f, size.height - w / 2), Offset(size.width, size.height - w / 2), w)
                    }
                    .padding(horizontal = 12.dp),
                contentAlignment = Alignment.Center,
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Start) {
                    Text(
                        label,
                        style = TextStyle(
                            fontFamily = PlusJakartaSans, fontSize = 12.sp,
                            fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.SemiBold,
                            color = if (isSelected) AppColors.textWhite else AppColors.textMuted,
                        ),
                    )
                    if (count > 0) {
                        Spacer(Modifier.width(6.dp))
                        Box(
                            Modifier
                                .background(
                                    Color.White.copy(alpha = if (isSelected) 0.14f else 0.08f),
                                    RoundedCornerShape(6.dp),
                                )
                                .padding(horizontal = 5.dp, vertical = 1.dp),
                        ) {
                            Text(
                                "$count",
                                style = TextStyle(
                                    fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.Bold,
                                    color = if (isSelected) AppColors.textWhite else AppColors.textMuted,
                                ),
                            )
                        }
                    }
                }
            }
        }
    }
}
