package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.EventRepeat
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlin.math.roundToInt

private val milestones = listOf(1, 5, 10, 15, 20, 25, 31)
private const val THUMB_RADIUS = 14f

// bespoke tactile obsidian & neon glowing track slider for due day selection (1..31).
@Composable
fun SubscriptionDueDaySlider(
    dueDay: Int,
    onDayChanged: (Int) -> Unit,
) {
    val haptic = LocalHapticFeedback.current
    val currentDay by rememberUpdatedState(dueDay)
    val currentOnChanged by rememberUpdatedState(onDayChanged)

    Column {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                "TANGGAL JATUH TEMPO",
                modifier = Modifier.weight(1f),
                style = AppTypography.badgeLabel.copy(color = AppColors.textMuted, letterSpacing = 0.8.sp),
                overflow = TextOverflow.Ellipsis,
                maxLines = 1,
            )
            Spacer(Modifier.width(8.dp))
            val chipShape = RoundedCornerShape(10.dp)
            Row(
                modifier = Modifier
                    .background(AppColors.neoChartreuse.copy(alpha = 0.12f), chipShape)
                    .border(1.dp, AppColors.neoChartreuse.copy(alpha = 0.35f), chipShape)
                    .padding(horizontal = 10.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Rounded.EventRepeat, contentDescription = null, modifier = Modifier.size(12.dp), tint = AppColors.neoChartreuse)
                Spacer(Modifier.width(5.dp))
                Text(
                    "Tgl $dueDay setiap bulan",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.W800,
                        color = AppColors.neoChartreuse,
                        fontFeatureSettings = "tnum",
                    ),
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
            val trackWidth = maxWidth.value
            val usableWidth = trackWidth - THUMB_RADIUS * 2
            val fraction = ((dueDay - 1) / 30f).coerceIn(0f, 1f)
            val thumbX = THUMB_RADIUS + fraction * usableWidth

            fun handleInteraction(localPx: Offset, density: Float) {
                if (usableWidth <= 0) return
                val dx = (localPx.x / density - THUMB_RADIUS).coerceIn(0f, usableWidth)
                val day = (1 + dx / usableWidth * 30).roundToInt().coerceIn(1, 31)
                if (day != currentDay) {
                    haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                    currentOnChanged(day)
                }
            }

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(40.dp)
                    .pointerInput(trackWidth) {
                        detectTapGestures(onPress = { handleInteraction(it, density) })
                    }
                    .pointerInput(trackWidth) {
                        detectHorizontalDragGestures(
                            onDragStart = { handleInteraction(it, density) },
                        ) { change, _ -> handleInteraction(change.position, density) }
                    },
                contentAlignment = Alignment.CenterStart,
            ) {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(12.dp)
                        .background(AppColors.canvasInputSearch, RoundedCornerShape(6.dp))
                        .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(6.dp)),
                )
                val rightRadius = if (thumbX >= trackWidth - 2) 6.dp else 2.dp
                Box(
                    Modifier
                        .width(thumbX.dp)
                        .height(12.dp)
                        .background(
                            Brush.horizontalGradient(listOf(Color(0x33D4F442), AppColors.neoChartreuse)),
                            RoundedCornerShape(topStart = 6.dp, bottomStart = 6.dp, topEnd = rightRadius, bottomEnd = rightRadius),
                        ),
                )
                for (m in milestones) {
                    Box(
                        Modifier
                            .offset(x = (THUMB_RADIUS + ((m - 1) / 30f) * usableWidth - 1.5f).dp)
                            .size(3.dp, 8.dp)
                            .background(
                                if (m <= dueDay) AppColors.textDarkPrimary.copy(alpha = 0.6f) else AppColors.textMuted.copy(alpha = 0.35f),
                                RoundedCornerShape(1.5.dp),
                            ),
                    )
                }
                Box(
                    Modifier
                        .offset(x = (thumbX - THUMB_RADIUS).dp)
                        .size((THUMB_RADIUS * 2).dp)
                        .shadow(10.dp, CircleShape, ambientColor = AppColors.neoChartreuse.copy(alpha = 0.45f), spotColor = AppColors.neoChartreuse.copy(alpha = 0.45f))
                        .background(AppColors.neoChartreuse, CircleShape)
                        .border(2.dp, AppColors.textDarkPrimary, CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Box(Modifier.size(6.dp).background(AppColors.textDarkPrimary, CircleShape))
                }
            }
        }
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            for (m in milestones) {
                Text(
                    "$m",
                    modifier = Modifier.clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                        haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                        onDayChanged(m)
                    },
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 10.sp,
                        fontWeight = if (m == dueDay) FontWeight.W800 else FontWeight.W600,
                        color = if (m == dueDay) AppColors.neoChartreuse else AppColors.textMuted.copy(alpha = 0.6f),
                        fontFeatureSettings = "tnum",
                    ),
                )
            }
        }
    }
}
