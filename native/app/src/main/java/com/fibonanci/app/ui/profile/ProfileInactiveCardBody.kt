package com.fibonanci.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.MonetizationOn
import androidx.compose.material.icons.outlined.Shield
import androidx.compose.material.icons.outlined.Swipe
import androidx.compose.material.icons.outlined.TouchApp
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.theme.AppColors

@Composable
fun ProfileInactiveCardBody(
    profile: ProfileEntry,
    onActivate: () -> Unit,
) {
    val targetFormatted = AppCurrency.format(profile.monthlyIncomeTarget ?: 0.0, profile.currency)
    val shape = RoundedCornerShape(10.dp)
    Column(Modifier.fillMaxWidth()) {
        Spacer(Modifier.height(12.dp))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.White.copy(alpha = 0.04f), shape)
                .border(1.dp, Color.White.copy(alpha = 0.08f), shape)
                .padding(horizontal = 10.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(Icons.Outlined.Swipe, contentDescription = null, tint = AppColors.neoChartreuse, modifier = Modifier.size(14.dp))
            Spacer(Modifier.width(6.dp))
            Text(
                "Geser atau ketuk untuk mengaktifkan akun ini",
                style = jakarta(11.sp, FontWeight.SemiBold, Color.White.copy(alpha = 0.8f)),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
        }
        Spacer(Modifier.height(14.dp))
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text("Target Pemasukan", style = jakarta(10.sp, FontWeight.Medium, AppColors.textMuted))
                Spacer(Modifier.height(2.dp))
                Text(
                    targetFormatted,
                    style = jakarta(20.sp, FontWeight.ExtraBold, Color(0xFFEEEEEE), letterSpacing = (-0.5).sp, tabular = true),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            Box(
                modifier = Modifier
                    .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onActivate)
                    .background(AppColors.neoChartreuse, shape)
                    .padding(horizontal = 14.dp, vertical = 8.dp),
            ) {
                Text("Pilih Akun", style = jakarta(11.5.sp, FontWeight.Bold, AppColors.textDarkPrimary))
            }
        }
        Spacer(Modifier.height(14.dp))
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            ProfileStat(Icons.Outlined.MonetizationOn, profile.currency, "Mata Uang")
            ProfileStat(Icons.Outlined.Shield, "Lokal", "Keamanan")
            ProfileStat(Icons.Outlined.TouchApp, "Tersedia", "Status")
        }
    }
}
