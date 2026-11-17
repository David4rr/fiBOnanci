package com.fibonanci.app.ui.wallet

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun WalletTypeSelector(
    selectedType: String,
    onTypeChanged: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(modifier.fillMaxWidth()) {
        TypePill("Bank", "bank", selectedType, onTypeChanged)
        Spacer(Modifier.width(8.dp))
        TypePill("E-Wallet", "ewallet", selectedType, onTypeChanged)
        Spacer(Modifier.width(8.dp))
        TypePill("Kas Tunai", "cash", selectedType, onTypeChanged)
    }
}

@Composable
private fun RowScope.TypePill(label: String, value: String, selectedType: String, onTypeChanged: (String) -> Unit) {
    val isSelected = selectedType == value
    val haptics = LocalHapticFeedback.current
    val bg by animateColorAsState(
        if (isSelected) AppColors.neoChartreuse else AppColors.canvasInputSearch,
        tween(180),
        label = "pillBg",
    )
    val borderColor by animateColorAsState(
        if (isSelected) AppColors.neoChartreuse else AppColors.canvasBorder,
        tween(180),
        label = "pillBorder",
    )
    Box(
        Modifier
            .weight(1f)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
                onTypeChanged(value)
            }
            .background(bg, RoundedCornerShape(14.dp))
            .border(1.2.dp, borderColor, RoundedCornerShape(14.dp))
            .padding(vertical = 10.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = AppTypography.listTitle.copy(
                color = if (isSelected) AppColors.textDarkPrimary else AppColors.textWhite,
                fontWeight = if (isSelected) FontWeight.W800 else FontWeight.W500,
                fontSize = 13.sp,
            ),
        )
    }
}
