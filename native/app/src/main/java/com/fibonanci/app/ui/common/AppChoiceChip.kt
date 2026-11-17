package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

/**
 * instantaneous, zero-latency choice chip for filter dialogs and selectors.
 * no cross-fade between states, so single-choice switching never flashes.
 */
@Composable
fun AppChoiceChip(
    label: String,
    selected: Boolean,
    onSelected: ((Boolean) -> Unit)? = null,
    onTap: (() -> Unit)? = null,
    selectedColor: Color = AppColors.neoChartreuse,
    backgroundColor: Color = AppColors.canvasInputSearch,
    selectedTextColor: Color = AppColors.textDarkPrimary,
    unselectedTextColor: Color = AppColors.textWhite,
    selectedBorderColor: Color? = null,
    unselectedBorderColor: Color = AppColors.canvasBorder,
    borderRadius: Dp = 14.dp,
    modifier: Modifier = Modifier,
) {
    val borderColor = if (selected) selectedBorderColor ?: selectedColor else unselectedBorderColor
    val shape = RoundedCornerShape(borderRadius)

    Text(
        text = label,
        style = TextStyle(
            fontFamily = PlusJakartaSans,
            color = if (selected) selectedTextColor else unselectedTextColor,
            fontWeight = if (selected) FontWeight.W800 else FontWeight.W500,
            fontSize = 12.5.sp,
        ),
        modifier = modifier
            .clickable(interactionSource = null, indication = null) {
                if (onTap != null) {
                    onTap()
                } else {
                    onSelected?.invoke(!selected)
                }
            }
            .background(if (selected) selectedColor else backgroundColor, shape)
            .border(1.dp, borderColor, shape)
            .padding(horizontal = 14.dp, vertical = 8.5.dp),
    )
}
