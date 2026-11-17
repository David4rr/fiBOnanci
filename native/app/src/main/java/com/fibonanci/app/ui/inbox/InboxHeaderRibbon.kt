package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import androidx.compose.foundation.layout.Box

@Composable
fun InboxHeaderRibbon(
    pendingCount: Int,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Row(modifier = Modifier.weight(1f), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "Kotak Masuk Notifikasi",
                    style = AppTypography.modalTitle,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f, fill = false),
                )
                if (pendingCount > 0) {
                    Spacer(Modifier.width(8.dp))
                    val shape = RoundedCornerShape(10.dp)
                    Row(
                        modifier = Modifier
                            .background(AppColors.neoChartreuse.copy(alpha = 0.12f), shape)
                            .border(1.dp, AppColors.neoChartreuse.copy(alpha = 0.3f), shape)
                            .padding(horizontal = 7.dp, vertical = 2.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Box(Modifier.size(5.dp).background(AppColors.neoChartreuse, CircleShape))
                        Spacer(Modifier.width(4.dp))
                        Text(
                            "$pendingCount",
                            style = TextStyle(
                                fontFamily = PlusJakartaSans,
                                color = AppColors.neoChartreuse,
                                fontWeight = FontWeight.ExtraBold,
                                fontSize = 10.5.sp,
                            ),
                        )
                    }
                }
            }
            Spacer(Modifier.width(8.dp))
            Icon(
                Icons.Rounded.KeyboardArrowDown,
                contentDescription = null,
                tint = AppColors.textWhite,
                modifier = Modifier
                    .size(28.dp)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(bounded = false, radius = 20.dp),
                        onClick = onDismiss,
                    ),
            )
        }
        if (pendingCount > 0) {
            Text(
                "Geser kanan untuk terima, kiri untuk tolak",
                modifier = Modifier.padding(top = 4.dp, bottom = 12.dp),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = AppColors.textMuted,
                ),
            )
        } else {
            Spacer(Modifier.height(12.dp))
        }
    }
}
