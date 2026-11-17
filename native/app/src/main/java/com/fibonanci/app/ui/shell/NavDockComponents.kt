package com.fibonanci.app.ui.shell

import android.view.HapticFeedbackConstants
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors

private val labelStyle = TextStyle(
    color = AppColors.neoChartreuse,
    fontSize = 11.5.sp,
    fontWeight = FontWeight.W700,
    letterSpacing = (-0.2).sp,
)

@Composable
fun NavItemWidget(
    isActive: Boolean,
    icon: ImageVector,
    activeIcon: ImageVector,
    label: String,
    onTap: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val view = LocalView.current
    val currentOnTap by rememberUpdatedState(onTap)
    var isPressed by remember { mutableStateOf(false) }

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.88f else if (isActive) 1.0f else 0.90f,
        animationSpec = tween(140, easing = EaseOut),
        label = "navItemScale",
    )
    val fill by animateColorAsState(
        targetValue = if (isActive) AppColors.neoChartreuse.copy(alpha = 0.16f) else Color.Transparent,
        animationSpec = tween(240, easing = EaseOutCubic),
        label = "navItemFill",
    )
    // the dart border lerps from null, i.e. fades in from a transparent stroke
    val borderColor by animateColorAsState(
        targetValue = if (isActive) AppColors.neoChartreuse.copy(alpha = 0.35f) else AppColors.neoChartreuse.copy(alpha = 0f),
        animationSpec = tween(240, easing = EaseOutCubic),
        label = "navItemBorder",
    )
    val shape = RoundedCornerShape(22.dp)

    Box(
        modifier
            .fillMaxWidth()
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        isPressed = true
                        tryAwaitRelease()
                        isPressed = false
                    },
                    onTap = {
                        view.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
                        currentOnTap()
                    },
                )
            }
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .padding(horizontal = 2.dp)
            .height(44.dp)
            .background(fill, shape)
            .border(1.dp, borderColor, shape)
            .padding(horizontal = 8.dp),
        contentAlignment = Alignment.Center,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                imageVector = if (isActive) activeIcon else icon,
                contentDescription = null,
                tint = if (isActive) AppColors.neoChartreuse else AppColors.textMuted,
                modifier = Modifier.size(20.dp),
            )
            if (isActive) {
                Spacer(Modifier.width(6.dp))
                Text(
                    text = label,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    softWrap = false,
                    style = LocalTextStyle.current.merge(labelStyle),
                    modifier = Modifier.weight(1f, fill = false),
                )
            }
        }
    }
}
