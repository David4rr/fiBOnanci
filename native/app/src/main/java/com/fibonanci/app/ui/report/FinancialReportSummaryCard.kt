package com.fibonanci.app.ui.report

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.domain.FinancialReportData
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import java.util.Locale

private fun buildUnifiedSlices(data: FinancialReportData): List<UnifiedDonutSlice> {
    val totalFlow = data.totalIncome + data.totalExpense
    if (totalFlow <= 0) return emptyList()
    val slices = mutableListOf<UnifiedDonutSlice>()
    data.incomeByCategory.forEachIndexed { i, c ->
        slices.add(
            UnifiedDonutSlice(
                categoryId = "in_${c.categoryId}", name = c.name, amount = c.amount,
                percentage = (c.amount / totalFlow) * 100.0, txCount = c.txCount,
                isIncome = true, color = CategoryDonutChart.resolveSliceColor(c.colorHex, true, i),
            ),
        )
    }
    data.expenseByCategory.forEachIndexed { i, c ->
        slices.add(
            UnifiedDonutSlice(
                categoryId = "out_${c.categoryId}", name = c.name, amount = c.amount,
                percentage = (c.amount / totalFlow) * 100.0, txCount = c.txCount,
                isIncome = false, color = CategoryDonutChart.resolveSliceColor(c.colorHex, false, i),
            ),
        )
    }
    return slices
}

@Composable
fun FinancialReportSummaryCard(data: FinancialReportData) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    var selectedSliceIndex by remember { mutableStateOf<Int?>(null) }
    val slices = buildUnifiedSlices(data)

    Column(
        Modifier
            .fillMaxWidth()
            .background(Color.White.copy(alpha = 0.03f), RoundedCornerShape(20.dp))
            .border(1.dp, Color.White.copy(alpha = 0.06f), RoundedCornerShape(20.dp))
            .padding(horizontal = 18.dp, vertical = 20.dp),
    ) {
        Text(
            "ARUS KAS BERSIH (${data.period.label.uppercase()})",
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.W600, color = AppColors.textMuted, letterSpacing = 0.6.sp),
        )
        Spacer(Modifier.height(12.dp))
        CategoryDonutChart(
            slices = slices,
            totalIncome = data.totalIncome,
            totalExpense = data.totalExpense,
            savingsRate = data.savingsRate,
            selectedIndex = selectedSliceIndex,
            onSelectIndex = { selectedSliceIndex = it },
        )
        Spacer(Modifier.height(16.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            MinimalMetric("Pemasukan", "+${AppCurrency.format(data.totalIncome, currency)}", AppColors.neoMint, Modifier.weight(1f))
            Box(Modifier.width(1.dp).height(28.dp).background(Color.White.copy(alpha = 0.06f)))
            MinimalMetric("Pengeluaran", "-${AppCurrency.format(data.totalExpense, currency)}", AppColors.neoCoral, Modifier.weight(1f))
        }
        if (slices.isNotEmpty()) {
            Spacer(Modifier.height(16.dp))
            HorizontalDivider(thickness = Dp.Hairline, color = Color.White.copy(alpha = 0.06f))
            Spacer(Modifier.height(8.dp))
            slices.forEachIndexed { i, item ->
                SliceRow(
                    item = item,
                    index = i,
                    formattedAmt = AppCurrency.format(item.amount, currency),
                    isSelected = selectedSliceIndex == i,
                    onTap = { selectedSliceIndex = if (selectedSliceIndex == i) null else i },
                )
            }
        }
    }
}

@Composable
private fun MinimalMetric(label: String, value: String, dotColor: Color, modifier: Modifier) {
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
            Box(Modifier.size(6.dp).background(dotColor, CircleShape))
            Spacer(Modifier.width(6.dp))
            Text(label, style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.W500, color = AppColors.textMuted))
        }
        Spacer(Modifier.height(4.dp))
        Text(
            value,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite, fontFeatureSettings = "tnum"),
        )
    }
}

@Composable
private fun SliceRow(item: UnifiedDonutSlice, index: Int, formattedAmt: String, isSelected: Boolean, onTap: () -> Unit) {
    val sign = if (item.isIncome) "+" else "-"
    val amountColor = if (item.isIncome) AppColors.neoMint else AppColors.textWhite
    val bg by animateColorAsState(
        if (isSelected) Color.White.copy(alpha = 0.06f) else Color.Transparent,
        tween(160, easing = LinearEasing),
        label = "sliceRowBg",
    )
    Row(
        Modifier
            .testTag("report_category_row_$index")
            .fillMaxWidth()
            .pointerInput(onTap) { detectTapGestures { onTap() } }
            .padding(vertical = 2.dp)
            .background(bg, RoundedCornerShape(10.dp))
            .padding(horizontal = 8.dp, vertical = 7.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(Modifier.size(7.dp).background(item.color, CircleShape))
        Spacer(Modifier.width(10.dp))
        Text(
            item.name,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.5.sp, fontWeight = if (isSelected) FontWeight.W700 else FontWeight.W500, color = AppColors.textWhite),
            modifier = Modifier.weight(1f),
        )
        Text(
            "$sign$formattedAmt",
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, fontWeight = FontWeight.W600, color = amountColor, fontFeatureSettings = "tnum"),
        )
        Spacer(Modifier.width(8.dp))
        Text(
            "${String.format(Locale.US, "%.0f", item.percentage)}%",
            textAlign = TextAlign.End,
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.W500, color = AppColors.textMuted, fontFeatureSettings = "tnum"),
            modifier = Modifier.width(34.dp),
        )
    }
}
