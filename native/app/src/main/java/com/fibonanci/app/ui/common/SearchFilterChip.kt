package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun SearchFilterChip(
    label: String,
    onClear: () -> Unit,
    color: Color = AppColors.neoChartreuse,
    backgroundColor: Color = AppColors.canvasInputSearch,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(8.dp)
    Row(
        modifier
            .background(backgroundColor, shape)
            .border(1.dp, color, shape)
            .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(label, style = AppTypography.badgeLabel.copy(color = color))
        Spacer(Modifier.width(4.dp))
        Icon(
            Icons.Filled.Close,
            contentDescription = null,
            tint = color,
            modifier = Modifier
                .size(14.dp)
                .clickable(interactionSource = null, indication = null, onClick = onClear),
        )
    }
}
