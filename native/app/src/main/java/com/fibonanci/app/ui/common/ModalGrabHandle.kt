package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors

@Composable
fun ModalGrabHandle(
    width: Dp = 40.dp,
    height: Dp = 4.dp,
    color: Color? = null,
    radius: Dp = 2.dp,
    padding: PaddingValues = PaddingValues(bottom = 14.dp),
    modifier: Modifier = Modifier,
) {
    Box(
        modifier.fillMaxWidth().padding(padding),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .size(width, height)
                .background(color ?: AppColors.textSubtle, RoundedCornerShape(radius)),
        )
    }
}
