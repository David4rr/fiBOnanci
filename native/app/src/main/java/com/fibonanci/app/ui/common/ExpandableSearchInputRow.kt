package com.fibonanci.app.ui.common

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

/** the 46dp search input row: search icon, text field, clear action and rotating tune button. */
@Composable
fun ExpandableSearchInputRow(
    searchQuery: String,
    hintText: String,
    isExpanded: Boolean,
    hasActiveFilter: Boolean,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onToggleExpanded: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val turns by animateFloatAsState(
        targetValue = if (isExpanded) 0.5f else 0f,
        animationSpec = tween(240, easing = FastOutSlowInEasing),
        label = "tuneTurns",
    )
    val highlighted = isExpanded || hasActiveFilter

    Row(
        modifier
            .fillMaxWidth()
            .height(46.dp)
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(Icons.Filled.Search, contentDescription = null, tint = AppColors.textMuted, modifier = Modifier.size(18.dp))
        Spacer(Modifier.width(10.dp))
        Box(Modifier.weight(1f), contentAlignment = Alignment.CenterStart) {
            if (searchQuery.isEmpty()) {
                Text(
                    hintText,
                    maxLines = 1,
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textMuted, fontSize = 12.5.sp),
                )
            }
            BasicTextField(
                value = searchQuery,
                onValueChange = { if (it != searchQuery) onSearchChanged(it) },
                modifier = Modifier.fillMaxWidth(),
                textStyle = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textWhite, fontSize = 13.5.sp),
                singleLine = true,
                cursorBrush = SolidColor(AppColors.neoChartreuse),
            )
        }
        if (searchQuery.isNotEmpty()) {
            Icon(
                Icons.Filled.Close,
                contentDescription = null,
                tint = AppColors.textMuted,
                modifier = Modifier
                    .clickable(interactionSource = null, indication = null, onClick = onClearSearch)
                    .padding(4.dp)
                    .size(16.dp),
            )
        }
        Spacer(Modifier.width(6.dp))
        Box(
            Modifier
                .clickable(interactionSource = null, indication = null, onClick = onToggleExpanded)
                .background(
                    if (highlighted) AppColors.neoChartreuse.copy(alpha = 0.2f) else Color.Transparent,
                    RoundedCornerShape(8.dp),
                )
                .padding(5.dp),
        ) {
            Icon(
                Icons.Filled.Tune,
                contentDescription = null,
                tint = if (highlighted) AppColors.neoChartreuse else AppColors.textWhite,
                modifier = Modifier
                    .size(17.dp)
                    .graphicsLayer { rotationZ = turns * 360f },
            )
        }
    }
}
