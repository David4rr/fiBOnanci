package com.fibonanci.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors

fun showEditProfileModal(host: ModalHost, profile: ProfileEntry? = null) {
    host.show(ModalKind.Sheet) { dismiss ->
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .windowInsetsPadding(WindowInsets.ime),
        ) {
            EditProfileModal(initialProfile = profile, onDismiss = dismiss)
        }
    }
}

// saves the form through the view model and shows the dart snackbars
internal fun saveProfileForm(
    vm: FinanceViewModel,
    host: ModalHost,
    form: EditProfileFormState,
    initialProfile: ProfileEntry?,
    selectedAvatar: String?,
    setActive: Boolean,
) {
    val username = form.username.trim().replace("@", "")
    val fullName = form.fullName.trim()
    val email = form.email.trim().ifEmpty { null }
    val phone = form.phone.trim().ifEmpty { null }
    val occupation = form.occupation.trim().ifEmpty { null }
    val bio = form.bio.trim().ifEmpty { null }
    if (initialProfile != null) {
        vm.updateProfile(
            profileId = initialProfile.id, username = username, fullName = fullName, email = email, phone = phone,
            avatarPath = selectedAvatar, occupation = occupation, bio = bio,
            currency = initialProfile.currency, monthlyIncomeTarget = initialProfile.monthlyIncomeTarget,
        )
        host.showSnackBar("Profil $username berhasil diperbarui!", background = AppColors.neoMint)
    } else {
        vm.addProfile(
            username = username, fullName = fullName, email = email, phone = phone,
            avatarPath = selectedAvatar, occupation = occupation, bio = bio, setActive = setActive,
        )
        host.showSnackBar("Profil $username berhasil dibuat!", background = AppColors.neoChartreuse)
    }
}

@Composable
fun EditProfileModal(
    initialProfile: ProfileEntry? = null,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    val form = remember { EditProfileFormState(initialProfile) }
    var selectedAvatar by remember {
        val p = initialProfile?.avatarPath
        mutableStateOf(if (p != null && !p.startsWith("preset:") && p.isNotEmpty()) p else null)
    }
    val setActive = true
    val isEditing = initialProfile != null
    val existingUsernames = state.profiles.filter { it.id != initialProfile?.id }.map { it.username }
    val pick = EditProfileAvatarPicker.rememberImagePicker(maxDimension = 1024) { selectedAvatar = it }
    val maxHeight: Dp = LocalConfiguration.current.screenHeightDp.dp * 0.88f

    fun onSave() {
        if (!form.validate(existingUsernames)) return
        saveProfileForm(vm, host, form, initialProfile, selectedAvatar, setActive)
        onDismiss()
    }

    Column(Modifier.fillMaxWidth().heightIn(max = maxHeight)) {
        EditProfileHeader(isEditing = isEditing, onClose = onDismiss)
        Box(Modifier.fillMaxWidth().height(16.dp), contentAlignment = Alignment.Center) {
            HorizontalDivider(thickness = 1.dp, color = AppColors.canvasBorder)
        }
        Column(
            modifier = Modifier
                .weight(1f, fill = false)
                .verticalScroll(rememberScrollState())
                .padding(start = 24.dp, top = 8.dp, end = 24.dp, bottom = 24.dp),
        ) {
            EditProfileAvatarPicker.buildPickerWidget(
                avatarPath = selectedAvatar,
                name = form.username,
                onTap = {
                    EditProfileAvatarPicker.showSourceDialog(
                        host,
                        hasPhoto = !selectedAvatar.isNullOrEmpty(),
                        onSelectSource = pick,
                        onRemovePhoto = { selectedAvatar = null },
                    )
                },
            )
            Spacer(Modifier.height(24.dp))
            EditProfileForm(form = form, existingUsernames = existingUsernames)
            Spacer(Modifier.height(24.dp))
            Button(
                onClick = { onSave() },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = AppColors.neoChartreuse,
                    contentColor = AppColors.textDarkPrimary,
                ),
                contentPadding = PaddingValues(vertical = 14.dp),
            ) {
                Text(
                    if (isEditing) "Simpan Perubahan" else "Buat Profil Baru",
                    style = jakarta(14.sp, FontWeight.ExtraBold),
                )
            }
        }
    }
}
