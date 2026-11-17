package com.fibonanci.app.ui.common

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors

/** standard maximum viewport width matching modern iphone pro max dimensions (430pt). */
val kMaxIPhoneViewportWidth: Dp = 430.dp

/**
 * constrains width to iphone viewport dimensions on wide screens (tablets, landscape):
 * centers the content, clamps the reported screen width and drops horizontal insets.
 * portrait phones pass through at their natural width.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun IPhoneViewportContainer(
    maxWidth: Dp = kMaxIPhoneViewportWidth,
    backgroundColor: Color? = null,
    content: @Composable () -> Unit,
) {
    val configuration = LocalConfiguration.current
    val width = configuration.screenWidthDp
    val height = configuration.screenHeightDp

    // physical phones in portrait (shortestSide < 600dp) keep their full width, so
    // "small display size" / high dpi settings never cause pillarboxing
    val isPortraitPhone = width <= height && minOf(width, height) < 600
    val isStretched = !isPortraitPhone && width > maxWidth.value

    if (!isStretched) {
        content()
        return
    }

    val clamped = remember(configuration, maxWidth) {
        Configuration(configuration).apply { screenWidthDp = maxWidth.value.toInt() }
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(backgroundColor ?: AppColors.canvasBg),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .width(maxWidth)
                .fillMaxHeight()
                .clipToBounds()
                .consumeWindowInsets(WindowInsets.safeDrawing.only(WindowInsetsSides.Horizontal)),
        ) {
            CompositionLocalProvider(LocalConfiguration provides clamped, content = content)
        }
    }
}
