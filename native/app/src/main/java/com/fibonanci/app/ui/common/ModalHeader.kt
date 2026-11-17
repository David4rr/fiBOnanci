package com.fibonanci.app.ui.common

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterExitState
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.EaseInOutCubic
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun ModalHeader(
    title: String,
    subtitle: String? = null,
    onClose: (() -> Unit)? = null,
    showCloseButton: Boolean = true,
    closeIcon: ImageVector = Icons.Rounded.KeyboardArrowDown,
    closeIconColor: Color = AppColors.textWhite,
    closeIconSize: Dp = 28.dp,
    leading: (@Composable () -> Unit)? = null,
    trailing: (@Composable () -> Unit)? = null,
    titleStyle: TextStyle? = null,
    subtitleStyle: TextStyle? = null,
    padding: PaddingValues = PaddingValues(bottom = 16.dp),
    modifier: Modifier = Modifier,
) {
    // default close == Navigator.pop of the enclosing modal
    val modalDismiss = LocalModalDismiss.current

    Row(modifier.padding(padding), verticalAlignment = Alignment.Top) {
        leading?.invoke()
        AnimatedContent(
            targetState = title to subtitle,
            modifier = Modifier.weight(1f),
            transitionSpec = { SmoothPageView.headerTitleTransition(260) },
            contentAlignment = Alignment.TopStart,
            label = "modalHeaderTitle",
        ) { (t, s) ->
            Column {
                Text(t, style = titleStyle ?: AppTypography.modalTitle)
                if (s != null) {
                    Spacer(Modifier.height(4.dp))
                    Text(s, style = subtitleStyle ?: AppTypography.modalSubtitle)
                }
            }
        }
        if (trailing != null) {
            trailing()
        } else if (showCloseButton) {
            AnimatedContent(
                targetState = closeIcon,
                modifier = Modifier.clickable(
                    interactionSource = null,
                    indication = ripple(bounded = false, radius = 20.dp),
                ) { (onClose ?: modalDismiss)?.invoke() },
                transitionSpec = {
                    fadeIn(tween(320, easing = EaseInOutCubic)) togetherWith
                        fadeOut(tween(320, easing = EaseInOutCubic))
                },
                contentAlignment = Alignment.Center,
                label = "modalHeaderClose",
            ) { icon ->
                // arrows rotate into place: left from -90deg, down from +90deg
                val startTurns = when (icon) {
                    Icons.AutoMirrored.Rounded.KeyboardArrowLeft -> -0.25f
                    Icons.Rounded.KeyboardArrowDown -> 0.25f
                    else -> 0f
                }
                val shown by transition.animateFloat(
                    transitionSpec = { tween(320, easing = EaseInOutCubic) },
                    label = "closeIconTurn",
                ) { if (it == EnterExitState.Visible) 1f else 0f }
                Icon(
                    icon,
                    contentDescription = null,
                    tint = closeIconColor,
                    modifier = Modifier
                        .size(closeIconSize)
                        .graphicsLayer { rotationZ = startTurns * (1f - shown) * 360f },
                )
            }
        }
    }
}
