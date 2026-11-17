package com.fibonanci.app.ui.subscription

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AllInclusive
import androidx.compose.material.icons.rounded.Timelapse
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

// segmented toggle between routine subscription and installment / planned bill.
@Composable
fun SubscriptionTypeToggle(
    isInstallment: Boolean,
    onToggleInstallment: (Boolean) -> Unit,
) {
    val shape = RoundedCornerShape(16.dp)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColors.canvasInputSearch, shape)
            .border(1.dp, AppColors.canvasBorder, shape)
            .padding(4.dp),
    ) {
        TypePill("Langganan Rutin", Icons.Rounded.AllInclusive, !isInstallment, Modifier.weight(1f)) { onToggleInstallment(false) }
        Spacer(Modifier.width(4.dp))
        TypePill("Cicilan / Rencana", Icons.Rounded.Timelapse, isInstallment, Modifier.weight(1f)) { onToggleInstallment(true) }
    }
}

@Composable
private fun TypePill(title: String, icon: ImageVector, isSelected: Boolean, modifier: Modifier, onTap: () -> Unit) {
    val haptic = LocalHapticFeedback.current
    val spec = tween<Color>(180, easing = EaseOut)
    val bg by animateColorAsState(if (isSelected) AppColors.canvasCardSurface else Color.Transparent, spec, label = "pillBg")
    val border by animateColorAsState(if (isSelected) AppColors.canvasBorder else Color.Transparent, spec, label = "pillBorder")
    val shape = RoundedCornerShape(12.dp)
    Row(
        modifier = modifier
            .background(bg, shape)
            .border(1.dp, border, shape)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                onTap()
            }
            .padding(vertical = 9.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(15.dp), tint = if (isSelected) AppColors.neoChartreuse else AppColors.textMuted)
        Spacer(Modifier.width(6.dp))
        Text(
            title,
            modifier = Modifier.weight(1f, fill = false),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 12.sp,
                fontWeight = if (isSelected) FontWeight.W800 else FontWeight.W600,
                color = if (isSelected) AppColors.textWhite else AppColors.textMuted,
            ),
        )
    }
}
