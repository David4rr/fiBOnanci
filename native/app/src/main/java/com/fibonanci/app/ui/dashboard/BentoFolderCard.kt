package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.common.PeekableBalanceText
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlin.math.min
import kotlin.math.roundToInt

// reusable bento folder card: folder tab clip, circular icon badge, metric value, subtitle and optional progress bar.
@Composable
fun BentoFolderCard(
    backgroundColor: Color,
    gradient: Brush? = null,
    icon: (@Composable () -> Unit)? = null,
    iconData: ImageVector? = null,
    topTrailing: (@Composable () -> Unit)? = null,
    title: String,
    subtitle: String? = null,
    subtitleWidget: (@Composable () -> Unit)? = null,
    trailingIcon: (@Composable () -> Unit)? = null,
    rightWidget: (@Composable () -> Unit)? = null,
    progress: Float? = null,
    onTap: (() -> Unit)? = null,
    height: Dp? = 132.dp,
    padding: PaddingValues = PaddingValues(16.dp),
    textColor: Color? = null,
    subtitleColor: Color? = null,
    iconColor: Color? = null,
    iconBgColor: Color? = null,
    isBalanceHidden: Boolean? = null,
    modifier: Modifier = Modifier,
) {
    val isNeoPastel = backgroundColor == AppColors.neoCoral ||
        backgroundColor == AppColors.neoChartreuse ||
        backgroundColor == AppColors.neoMint ||
        backgroundColor == AppColors.neoCyan

    // same threshold as flutter's ThemeData.estimateBrightnessForColor
    val lum = backgroundColor.luminance() + 0.05
    val isDark = if (isNeoPastel) false else lum * lum <= 0.15

    val primaryText = textColor ?: if (isDark) AppColors.textWhite else AppColors.textDarkPrimary
    val secondaryText = subtitleColor ?: if (isDark) Color.White.copy(alpha = 0.90f) else AppColors.textDarkSecondary
    val effectiveIconColor = iconColor ?: primaryText
    val iconBg = iconBgColor ?: if (isDark) Color.White.copy(alpha = 0.18f) else AppColors.cardIconBadgeBg

    val iconWidget: @Composable () -> Unit = {
        Box(
            Modifier.size(34.dp).clip(CircleShape).background(iconBg),
            contentAlignment = Alignment.Center,
        ) {
            if (icon != null) icon() else Icon(iconData ?: Icons.Outlined.Folder, null, tint = effectiveIconColor, modifier = Modifier.size(18.dp))
        }
    }

    val bottomContent: @Composable () -> Unit = {
        Column {
            ScaleDownBox {
                PeekableBalanceText(
                    text = title,
                    isHidden = isBalanceHidden,
                    style = AppTypography.cardMetricValue.copy(color = primaryText),
                )
            }
            Spacer(Modifier.height(2.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.weight(1f)) {
                    if (subtitleWidget != null) {
                        subtitleWidget()
                    } else {
                        Text(
                            subtitle ?: "",
                            style = AppTypography.cardMetricLabel.copy(color = secondaryText),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
                if (trailingIcon != null) {
                    Spacer(Modifier.width(4.dp))
                    trailingIcon()
                }
            }
            if (progress != null) {
                Spacer(Modifier.height(6.dp))
                Box(
                    Modifier.fillMaxWidth().height(3.5.dp).clip(RoundedCornerShape(2.dp))
                        .background(if (isDark) Color.White.copy(alpha = 0.15f) else Color.Black.copy(alpha = 0.10f)),
                ) {
                    Box(Modifier.fillMaxWidth(progress.coerceIn(0f, 1f)).fillMaxHeight().background(primaryText))
                }
            }
        }
    }

    FolderTabCard(
        backgroundColor = backgroundColor,
        gradient = gradient,
        height = height,
        padding = padding,
        onTap = onTap,
        modifier = modifier,
    ) {
        val fill = if (height != null) Modifier.fillMaxSize() else Modifier.fillMaxWidth()
        if (rightWidget != null) {
            Row(fill) {
                Column(
                    Modifier.weight(6f).fillMaxHeight(),
                    verticalArrangement = Arrangement.SpaceBetween,
                ) {
                    iconWidget()
                    bottomContent()
                }
                Spacer(Modifier.width(12.dp))
                Column(
                    Modifier.weight(5f).fillMaxHeight(),
                    horizontalAlignment = Alignment.End,
                ) {
                    topTrailing?.invoke()
                    Spacer(Modifier.height(4.dp))
                    Box(Modifier.weight(1f).fillMaxWidth()) { rightWidget() }
                }
            }
        } else {
            Column(fill, verticalArrangement = Arrangement.SpaceBetween) {
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top,
                ) {
                    iconWidget()
                    topTrailing?.invoke()
                }
                bottomContent()
            }
        }
    }
}

// port of FittedBox(fit: scaleDown, alignment: centerLeft)
@Composable
private fun ScaleDownBox(content: @Composable () -> Unit) {
    Layout(content = content) { measurables, constraints ->
        val placeable = measurables.first().measure(Constraints(maxHeight = constraints.maxHeight))
        val scale = if (constraints.hasBoundedWidth && placeable.width > constraints.maxWidth) {
            constraints.maxWidth.toFloat() / placeable.width
        } else 1f
        val w = (placeable.width * scale).roundToInt()
        val h = (placeable.height * scale).roundToInt()
        layout(min(w, constraints.maxWidth), h) {
            placeable.placeWithLayer(0, 0) {
                scaleX = scale
                scaleY = scale
                transformOrigin = TransformOrigin(0f, 0f)
            }
        }
    }
}
