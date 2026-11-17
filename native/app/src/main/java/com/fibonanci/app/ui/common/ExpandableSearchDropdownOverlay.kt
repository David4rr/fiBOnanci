package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.layout
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.lerp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import kotlin.math.roundToInt

/**
 * floating overlay morphing container that expands the search bar on top of the
 * following widgets without pushing them down. [anchorOffset] is the bar position
 * inside the overlay, [animation] the curved expand progress.
 */
@Composable
fun ExpandableSearchDropdownOverlay(
    searchQuery: String,
    hintText: String,
    barBorderRadius: Dp,
    headerTitle: String,
    primaryFilterTitle: String,
    primaryFilterChoices: List<FilterChoice>,
    wallets: List<WalletEntry>,
    showWalletFilter: Boolean,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    anchorOffset: IntOffset,
    width: Dp,
    animation: Float,
    tempType: String,
    tempWalletId: String?,
    hasActiveFilter: Boolean,
    onSelectType: (String) -> Unit,
    onSelectWallet: (String?) -> Unit,
    onReset: () -> Unit,
    onApply: () -> Unit,
    onClose: () -> Unit,
) {
    val hasPendingChange = tempType != "all" || tempWalletId != null
    val progress = animation
    val currentRadius = lerp(barBorderRadius, 16.dp, progress)
    val borderColor = lerp(
        if (hasActiveFilter) AppColors.neoChartreuse.copy(alpha = 0.5f) else AppColors.canvasBorder,
        AppColors.neoChartreuse.copy(alpha = 0.6f),
        progress,
    )
    val shape = RoundedCornerShape(currentRadius)

    Box(Modifier.fillMaxSize()) {
        Box(
            Modifier
                .fillMaxSize()
                .pointerInput(Unit) { detectTapGestures { onClose() } },
        )
        Column(
            Modifier
                .offset { anchorOffset }
                .width(width)
                // black drop shadow (0.55 * progress, blur 20 * progress + 4, y 8 * progress)
                .shadow(
                    elevation = (10f * progress + 2f).dp,
                    shape = shape,
                    ambientColor = Color.Black.copy(alpha = 0.55f * progress),
                    spotColor = Color.Black.copy(alpha = 0.55f * progress),
                )
                .clip(shape)
                .background(AppColors.canvasInputSearch, shape)
                .border(1.dp, borderColor, shape)
                // swallow taps on the container so the barrier does not close it
                .pointerInput(Unit) { detectTapGestures { } },
        ) {
            ExpandableSearchInputRow(
                searchQuery = searchQuery,
                hintText = hintText,
                isExpanded = true,
                hasActiveFilter = hasActiveFilter,
                onSearchChanged = onSearchChanged,
                onClearSearch = onClearSearch,
                onToggleExpanded = onClose,
            )
            Box(
                Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .graphicsLayer { alpha = ((progress - 0.15f) / 0.85f).coerceIn(0f, 1f) }
                    .background(AppColors.canvasBorder.copy(alpha = 0.4f)),
            )
            // Align(heightFactor: progress) inside ClipRect
            Box(
                Modifier
                    .clipToBounds()
                    .layout { measurable, constraints ->
                        val placeable = measurable.measure(constraints)
                        layout(placeable.width, (placeable.height * progress).roundToInt()) {
                            placeable.place(0, 0)
                        }
                    },
            ) {
                ExpandableSearchFilterPanel(
                    headerTitle = headerTitle,
                    primaryFilterTitle = primaryFilterTitle,
                    primaryFilterChoices = primaryFilterChoices,
                    tempType = tempType,
                    tempWalletId = tempWalletId,
                    wallets = wallets,
                    showWalletFilter = showWalletFilter,
                    hasPendingChange = hasPendingChange,
                    onSelectType = onSelectType,
                    onSelectWallet = onSelectWallet,
                    onReset = onReset,
                    onApply = onApply,
                    modifier = Modifier.graphicsLayer {
                        alpha = ((progress - 0.25f) / 0.75f).coerceIn(0f, 1f)
                    },
                )
            }
        }
    }
}
