package com.fibonanci.app.ui.wallet

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.BiasAlignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

private val segmentCurve = CubicBezierEasing(0.22f, 1.0f, 0.36f, 1.0f)
private val easeOutCubic = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1.0f)

@Composable
fun WalletSegmentedToggle(
    selectedSegment: Int,
    walletCount: Int,
    pocketCount: Int,
    onSegmentChanged: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val bias by animateFloatAsState(
        if (selectedSegment == 0) -1f else 1f,
        tween(280, easing = segmentCurve),
        label = "segmentBias",
    )
    Box(
        modifier
            .fillMaxWidth()
            .height(48.dp)
            .background(AppColors.canvasCardSurface, RoundedCornerShape(16.dp))
            .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(16.dp))
            .padding(4.dp),
    ) {
        Box(
            Modifier
                .align(BiasAlignment(bias, 0f))
                .fillMaxWidth(0.5f)
                .fillMaxHeight()
                .background(AppColors.neoChartreuse, RoundedCornerShape(12.dp)),
        )
        Row(Modifier.fillMaxSize()) {
            SegmentButton(0, "Rekening Utama ($walletCount)", selectedSegment == 0, onSegmentChanged)
            SegmentButton(1, "Kantong Tabungan ($pocketCount)", selectedSegment == 1, onSegmentChanged)
        }
    }
}

@Composable
private fun RowScope.SegmentButton(index: Int, label: String, isSelected: Boolean, onSegmentChanged: (Int) -> Unit) {
    val color by animateColorAsState(
        if (isSelected) AppColors.textDarkPrimary else AppColors.textMuted,
        tween(220, easing = easeOutCubic),
        label = "segmentText",
    )
    Box(
        Modifier
            .weight(1f)
            .fillMaxHeight()
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                onSegmentChanged(index)
            },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 13.sp,
                fontWeight = if (isSelected) FontWeight.W800 else FontWeight.W600,
                color = color,
            ),
        )
    }
}
