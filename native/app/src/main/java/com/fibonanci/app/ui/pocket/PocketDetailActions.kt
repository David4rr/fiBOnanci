package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.NorthEast
import androidx.compose.material.icons.rounded.SouthWest
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun PocketDetailActions(
    pocket: PocketEntry,
    pocketColor: Color,
    onDeposit: (() -> Unit)? = null,
    onWithdraw: (() -> Unit)? = null,
) {
    val host = LocalModalHost.current
    val hasBalance = pocket.currentAmount > 0
    val shape = RoundedCornerShape(14.dp)
    val labelStyle = TextStyle(fontFamily = PlusJakartaSans, fontWeight = FontWeight.ExtraBold, fontSize = 13.5.sp)

    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Button(
            onClick = onDeposit ?: { showPocketTransferDialog(host, pocket = pocket, isDeposit = true) },
            modifier = Modifier.weight(1f).height(48.dp),
            shape = shape,
            colors = ButtonDefaults.buttonColors(containerColor = AppColors.neoMint),
            elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
        ) {
            Icon(Icons.Rounded.SouthWest, contentDescription = null, tint = AppColors.canvasBg, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(8.dp))
            Text("Isi Dana", style = labelStyle.copy(color = AppColors.canvasBg))
        }
        Spacer(Modifier.width(12.dp))
        Button(
            onClick = onWithdraw ?: { showPocketTransferDialog(host, pocket = pocket, isDeposit = false) },
            enabled = hasBalance,
            modifier = Modifier.weight(1f).height(48.dp),
            shape = shape,
            colors = ButtonDefaults.buttonColors(
                containerColor = AppColors.neoCoral,
                disabledContainerColor = AppColors.canvasInputSearch,
                disabledContentColor = AppColors.textMuted,
            ),
            border = if (hasBalance) null else BorderStroke(0.8.dp, AppColors.canvasBorder),
            elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
        ) {
            Icon(
                Icons.Rounded.NorthEast,
                contentDescription = null,
                tint = if (hasBalance) AppColors.canvasBg else AppColors.textMuted,
                modifier = Modifier.size(18.dp),
            )
            Spacer(Modifier.width(8.dp))
            Text("Tarik Dana", style = labelStyle.copy(color = if (hasBalance) AppColors.canvasBg else AppColors.textMuted))
        }
    }
}
