package com.fibonanci.app.ui.profile

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material.icons.rounded.EventRepeat
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.domain.FinancialHealthReport
import com.fibonanci.app.domain.SafeToSpendMetrics
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.health.showFinancialHealthModal
import com.fibonanci.app.ui.theme.AppColors

@Composable
internal fun ProfileStat(icon: ImageVector, value: String, unit: String) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, contentDescription = null, tint = AppColors.neoChartreuse, modifier = Modifier.size(14.5.dp))
            Spacer(Modifier.width(4.dp))
            Text(value, style = jakarta(14.sp, FontWeight.Bold, Color.White, tabular = true))
        }
        Text(unit, style = jakarta(10.sp, FontWeight.Medium, AppColors.textMuted))
    }
}

@Composable
fun ProfileActiveCardBody(
    metrics: SafeToSpendMetrics,
    healthReport: FinancialHealthReport,
    wallets: Int,
    txs: Int,
    subs: Int,
    burnFormatted: String,
    healthScore: Int,
    onHealthDetails: (() -> Unit)? = null,
) {
    val host = LocalModalHost.current
    Column(Modifier.fillMaxWidth()) {
        Spacer(Modifier.height(12.dp))
        ProfileFinancialTimelinePill(
            realBalance = metrics.totalRealBalance,
            pendingBills = metrics.pendingBills,
            safeToSpend = metrics.safeToSpendMonthly,
        )
        Spacer(Modifier.height(14.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Row(modifier = Modifier.weight(1f), verticalAlignment = Alignment.CenterVertically) {
                // fitted box scale-down: shrink the font until it fits
                BasicText(
                    burnFormatted,
                    style = jakarta(30.sp, FontWeight.ExtraBold, Color(0xFFEEEEEE), letterSpacing = (-0.8).sp, tabular = true),
                    maxLines = 1,
                    softWrap = false,
                    autoSize = TextAutoSize.StepBased(minFontSize = 6.sp, maxFontSize = 30.sp),
                    modifier = Modifier.weight(1f, fill = false),
                )
                Spacer(Modifier.width(6.dp))
                Column {
                    Canvas(Modifier.size(15.dp, 14.dp)) { with(FinancialShieldPainter()) { paint() } }
                    Spacer(Modifier.height(2.dp))
                    Text("Aman", style = jakarta(10.sp, FontWeight.SemiBold, Color.White))
                    Text("Harian", style = jakarta(9.sp, FontWeight.Medium, AppColors.textMuted))
                }
            }
            Column(
                horizontalAlignment = Alignment.End,
                modifier = Modifier.clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                ) { (onHealthDetails ?: { showFinancialHealthModal(host) })() },
            ) {
                Row(verticalAlignment = Alignment.Bottom) {
                    Text("$healthScore", style = jakarta(20.sp, FontWeight.ExtraBold, Color.White, tabular = true), modifier = Modifier.alignByBaseline())
                    Spacer(Modifier.width(2.dp))
                    Text("SKOR", style = jakarta(9.5.sp, FontWeight.Bold, AppColors.textMuted), modifier = Modifier.alignByBaseline())
                }
                Spacer(Modifier.height(2.dp))
                val scores = listOf(
                    healthReport.emergencyRunway.score,
                    healthReport.fixedCommitment.score,
                    healthReport.savingsMargin.score,
                    healthReport.spendPacing.score,
                    healthScore.toDouble(),
                )
                Canvas(Modifier.size(64.dp, 24.dp)) { with(ProfileWaveChartPainter(scores = scores)) { paint() } }
            }
        }
        Spacer(Modifier.height(14.dp))
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            ProfileStat(Icons.Outlined.AccountBalanceWallet, "$wallets", "Rekening")
            ProfileStat(Icons.Rounded.SwapHoriz, "$txs", "Transaksi")
            ProfileStat(Icons.Rounded.EventRepeat, "$subs", "Tagihan Rutin")
        }
    }
}
