package com.fibonanci.app.ui.wallet

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.common.PeekableBalanceText
import com.fibonanci.app.ui.dashboard.TrendSplineChart
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import com.fibonanci.app.ui.walletdetail.WalletCashflowSummary

@Composable
fun WalletTotalBalanceCard(
    totalRealBalance: Double,
    monthlyIncome: Double = 0.0,
    monthlyExpense: Double = 0.0,
    incomeSeries: List<Double> = emptyList(),
    expenseSeries: List<Double> = emptyList(),
    dateLabels: List<String> = emptyList(),
    showChart: Boolean = false,
    currencyFormatter: (Double) -> String,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier
            .padding(start = 20.dp, top = 14.dp, end = 20.dp)
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, RoundedCornerShape(20.dp))
            .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(20.dp))
            .padding(start = 18.dp, top = 16.dp, end = 18.dp, bottom = 14.dp),
    ) {
        Row(verticalAlignment = Alignment.Top) {
            Column(Modifier.weight(1f)) {
                Text(
                    "TOTAL SALDO RIIL",
                    style = AppTypography.badgeLabel.copy(
                        color = AppColors.textMuted,
                        fontSize = 9.5.sp,
                        letterSpacing = 0.8.sp,
                    ),
                )
                Spacer(Modifier.height(4.dp))
                PeekableBalanceText(
                    text = currencyFormatter(totalRealBalance),
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        color = AppColors.neoChartreuse,
                        fontSize = 21.sp,
                        fontWeight = FontWeight.W800,
                        letterSpacing = (-0.5).sp,
                        fontFeatureSettings = "tnum",
                    ),
                )
            }
            Spacer(Modifier.width(12.dp))
            WalletCashflowSummary(monthlyIncome, monthlyExpense, currencyFormatter)
        }
        if (showChart) {
            Spacer(Modifier.height(12.dp))
            HorizontalDivider(thickness = Dp.Hairline, color = Color.White.copy(alpha = 0.06f))
            Spacer(Modifier.height(10.dp))
            TrendSplineChart(
                incomeValues = incomeSeries,
                expenseValues = expenseSeries,
                labels = dateLabels,
                headline = "Tren Arus Kas (Semua Rekening)",
                subtitle = "30 Hari",
                height = 74.dp,
                embedded = true,
            )
        }
    }
}
