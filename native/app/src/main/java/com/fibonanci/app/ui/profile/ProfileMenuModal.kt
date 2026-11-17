package com.fibonanci.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.PersonAddAlt1
import androidx.compose.material.icons.outlined.Share
import androidx.compose.material.icons.rounded.FavoriteBorder
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.health.showFinancialHealthModal
import com.fibonanci.app.ui.theme.AppColors

fun showProfileMenuModal(
    host: ModalHost,
    profile: ProfileEntry,
    totalProfiles: Int = 1,
    onHealthDetails: (() -> Unit)? = null,
    onEditProfile: (() -> Unit)? = null,
    onNewProfile: (() -> Unit)? = null,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        val clipboard = LocalClipboardManager.current
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasBg, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Bottom + WindowInsetsSides.Horizontal))
                .padding(start = 20.dp, top = 12.dp, end = 20.dp, bottom = 24.dp),
        ) {
            ModalGrabHandle()
            Spacer(Modifier.height(8.dp))
            ModalHeader(title = "Menu Profil", padding = PaddingValues(0.dp), onClose = dismiss)
            Spacer(Modifier.height(14.dp))
            ProfileMorphingMenuItem(
                icon = Icons.Outlined.PersonAddAlt1,
                title = "New Profile",
                subtitle = "Tambah akun profil baru di perangkat",
                onTap = {
                    dismiss()
                    if (onNewProfile != null) onNewProfile() else showEditProfileModal(host)
                },
            )
            Spacer(Modifier.height(8.dp))
            ProfileMorphingMenuItem(
                icon = Icons.Rounded.FavoriteBorder,
                title = "Health Finance Details",
                subtitle = "Audit komprehensif 4 pilar kesehatan keuangan",
                onTap = {
                    dismiss()
                    if (onHealthDetails != null) onHealthDetails() else showFinancialHealthModal(host)
                },
            )
            Spacer(Modifier.height(8.dp))
            ProfileMorphingMenuItem(
                icon = Icons.Outlined.Share,
                title = "Share Profile",
                subtitle = "Bagikan kartu profil finansial",
                onTap = {
                    dismiss()
                    clipboard.setText(AnnotatedString("${profile.fullName} (@${profile.username}) - fiBOnanci"))
                    host.showSnackBar("Kartu profil berhasil disalin!")
                },
            )
        }
    }
}
