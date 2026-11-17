package com.fibonanci.app.ui.profile

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors

@Composable
fun ProfileEditTab(
    initialProfile: ProfileEntry? = null,
    onSaved: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    val form = remember { EditProfileFormState(initialProfile) }
    var selectedAvatar by remember {
        val p = initialProfile?.avatarPath
        mutableStateOf(if (p != null && !p.startsWith("preset:") && p.isNotEmpty()) p else null)
    }
    val isEditing = initialProfile != null
    val existingUsernames = state.profiles.filter { it.id != initialProfile?.id }.map { it.username }
    val pick = EditProfileAvatarPicker.rememberImagePicker(maxDimension = 512) { selectedAvatar = it }

    fun onSave() {
        if (!form.validate(existingUsernames)) return
        saveProfileForm(vm, host, form, initialProfile, selectedAvatar, setActive = true)
        onSaved()
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 36.dp),
    ) {
        item {
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
            Spacer(Modifier.height(20.dp))
            EditProfileForm(form = form, existingUsernames = existingUsernames)
            Spacer(Modifier.height(24.dp))
            Button(
                onClick = { onSave() },
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = AppColors.neoChartreuse,
                    contentColor = AppColors.textDarkPrimary,
                ),
                elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
            ) {
                Text(
                    if (isEditing) "Simpan Perubahan" else "Buat Profil Baru",
                    style = jakarta(14.sp, FontWeight.ExtraBold),
                )
            }
        }
    }
}
