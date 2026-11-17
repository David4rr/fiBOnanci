package com.fibonanci.app.ui.shell

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector

data class DockItemData(
    val index: Int,
    val icon: ImageVector,
    val activeIcon: ImageVector,
    val label: String,
)

private class WeightState(var prev: List<Float>, var target: List<Float>, var lastIndex: Int, var pendingRestart: Boolean = false)

@Composable
fun AnimatedNavDockRow(
    currentIndex: Int,
    onTapIndex: (Int) -> Unit,
    items: List<DockItemData>,
    modifier: Modifier = Modifier,
) {
    fun computeWeights(index: Int) = List(items.size) { i -> if (i == index) 1.35f else 1.0f }

    // raw progress; the easeOutCubic curve is applied when reading, like CurvedAnimation
    val controller = remember { Animatable(0f) }
    val weights = remember { computeWeights(currentIndex).let { WeightState(it, it, currentIndex) } }

    fun currentWeights(): List<Float> {
        val t = if (weights.pendingRestart) 0f else EaseOutCubic.transform(controller.value)
        return List(items.size) { i -> weights.prev[i] + (weights.target[i] - weights.prev[i]) * t }
    }

    // same as didUpdateWidget: snapshot the in-flight weights and restart from 0
    if (weights.lastIndex != currentIndex) {
        weights.prev = currentWeights()
        weights.target = computeWeights(currentIndex)
        weights.lastIndex = currentIndex
        weights.pendingRestart = true
    }
    LaunchedEffect(currentIndex) {
        controller.snapTo(0f)
        weights.pendingRestart = false
        controller.animateTo(1f, tween(280, easing = { it }))
    }

    val current = currentWeights()
    Row(modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        items.forEachIndexed { i, item ->
            NavItemWidget(
                isActive = currentIndex == item.index,
                icon = item.icon,
                activeIcon = item.activeIcon,
                label = item.label,
                onTap = { onTapIndex(item.index) },
                modifier = Modifier.weight(current[i]),
            )
        }
    }
}
