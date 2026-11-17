package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Remove
import androidx.compose.material.icons.rounded.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

// tactile obsidian input row for custom installment tenor (months) with steppers.
@Composable
fun SubscriptionCustomTenorRow(
    value: String,
    onValueChange: (String) -> Unit,
    totalCycles: Int,
    onChanged: (Int) -> Unit,
) {
    fun step(delta: Int) {
        val next = (totalCycles + delta).coerceIn(1, 120)
        onValueChange(next.toString())
        onChanged(next)
    }

    val shape = RoundedCornerShape(12.dp)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColors.canvasInputSearch, shape)
            .border(1.dp, AppColors.canvasBorder, shape)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(Icons.Rounded.Tune, contentDescription = null, modifier = Modifier.size(16.dp), tint = AppColors.neoCoral)
        Spacer(Modifier.width(8.dp))
        Text(
            "Durasi Tenor",
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, fontWeight = FontWeight.W600, color = AppColors.textMuted),
        )
        Spacer(Modifier.weight(1f))
        StepperButton(Icons.Rounded.Remove) { step(-1) }
        BasicTextField(
            value = value,
            onValueChange = { raw ->
                val digits = raw.filter { it.isDigit() }
                onValueChange(digits)
                val n = digits.toIntOrNull()
                if (n != null && n > 0) onChanged(n.coerceIn(1, 120))
            },
            modifier = Modifier.width(48.dp),
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            cursorBrush = SolidColor(AppColors.textWhite),
            textStyle = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 14.sp,
                fontWeight = FontWeight.W800,
                color = AppColors.textWhite,
                textAlign = TextAlign.Center,
            ),
        )
        StepperButton(Icons.Rounded.Add) { step(1) }
        Spacer(Modifier.width(6.dp))
        Text(
            "Bln",
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, fontWeight = FontWeight.W700, color = AppColors.neoCoral),
        )
    }
}

@Composable
private fun StepperButton(icon: ImageVector, onTap: () -> Unit) {
    val haptic = LocalHapticFeedback.current
    val shape = RoundedCornerShape(8.dp)
    Box(
        modifier = Modifier
            .size(28.dp)
            .background(AppColors.canvasCardSurface, shape)
            .border(1.dp, AppColors.canvasBorder, shape)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                haptic.performHapticFeedback(HapticFeedbackType.ContextClick)
                onTap()
            },
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(15.dp), tint = AppColors.textWhite)
    }
}

// tactile button for installment tenor presets or custom toggle.
@Composable
fun SubscriptionTenorPresetButton(
    label: String,
    isSelected: Boolean,
    onTap: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val haptic = LocalHapticFeedback.current
    val shape = RoundedCornerShape(10.dp)
    Box(
        modifier = modifier
            .height(38.dp)
            .background(if (isSelected) AppColors.neoCoral else AppColors.canvasInputSearch, shape)
            .border(1.dp, if (isSelected) AppColors.neoCoral else AppColors.canvasBorder, shape)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                onTap()
            },
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 12.sp,
                fontWeight = FontWeight.W800,
                color = if (isSelected) AppColors.textDarkPrimary else AppColors.textWhite,
            ),
        )
    }
}
