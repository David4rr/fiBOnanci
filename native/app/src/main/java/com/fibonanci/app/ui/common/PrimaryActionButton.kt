package com.fibonanci.app.ui.common

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun PrimaryActionButton(
    text: String,
    onPressed: (() -> Unit)? = null,
    backgroundColor: Color = AppColors.neoChartreuse,
    foregroundColor: Color = AppColors.textDarkPrimary,
    height: Dp = 52.dp,
    borderRadius: Dp = 16.dp,
    isLoading: Boolean = false,
    icon: ImageVector? = null,
    textStyle: TextStyle? = null,
    modifier: Modifier = Modifier,
) {
    val style = textStyle ?: AppTypography.listTitle.copy(color = foregroundColor, fontWeight = FontWeight.W800)

    Button(
        onClick = { onPressed?.invoke() },
        enabled = !isLoading && onPressed != null,
        modifier = modifier.fillMaxWidth().height(height),
        shape = RoundedCornerShape(borderRadius),
        colors = ButtonDefaults.buttonColors(
            containerColor = backgroundColor,
            contentColor = foregroundColor,
            // flutter elevated button disabled tones (onSurface 12% / 38%)
            disabledContainerColor = Color.White.copy(alpha = 0.12f),
            disabledContentColor = Color.White.copy(alpha = 0.38f),
        ),
        elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
    ) {
        when {
            isLoading -> CircularProgressIndicator(
                modifier = Modifier.size(24.dp),
                color = foregroundColor,
                strokeWidth = 2.5.dp,
            )

            icon != null -> Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(icon, contentDescription = null, tint = foregroundColor, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Text(
                    text,
                    style = style,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f, fill = false),
                )
            }

            else -> Text(text, style = style, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}
