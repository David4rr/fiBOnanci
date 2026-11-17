package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.DoneAll
import androidx.compose.material.icons.rounded.SettingsSuggest
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun InboxEmptyView(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 36.dp, horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .background(AppColors.neoMint.copy(alpha = 0.10f), CircleShape)
                .border(1.dp, AppColors.neoMint.copy(alpha = 0.20f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(Icons.Rounded.DoneAll, contentDescription = null, tint = AppColors.neoMint, modifier = Modifier.size(20.dp))
        }
        Spacer(Modifier.height(16.dp))
        Text(
            "Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!",
            textAlign = TextAlign.Center,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                lineHeight = (13 * 1.5).sp,
                color = AppColors.textMuted,
                letterSpacing = (-0.1).sp,
            ),
        )
        Spacer(Modifier.height(16.dp))
        TextButton(onClick = { NotificationBridge.openPermissionSettings(context) }) {
            Icon(
                Icons.Rounded.SettingsSuggest,
                contentDescription = null,
                tint = AppColors.textMuted,
                modifier = Modifier.size(16.dp),
            )
            Spacer(Modifier.width(8.dp))
            Text(
                "Buka Setelan Akses Notifikasi Android",
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    color = AppColors.textMuted,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.SemiBold,
                ),
            )
        }
    }
}
