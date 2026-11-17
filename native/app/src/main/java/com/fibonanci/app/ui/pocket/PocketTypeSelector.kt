package com.fibonanci.app.ui.pocket

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Elderly
import androidx.compose.material.icons.outlined.Flag
import androidx.compose.material.icons.outlined.Savings
import androidx.compose.material.icons.outlined.Shield
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

data class PocketType(val id: String, val label: String, val icon: ImageVector, val color: String)

val kPocketTypes = listOf(
    PocketType("savings", "Simpanan", Icons.Outlined.Savings, "#A855F7"),
    PocketType("retirement", "Masa Tua", Icons.Outlined.Elderly, "#D4F442"),
    PocketType("emergency", "Dana Darurat", Icons.Outlined.Shield, "#7DF24E"),
    PocketType("goal", "Target / Impian", Icons.Outlined.Flag, "#26D9D9"),
)

@Composable
fun PocketTypeSelector(
    selectedType: String,
    onSelectType: (String) -> Unit,
) {
    val haptics = LocalHapticFeedback.current
    LazyRow(
        modifier = Modifier.fillMaxWidth().height(40.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        items(kPocketTypes, key = { it.id }) { t ->
            val isSelected = t.id == selectedType
            val typeColor = AppColors.fromHex(t.color)
            val spec = tween<Color>(180)
            val bg by animateColorAsState(if (isSelected) typeColor.copy(alpha = 0.18f) else AppColors.canvasInputSearch, spec, label = "bg")
            val borderColor by animateColorAsState(if (isSelected) typeColor else AppColors.canvasBorder, spec, label = "border")
            val borderWidth by animateDpAsState(if (isSelected) 1.5.dp else 1.dp, tween(180), label = "borderWidth")
            Row(
                modifier = Modifier
                    .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                        haptics.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                        onSelectType(t.id)
                    }
                    .background(bg, RoundedCornerShape(12.dp))
                    .border(borderWidth, borderColor, RoundedCornerShape(12.dp))
                    .padding(horizontal = 14.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(t.icon, contentDescription = null, tint = if (isSelected) typeColor else AppColors.textMuted, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text(
                    t.label,
                    style = TextStyle(
                        color = if (isSelected) typeColor else AppColors.textMuted,
                        fontSize = 12.5.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                    ),
                )
            }
        }
    }
}

object PocketTypeSelector {
    // material filled text field without underline, mirroring the dart InputDecoration.
    @Composable
    fun buildTextField(
        value: String,
        onValueChange: (String) -> Unit,
        label: String,
        hintText: String,
        errorText: String? = null,
        keyboardType: KeyboardType = KeyboardType.Text,
        onChanged: ((String) -> Unit)? = null,
    ) {
        TextField(
            value = value,
            onValueChange = {
                onValueChange(it)
                onChanged?.invoke(it)
            },
            modifier = Modifier.fillMaxWidth(),
            textStyle = AppTypography.listTitle,
            label = { Text(label) },
            placeholder = { Text(hintText) },
            isError = errorText != null,
            supportingText = errorText?.let { { Text(it) } },
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            shape = RoundedCornerShape(16.dp),
            colors = TextFieldDefaults.colors(
                focusedContainerColor = AppColors.canvasInputSearch,
                unfocusedContainerColor = AppColors.canvasInputSearch,
                errorContainerColor = AppColors.canvasInputSearch,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent,
                errorIndicatorColor = Color.Transparent,
            ),
        )
    }
}
