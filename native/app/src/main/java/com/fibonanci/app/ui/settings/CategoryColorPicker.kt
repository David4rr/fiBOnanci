package com.fibonanci.app.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors

object CategoryColorPicker {
    val palette = listOf(
        "#D4F442", "#10B981", "#14B8A6", "#06B6D4",
        "#3B82F6", "#6366F1", "#8B5CF6", "#A855F7",
        "#EC4899", "#F43F5E", "#EF4444", "#F97316",
        "#F59E0B", "#D97706", "#78716C", "#64748B",
    )

    fun parseColor(hex: String): Color {
        val cleaned = hex.replace("#", "").trim()
        val v = "FF$cleaned".toLongOrNull(16)
        return if (v != null) Color(v.toInt()) else AppColors.neoChartreuse
    }
}

private val hexPattern = Regex("^[0-9a-fA-F]{6}$")

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun CategoryColorPicker(selectedColor: String, onColorChanged: (String) -> Unit) {
    var customHexOpen by rememberSaveable { mutableStateOf(false) }
    var hexCtrl by rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(textValue(selectedColor)) }

    fun onHexSubmitted(v: String) {
        val clean = v.replace("#", "").trim()
        if (hexPattern.matches(clean)) onColorChanged("#${clean.uppercase()}")
    }

    Column {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(
                "PILIH WARNA",
                style = TextStyle(fontSize = 10.sp, fontWeight = FontWeight.W700, color = Color.White.copy(alpha = 0.4f), letterSpacing = 0.8.sp),
            )
            Text(
                if (customHexOpen) "Tutup HEX" else "# Custom HEX",
                style = TextStyle(fontSize = 10.sp, fontWeight = FontWeight.W600, color = AppColors.neoChartreuse),
                modifier = Modifier.plainClickable { customHexOpen = !customHexOpen },
            )
        }
        Spacer(Modifier.height(8.dp))
        if (customHexOpen) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier
                        .size(20.dp)
                        .background(CategoryColorPicker.parseColor(selectedColor), CircleShape)
                        .border(1.5.dp, Color.White.copy(alpha = 0.24f), CircleShape),
                )
                Spacer(Modifier.width(8.dp))
                BasicTextField(
                    value = hexCtrl,
                    onValueChange = { hexCtrl = it; onHexSubmitted(it.text) },
                    singleLine = true,
                    textStyle = TextStyle(fontSize = 12.sp, color = Color.White, fontFamily = FontFamily.Monospace),
                    cursorBrush = SolidColor(AppColors.neoChartreuse),
                    modifier = Modifier.weight(1f),
                    decorationBox = { inner ->
                        Box(
                            Modifier
                                .fillMaxWidth()
                                .background(Color.White.copy(alpha = 0.05f), RoundedCornerShape(8.dp))
                                .padding(horizontal = 10.dp, vertical = 6.dp),
                        ) {
                            if (hexCtrl.text.isEmpty()) Text("Misal: #FF6B6B", style = TextStyle(fontSize = 12.sp, color = Color.White.copy(alpha = 0.38f)))
                            inner()
                        }
                    },
                )
            }
            Spacer(Modifier.height(8.dp))
        }
        FlowRow(horizontalArrangement = Arrangement.spacedBy(7.dp), verticalArrangement = Arrangement.spacedBy(7.dp)) {
            for (hex in CategoryColorPicker.palette) {
                val active = selectedColor.uppercase() == hex.uppercase()
                val c = CategoryColorPicker.parseColor(hex)
                Box(
                    Modifier
                        .testTag("color_chip_$hex")
                        .size(20.dp)
                        .then(if (active) Modifier.shadow(6.dp, CircleShape, ambientColor = c.copy(alpha = 0.5f), spotColor = c.copy(alpha = 0.5f)) else Modifier)
                        .background(c, CircleShape)
                        .then(if (active) Modifier.border(2.2.dp, Color.White, CircleShape) else Modifier)
                        .plainClickable {
                            hexCtrl = textValue(hex)
                            onColorChanged(hex)
                        },
                )
            }
        }
    }
}
