package com.fibonanci.app.ui.report

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.domain.FinancialReportService
import com.fibonanci.app.domain.ReportPeriod
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun FinancialReportTab(state: FinanceState) {
    var selectedPeriod by remember { mutableStateOf(ReportPeriod.thisMonth) }
    val report = FinancialReportService.generate(
        wallets = state.wallets,
        pockets = state.pockets,
        categories = state.categories,
        transactions = state.transactions,
        subscriptions = state.subscriptions,
        period = selectedPeriod,
    )

    LazyColumn(contentPadding = PaddingValues(start = 20.dp, top = 8.dp, end = 20.dp, bottom = 36.dp)) {
        item {
            Row(
                Modifier
                    .fillMaxWidth()
                    .background(Color.White.copy(alpha = 0.04f), RoundedCornerShape(12.dp))
                    .padding(3.dp),
            ) {
                for (period in ReportPeriod.entries) {
                    val isSelected = period == selectedPeriod
                    val bg by animateColorAsState(
                        if (isSelected) Color.White.copy(alpha = 0.10f) else Color.Transparent,
                        tween(180, easing = LinearEasing),
                        label = "periodBg",
                    )
                    Box(
                        Modifier
                            .weight(1f)
                            .testTag("report_period_${period.name}")
                            .pointerInput(period) { detectTapGestures { selectedPeriod = period } }
                            .background(bg, RoundedCornerShape(9.dp))
                            .padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            period.label,
                            style = TextStyle(
                                fontFamily = PlusJakartaSans,
                                fontSize = 11.5.sp,
                                fontWeight = if (isSelected) FontWeight.W700 else FontWeight.W500,
                                color = if (isSelected) AppColors.textWhite else AppColors.textMuted,
                            ),
                        )
                    }
                }
            }
        }
        item { Spacer(Modifier.height(16.dp)) }
        item { FinancialReportSummaryCard(data = report) }
        item { Spacer(Modifier.height(14.dp)) }
        item { FinancialReportBreakdownCards(data = report) }
    }
}
