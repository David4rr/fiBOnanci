package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun CardlessEmptyView(
    icon: ImageVector,
    title: String,
    description: String,
    hint: String? = null,
    onTap: (() -> Unit)? = null,
    padding: PaddingValues = PaddingValues(0.dp),
    modifier: Modifier = Modifier,
) {
    val tapModifier = if (onTap != null) {
        Modifier.clickable(interactionSource = null, indication = null, onClick = onTap)
    } else {
        Modifier
    }

    Column(
        modifier
            .fillMaxWidth()
            .then(tapModifier)
            .padding(padding),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            Modifier
                .size(52.dp)
                .background(Color.White.copy(alpha = 0.04f), CircleShape)
                .border(1.dp, Color.White.copy(alpha = 0.08f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = AppColors.textSubtle, modifier = Modifier.size(24.dp))
        }
        Spacer(Modifier.height(16.dp))
        Text(title, style = AppTypography.sectionTitle, textAlign = TextAlign.Center)
        Spacer(Modifier.height(8.dp))
        Text(description, style = AppTypography.listSubtitle, textAlign = TextAlign.Center)
        if (hint != null) {
            Spacer(Modifier.height(12.dp))
            Text(
                hint,
                textAlign = TextAlign.Center,
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.W500,
                    color = AppColors.textSubtle,
                    letterSpacing = (-0.1).sp,
                ),
            )
        }
    }
}
