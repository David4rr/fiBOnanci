package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.material.icons.rounded.ArrowDownward
import androidx.compose.material.icons.rounded.ArrowUpward
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.LocalFinance
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.common.PeekableBalanceText
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun PocketStockChartHeader(
    displayBalance: Double,
    themeColor: Color,
    isUpward: Boolean,
    pctFormatted: String,
    deltaFormatted: String,
    pocketsCount: Int,
    scrubbedIndex: Int?,
    scrubbedLabel: String?,
    selectedFilter: String,
    filters: List<String>,
    onFilterChanged: (String) -> Unit,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                "TOTAL DANA TERKUMPUL",
                style = AppTypography.badgeLabel.copy(color = AppColors.textMuted, fontSize = 9.5.sp, letterSpacing = 0.8.sp),
            )
            Spacer(Modifier.height(4.dp))
            PeekableBalanceText(
                text = AppCurrency.format(displayBalance, state.profile.currency),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    color = themeColor,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = (-0.5).sp,
                    fontFeatureSettings = "tnum",
                ),
            )
            Spacer(Modifier.height(4.dp))
            if (scrubbedIndex != null) {
                Text(
                    if (scrubbedLabel != null) "Titik: $scrubbedLabel" else "Titik pantau",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        color = AppColors.textWhite.copy(alpha = 0.85f),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                    ),
                )
            } else {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Row(
                        modifier = Modifier
                            .background(themeColor.copy(alpha = 0.14f), RoundedCornerShape(6.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Icon(
                            if (isUpward) Icons.Rounded.ArrowUpward else Icons.Rounded.ArrowDownward,
                            contentDescription = null,
                            tint = themeColor,
                            modifier = Modifier.size(11.dp),
                        )
                        Spacer(Modifier.width(2.dp))
                        Text(
                            pctFormatted,
                            style = TextStyle(
                                fontFamily = PlusJakartaSans,
                                color = themeColor,
                                fontSize = 10.5.sp,
                                fontWeight = FontWeight.ExtraBold,
                                fontFeatureSettings = "tnum",
                            ),
                        )
                    }
                    Spacer(Modifier.width(6.dp))
                    Text(
                        "$deltaFormatted ($pocketsCount kantong)",
                        style = AppTypography.listSubtitle.copy(fontSize = 11.sp),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f),
                    )
                }
            }
        }
        Row(
            modifier = Modifier
                .background(AppColors.canvasBg, RoundedCornerShape(10.dp))
                .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(10.dp))
                .padding(2.dp),
        ) {
            filters.forEach { filter ->
                val isSelected = selectedFilter == filter
                Box(
                    modifier = Modifier
                        .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { onFilterChanged(filter) }
                        .background(if (isSelected) themeColor.copy(alpha = 0.18f) else Color.Transparent, RoundedCornerShape(8.dp))
                        .padding(horizontal = 7.dp, vertical = 3.5.dp),
                ) {
                    Text(
                        filter,
                        style = TextStyle(
                            fontFamily = PlusJakartaSans,
                            color = if (isSelected) themeColor else AppColors.textMuted,
                            fontSize = 10.5.sp,
                            fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.SemiBold,
                        ),
                    )
                }
            }
        }
    }
}
