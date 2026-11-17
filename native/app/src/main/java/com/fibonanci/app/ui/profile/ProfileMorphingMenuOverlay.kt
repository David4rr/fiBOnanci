package com.fibonanci.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.PersonAddAlt1
import androidx.compose.material.icons.outlined.Share
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.FavoriteBorder
import androidx.compose.material.icons.rounded.MoreHoriz
import androidx.compose.material.icons.rounded.PieChartOutline
import androidx.compose.material.icons.rounded.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.health.showFinancialHealthModal
import com.fibonanci.app.ui.theme.AppColors

@Composable
fun ProfileMorphingMenuOverlay(
    profile: ProfileEntry,
    totalProfiles: Int,
    onClose: () -> Unit,
    onAction: ((() -> Unit)?) -> Unit,
    onEditProfile: (() -> Unit)? = null,
    onNewProfile: (() -> Unit)? = null,
    onHealthDetails: (() -> Unit)? = null,
    onFinancialReport: (() -> Unit)? = null,
    onSettings: (() -> Unit)? = null,
    onShareProfile: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    val shape = RoundedCornerShape(16.dp)
    Column(
        modifier = modifier
            .width(256.dp)
            .shadow(24.dp, shape, ambientColor = Color.Black.copy(alpha = 0.65f), spotColor = Color.Black.copy(alpha = 0.65f))
            .background(AppColors.canvasCardSurface, shape)
            .border(1.2.dp, Color(0xFF2E3244), shape)
            .padding(12.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(Icons.Rounded.MoreHoriz, contentDescription = null, tint = AppColors.neoChartreuse, modifier = Modifier.size(16.dp))
            Spacer(Modifier.width(8.dp))
            Text("Menu Profil", style = jakarta(12.5.sp, FontWeight.Bold, Color.White))
            Spacer(Modifier.weight(1f))
            Box(
                modifier = Modifier
                    .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onClose)
                    .background(Color.White.copy(alpha = 0.08f), CircleShape)
                    .padding(4.dp),
            ) {
                Icon(Icons.Rounded.Close, contentDescription = "Tutup", tint = AppColors.textMuted, modifier = Modifier.size(14.dp))
            }
        }
        Spacer(Modifier.height(12.dp))
        ProfileMorphingMenuItem(
            icon = Icons.Outlined.PersonAddAlt1,
            title = "New Profile",
            subtitle = "Tambah akun profil baru",
            onTap = { onAction(onNewProfile ?: { showEditProfileModal(host) }) },
        )
        Spacer(Modifier.height(8.dp))
        ProfileMorphingMenuItem(
            icon = Icons.Rounded.FavoriteBorder,
            title = "Health Finance Details",
            subtitle = "Audit komprehensif keuangan",
            onTap = { onAction(onHealthDetails ?: { showFinancialHealthModal(host) }) },
        )
        if (onFinancialReport != null) {
            Spacer(Modifier.height(8.dp))
            ProfileMorphingMenuItem(
                icon = Icons.Rounded.PieChartOutline,
                title = "Laporan Keuangan",
                subtitle = "Ringkasan arus kas & kategori",
                onTap = { onAction(onFinancialReport) },
            )
        }
        if (onSettings != null) {
            Spacer(Modifier.height(8.dp))
            ProfileMorphingMenuItem(
                icon = Icons.Rounded.Tune,
                title = "Pengaturan",
                subtitle = "Mata uang, kategori, & data lokal",
                onTap = { onAction(onSettings) },
            )
        }
        Spacer(Modifier.height(8.dp))
        ProfileMorphingMenuItem(
            icon = Icons.Outlined.Share,
            title = "Share Profile",
            subtitle = "Bagikan kartu profil finansial",
            onTap = { onAction(onShareProfile) },
        )
    }
}

@Composable
fun ProfileMorphingMenuItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onTap: () -> Unit,
    iconColor: Color? = null,
    titleColor: Color? = null,
) {
    val tint = iconColor ?: AppColors.neoChartreuse
    val shape = RoundedCornerShape(12.dp)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onTap)
            .background(Color.White.copy(alpha = 0.04f), shape)
            .border(1.dp, Color.White.copy(alpha = 0.06f), shape)
            .padding(horizontal = 10.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier.size(30.dp).background(tint.copy(alpha = 0.12f), RoundedCornerShape(8.dp)),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(15.dp))
        }
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = jakarta(12.sp, FontWeight.Bold, titleColor ?: Color.White))
            Spacer(Modifier.height(2.dp))
            Text(
                subtitle,
                style = jakarta(9.5.sp, FontWeight.Medium, AppColors.textMuted),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
        Icon(Icons.Rounded.ChevronRight, contentDescription = null, tint = AppColors.textMuted, modifier = Modifier.size(15.dp))
    }
}
