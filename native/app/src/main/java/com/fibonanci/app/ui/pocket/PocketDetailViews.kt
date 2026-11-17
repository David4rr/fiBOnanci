package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Elderly
import androidx.compose.material.icons.outlined.Flag
import androidx.compose.material.icons.outlined.Savings
import androidx.compose.material.icons.outlined.Shield
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.dashboard.BentoFolderCard
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlin.math.roundToInt

fun getPocketIcon(type: String): ImageVector = when (type) {
    "savings" -> Icons.Outlined.Savings
    "retirement" -> Icons.Outlined.Elderly
    "emergency" -> Icons.Outlined.Shield
    else -> Icons.Outlined.Flag
}

fun getPocketTypeLabel(type: String): String = when (type) {
    "savings" -> "Simpanan"
    "retirement" -> "Masa Tua"
    "emergency" -> "Dana Darurat"
    else -> "Target / Impian"
}

@Composable
fun PocketDetailHeader(
    pocket: PocketEntry,
    pocketColor: Color,
    themeConfig: PocketCardThemeConfig? = null,
    fmt: (Double) -> String,
    transactions: List<TransactionEntry> = emptyList(),
) {
    val config = themeConfig ?: PocketCardThemeConfig.resolve(pocket, 0)
    val target = pocket.targetAmount
    val latestCurrent = pocket.currentAmount
    val hasTarget = target != null && target > 0
    val latestProgress = if (hasTarget) (latestCurrent / target!!).coerceIn(0.0, 1.0) else null

    val isNeoPastel = config.backgroundColor == AppColors.neoCoral ||
        config.backgroundColor == AppColors.neoChartreuse ||
        config.backgroundColor == AppColors.neoMint ||
        config.backgroundColor == AppColors.neoCyan
    val isDark = if (isNeoPastel) false else isDarkColor(config.backgroundColor)
    val textScale = LocalDensity.current.fontScale.coerceIn(1f, 1.4f)
    val cardHeight = (172f * textScale).coerceIn(172f, 216f)

    BentoFolderCard(
        backgroundColor = config.backgroundColor,
        gradient = null,
        textColor = config.primaryTextColor,
        subtitleColor = config.secondaryTextColor,
        iconColor = config.iconColor,
        iconBgColor = config.iconBgColor,
        height = cardHeight.dp,
        padding = PaddingValues(horizontal = 18.dp, vertical = 14.dp),
        iconData = getPocketIcon(pocket.type),
        topTrailing = if (hasTarget) {
            {
                Box(
                    modifier = Modifier
                        .background(config.iconBgColor, RoundedCornerShape(12.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp),
                ) {
                    Text(
                        "${(latestProgress!! * 100).roundToInt()}%",
                        style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold, color = config.primaryTextColor),
                    )
                }
            }
        } else {
            null
        },
        title = fmt(latestCurrent),
        subtitleWidget = {
            Column {
                Text(
                    pocket.name,
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = config.secondaryTextColor,
                        letterSpacing = (-0.2).sp,
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    if (hasTarget) "Target: ${fmt(target!!)}" else "Total Terkumpul di Kantong",
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = config.tertiaryTextColor),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        },
        progress = latestProgress?.toFloat(),
        rightWidget = {
            PocketCashflowChart(
                pocket = pocket,
                transactions = transactions,
                isDark = isDark,
                primaryColor = config.primaryTextColor,
                secondaryColor = config.secondaryTextColor,
                accentColor = config.iconBgColor,
                fmt = fmt,
            )
        },
    )
}
