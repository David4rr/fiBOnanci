package com.fibonanci.app.ui.health

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.domain.HealthPillarMetric
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import java.util.Locale

@Composable
fun FinancialHealthPillarCard(
    metric: HealthPillarMetric,
    icon: ImageVector? = null,
    accentColor: Color? = null,
) {
    val progress = (metric.score / 100.0).coerceIn(0.0, 1.0).toFloat()
    val barColor = if (metric.isHealthy) AppColors.neoChartreuse else AppColors.neoCoral

    Column(Modifier.fillMaxWidth().padding(vertical = 10.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.padding(end = 8.dp).size(6.dp).background(barColor, CircleShape))
            Text(
                metric.title,
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.5.sp, fontWeight = FontWeight.W600, color = AppColors.textWhite),
                modifier = Modifier.weight(1f).alignByBaseline(),
            )
            Spacer(Modifier.width(12.dp))
            Text(
                metric.displayValue,
                style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textWhite, fontWeight = FontWeight.W700, fontSize = 13.5.sp, fontFeatureSettings = "tnum"),
                modifier = Modifier.alignByBaseline(),
            )
        }
        Spacer(Modifier.height(8.dp))
        Box(
            Modifier.fillMaxWidth().height(3.dp).clip(RoundedCornerShape(2.dp)).background(Color.White.copy(alpha = 0.06f)),
        ) {
            Box(Modifier.fillMaxWidth(progress).fillMaxHeight().background(barColor))
        }
        Spacer(Modifier.height(6.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                metric.description,
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.5.sp, color = AppColors.textMuted, fontWeight = FontWeight.W400),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(12.dp))
            Text(
                "${metric.benchmark} • ${String.format(Locale.US, "%.0f", metric.score)}/100",
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, color = Color.White.copy(alpha = 0.45f), fontWeight = FontWeight.W500, fontFeatureSettings = "tnum"),
            )
        }
    }
}
