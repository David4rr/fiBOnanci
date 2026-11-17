package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
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
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun InboxWalletChip(
    walletName: String? = null,
    profileName: String? = null,
    onSwitchWallet: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(6.dp)
    Row(
        modifier = modifier
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                enabled = onSwitchWallet != null,
            ) { onSwitchWallet?.invoke() }
            .background(AppColors.canvasInputSearch, shape)
            .border(
                0.8.dp,
                if (onSwitchWallet != null) AppColors.neoChartreuse.copy(alpha = 0.3f) else AppColors.canvasBorder,
                shape,
            )
            .padding(horizontal = 8.dp, vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (profileName != null) {
            Text(
                profileName,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f, fill = false),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppColors.neoChartreuse,
                ),
            )
            Text(" · ", style = TextStyle(fontSize = 10.sp, color = AppColors.textMuted))
        }
        Text(
            walletName ?: "Pilih Dompet",
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f, fill = false),
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 10.5.sp,
                fontWeight = FontWeight.SemiBold,
                color = AppColors.textWhite,
            ),
        )
        if (onSwitchWallet != null) {
            Spacer(Modifier.width(4.dp))
            Icon(
                Icons.Rounded.SwapHoriz,
                contentDescription = null,
                tint = AppColors.neoChartreuse,
                modifier = Modifier.size(12.dp),
            )
        }
    }
}
