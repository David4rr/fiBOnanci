package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

// vertically stacked deck of cards overlapping by a fixed vertical step
@Composable
fun OverlappingDeckList(
    children: List<@Composable () -> Unit>,
    overlapOffset: Dp = 70.dp,
    stepOffset: Dp = 95.dp,
    cardHeight: Dp = 200.dp,
) {
    if (children.isEmpty()) return
    val totalHeight = stepOffset * (children.size - 1) + cardHeight
    Box(Modifier.fillMaxWidth().height(totalHeight)) {
        children.forEachIndexed { i, child ->
            Box(Modifier.fillMaxWidth().offset(y = stepOffset * i)) { child() }
        }
    }
}
