package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors

/** fixed 46dp resting container that anchors the search bar in layout flow. */
@Composable
fun ExpandableSearchRestingBar(
    searchQuery: String,
    hintText: String,
    borderRadius: Dp,
    isExpanded: Boolean,
    hasActiveFilter: Boolean,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onToggleExpanded: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(borderRadius)
    Box(
        modifier
            .fillMaxWidth()
            .height(46.dp)
            .clip(shape)
            .background(AppColors.canvasInputSearch, shape)
            .border(
                1.dp,
                if (searchQuery.isNotEmpty() || hasActiveFilter) {
                    AppColors.neoChartreuse.copy(alpha = 0.5f)
                } else {
                    AppColors.canvasBorder
                },
                shape,
            ),
    ) {
        // Visibility(maintainSize): keeps its slot while the floating dropdown is open
        Box(Modifier.graphicsLayer { alpha = if (isExpanded) 0f else 1f }) {
            ExpandableSearchInputRow(
                searchQuery = searchQuery,
                hintText = hintText,
                isExpanded = false,
                hasActiveFilter = hasActiveFilter,
                onSearchChanged = onSearchChanged,
                onClearSearch = onClearSearch,
                onToggleExpanded = onToggleExpanded,
            )
        }
    }
}
