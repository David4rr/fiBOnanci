package com.fibonanci.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material3.Icon
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.showAppConfirmationDialog
import com.fibonanci.app.ui.theme.AppColors

fun showProfileDeleteDialog(host: ModalHost, vm: FinanceViewModel, profile: ProfileEntry, totalProfiles: Int) {
    val danger = Color(0xFFEF4444)
    showAppConfirmationDialog(
        host,
        title = if (totalProfiles > 1) "Hapus Profil?" else "Reset Profil?",
        content = if (totalProfiles > 1) {
            "Profil \"${profile.username}\" akan dihapus. Anda dapat beralih ke profil lain yang masih tersimpan."
        } else {
            "Profil \"${profile.username}\" adalah satu-satunya profil. Profil akan direset ke pengaturan default."
        },
        confirmText = if (totalProfiles > 1) "Hapus" else "Reset",
        confirmColor = danger,
        titleLeading = {
            Box(
                modifier = Modifier.size(36.dp).background(danger.copy(alpha = 0.15f), CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.Rounded.DeleteOutline, contentDescription = null, tint = danger, modifier = Modifier.size(20.dp))
            }
        },
        onConfirm = {
            vm.deleteProfile(profile.id)
            host.showSnackBar(
                if (totalProfiles > 1) "Profil \"${profile.username}\" berhasil dihapus" else "Profil berhasil direset",
                background = AppColors.neoCoral,
            )
        },
    )
}
