package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.displayCutout
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBars
import androidx.compose.foundation.layout.union
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors

@Composable
fun ModalSheetScaffold(
    padding: PaddingValues? = null,
    backgroundColor: Color = AppColors.canvasCardSurface,
    borderColor: Color = AppColors.canvasBorder,
    topRadius: Dp = 28.dp,
    applyKeyboardInset: Boolean = true,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val shape = RoundedCornerShape(topStart = topRadius, topEnd = topRadius)
    // default padding adds the keyboard inset to the bottom, a custom padding does not
    val keyboardInset = if (padding == null && applyKeyboardInset) Modifier.imePadding() else Modifier

    Box(
        modifier
            .fillMaxWidth()
            .background(backgroundColor, shape)
            .border(1.dp, borderColor, shape)
            .then(keyboardInset)
            .padding(padding ?: PaddingValues(start = 20.dp, top = 12.dp, end = 20.dp, bottom = 24.dp))
            // SafeArea(top: false)
            .windowInsetsPadding(
                WindowInsets.systemBars
                    .union(WindowInsets.displayCutout)
                    .only(WindowInsetsSides.Horizontal + WindowInsetsSides.Bottom),
            ),
    ) {
        content()
    }
}
