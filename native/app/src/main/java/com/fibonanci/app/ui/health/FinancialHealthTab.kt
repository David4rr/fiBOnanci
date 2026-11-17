package com.fibonanci.app.ui.health

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.domain.FinancialHealthReport
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun FinancialHealthTab(
    report: FinancialHealthReport,
    scrollController: LazyListState? = null,
    padding: PaddingValues? = null,
    modifier: Modifier = Modifier,
) {
    LazyColumn(
        modifier,
        state = scrollController ?: rememberLazyListState(),
        contentPadding = padding ?: PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 40.dp),
    ) {
        item { FinancialHealthScoreCard(report = report) }
        item { Spacer(Modifier.height(28.dp)) }
        item {
            Text(
                "4 Pilar Rasio Keuangan",
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.W700,
                    color = Color.White.copy(alpha = 0.38f),
                    letterSpacing = 0.8.sp,
                ),
            )
        }
        item { Spacer(Modifier.height(8.dp)) }
        item { FinancialHealthPillarCard(metric = report.emergencyRunway) }
        item { FinancialHealthPillarCard(metric = report.fixedCommitment) }
        item { FinancialHealthPillarCard(metric = report.savingsMargin) }
        item { FinancialHealthPillarCard(metric = report.spendPacing) }
        item { Spacer(Modifier.height(24.dp)) }
        item { FinancialHealthRecommendationsSection(recommendations = report.recommendations) }
    }
}
