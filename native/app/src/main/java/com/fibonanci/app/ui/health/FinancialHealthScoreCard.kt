package com.fibonanci.app.ui.health

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
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
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.domain.FinancialHealthReport
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.dashboard.FolderTabBorderPainter
import com.fibonanci.app.ui.dashboard.FolderTabClipper
import com.fibonanci.app.ui.profile.ProfileWaveChartPainter
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

private val clipper = FolderTabClipper(tabWidthFactor = 0.56f, cornerRadius = 24f, stepDepth = 18f)
private val borderPainter = FolderTabBorderPainter(clipper = clipper, borderColor = Color(0xFF262936), borderWidth = 1.1f)

@Composable
fun FinancialHealthScoreCard(report: FinancialHealthReport) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val isHealthyTier = report.overallScore >= 70
    val accent = if (isHealthyTier) AppColors.neoChartreuse else if (report.overallScore >= 50) Color(0xFFFBBF24) else AppColors.neoCoral

    Box(
        Modifier
            .fillMaxWidth()
            .drawWithContent {
                drawContent()
                with(borderPainter) { paint() }
            },
    ) {
        Column(
            Modifier
                .fillMaxWidth()
                .clip(clipper)
                .background(AppColors.carbonBlack)
                .padding(start = 20.dp, top = 18.dp, end = 20.dp, bottom = 20.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.size(6.dp).background(accent, CircleShape))
                Spacer(Modifier.width(7.dp))
                Text(
                    "INDEKS • ${report.tierLabel.uppercase()}",
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.W800, color = accent, letterSpacing = 0.9.sp),
                )
            }
            Spacer(Modifier.height(18.dp))
            Row(verticalAlignment = Alignment.Bottom) {
                Column(Modifier.weight(1f)) {
                    Row {
                        Text(
                            "${report.overallScore}",
                            style = TextStyle(
                                fontFamily = PlusJakartaSans,
                                fontSize = 44.sp,
                                fontWeight = FontWeight.W800,
                                color = AppColors.textWhite,
                                letterSpacing = (-1.6).sp,
                                lineHeight = 44.sp,
                                fontFeatureSettings = "tnum",
                            ),
                            modifier = Modifier.alignByBaseline(),
                        )
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "/ 100",
                            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W600, color = AppColors.textMuted, fontFeatureSettings = "tnum"),
                            modifier = Modifier.alignByBaseline(),
                        )
                    }
                    Spacer(Modifier.height(8.dp))
                    Text(
                        report.tierHeadline,
                        style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W500, color = Color.White.copy(alpha = 0.78f), lineHeight = (13 * 1.35).sp),
                    )
                }
                Spacer(Modifier.width(16.dp))
                Canvas(Modifier.size(width = 84.dp, height = 36.dp)) {
                    with(
                        ProfileWaveChartPainter(
                            scores = listOf(
                                report.emergencyRunway.score,
                                report.fixedCommitment.score,
                                report.savingsMargin.score,
                                report.spendPacing.score,
                                report.overallScore.toDouble(),
                            ),
                        ),
                    ) { paint() }
                }
            }
            Spacer(Modifier.height(20.dp))
            Row {
                AssetStat("Likuiditas Rekening", AppCurrency.format(report.totalLiquidAssets, currency), Modifier.weight(1f))
                Spacer(Modifier.width(16.dp))
                AssetStat("Cadangan Kantong", AppCurrency.format(report.totalPocketsAmount, currency), Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun AssetStat(label: String, value: String, modifier: Modifier) {
    Column(modifier) {
        Text(label, style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.W500, color = AppColors.textMuted))
        Spacer(Modifier.height(3.dp))
        Text(
            value,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite, fontFeatureSettings = "tnum"),
        )
    }
}

@Composable
fun FinancialHealthRecommendationsSection(recommendations: List<String>) {
    Column {
        Text(
            "CATATAN & TINDAKAN",
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.W700, color = Color.White.copy(alpha = 0.38f), letterSpacing = 1.0.sp),
        )
        Spacer(Modifier.height(12.dp))
        recommendations.forEachIndexed { i, rec ->
            Row(Modifier.padding(vertical = 7.dp)) {
                Text(
                    "0${i + 1}",
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.neoChartreuse, fontSize = 11.sp, fontWeight = FontWeight.W700, fontFeatureSettings = "tnum"),
                )
                Spacer(Modifier.width(12.dp))
                Text(
                    rec,
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.5.sp, color = Color.White.copy(alpha = 0.82f), lineHeight = (12.5 * 1.45).sp, fontWeight = FontWeight.W400),
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}
