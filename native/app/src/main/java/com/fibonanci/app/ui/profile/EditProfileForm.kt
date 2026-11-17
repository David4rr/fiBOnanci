package com.fibonanci.app.ui.profile

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Badge
import androidx.compose.material.icons.rounded.AlternateEmail
import androidx.compose.material.icons.rounded.MailOutline
import androidx.compose.material.icons.outlined.Phone
import androidx.compose.material.icons.rounded.Notes
import androidx.compose.material.icons.rounded.WorkOutline
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader

@Composable
fun EditProfileHeader(isEditing: Boolean, onClose: () -> Unit) {
    Column(Modifier.fillMaxWidth().padding(start = 24.dp, top = 16.dp, end = 24.dp)) {
        ModalGrabHandle()
        ModalHeader(
            title = if (isEditing) "Edit Profil" else "Tambah Profil Baru",
            padding = PaddingValues(0.dp),
            onClose = onClose,
        )
    }
}

private val usernamePattern = Regex("^[a-zA-Z0-9_.]+$")

// username validator from the dart form
fun validateProfileUsername(value: String, existingUsernames: List<String>?): String? {
    if (value.trim().isEmpty()) return "Username wajib diisi"
    val clean = value.trim().replace("@", "")
    if (clean.length < 2) return "Username minimal 2 karakter"
    if (!usernamePattern.matches(clean)) return "Hanya huruf, angka, titik, dan garis bawah (_)"
    if (existingUsernames != null && existingUsernames.any { it.lowercase() == clean.lowercase() }) {
        return "Username @$clean sudah digunakan"
    }
    return null
}

fun validateProfileFullName(value: String): String? =
    if (value.trim().isEmpty()) "Nama lengkap wajib diisi" else null

// field values + validation errors shared by the edit modal and the edit tab (replaces Form + controllers)
class EditProfileFormState(initialProfile: ProfileEntry?) {
    var username by mutableStateOf(initialProfile?.username ?: "")
    var fullName by mutableStateOf(initialProfile?.fullName ?: "")
    var email by mutableStateOf(initialProfile?.email ?: "")
    var phone by mutableStateOf(initialProfile?.phone ?: "")
    var occupation by mutableStateOf(initialProfile?.occupation ?: "")
    var bio by mutableStateOf(initialProfile?.bio ?: "")
    var usernameError by mutableStateOf<String?>(null)
    var fullNameError by mutableStateOf<String?>(null)

    fun validate(existingUsernames: List<String>?): Boolean {
        usernameError = validateProfileUsername(username, existingUsernames)
        fullNameError = validateProfileFullName(fullName)
        return usernameError == null && fullNameError == null
    }
}

@Composable
fun EditProfileForm(
    form: EditProfileFormState,
    existingUsernames: List<String>? = null,
) {
    Column(Modifier.fillMaxWidth()) {
        EditProfileInputField(
            label = "Username / Handle",
            value = form.username,
            onValueChange = { form.username = it },
            hintText = "e.g. david_arrozaqi",
            prefixIcon = Icons.Rounded.AlternateEmail,
            errorText = form.usernameError,
        )
        Spacer(Modifier.height(12.dp))
        EditProfileInputField(
            label = "Nama Lengkap",
            value = form.fullName,
            onValueChange = { form.fullName = it },
            hintText = "Nama lengkapmu",
            prefixIcon = Icons.Outlined.Badge,
            errorText = form.fullNameError,
        )
        Spacer(Modifier.height(12.dp))
        EditProfileInputField(
            label = "Email",
            value = form.email,
            onValueChange = { form.email = it },
            hintText = "nama@email.com",
            prefixIcon = Icons.Rounded.MailOutline,
            keyboardType = KeyboardType.Email,
        )
        Spacer(Modifier.height(12.dp))
        EditProfileInputField(
            label = "No. Handphone / WhatsApp",
            value = form.phone,
            onValueChange = { form.phone = it },
            hintText = "e.g. +62 812-3456-7890",
            prefixIcon = Icons.Outlined.Phone,
            keyboardType = KeyboardType.Phone,
        )
        Spacer(Modifier.height(12.dp))
        EditProfileInputField(
            label = "Profesi / Pekerjaan",
            value = form.occupation,
            onValueChange = { form.occupation = it },
            hintText = "e.g. Software Engineer",
            prefixIcon = Icons.Rounded.WorkOutline,
        )
        Spacer(Modifier.height(12.dp))
        EditProfileInputField(
            label = "Bio / Catatan Pribadi",
            value = form.bio,
            onValueChange = { form.bio = it },
            hintText = "e.g. Membangun kebebasan finansial",
            prefixIcon = Icons.Rounded.Notes,
            maxLines = 2,
        )
    }
}
