package com.fibonanci.app.ui.profile

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.outlined.CameraAlt
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.PhotoLibrary
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

enum class ImageSource { gallery, camera }

object EditProfileAvatarPicker {

    @Composable
    fun buildPickerWidget(
        avatarPath: String?,
        name: String,
        onTap: () -> Unit,
    ) {
        val hasPhoto = !avatarPath.isNullOrEmpty()
        val shape = RoundedCornerShape(18.dp)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onTap)
                .background(AppColors.canvasInputSearch, shape)
                .border(1.dp, AppColors.canvasBorder, shape)
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box {
                ProfileAvatar(avatarPath = avatarPath, name = name, size = 56.dp, iconSize = 28.dp)
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .offset(2.dp, 2.dp)
                        .background(AppColors.neoChartreuse, CircleShape)
                        .border(2.dp, Color(0xFF17181F), CircleShape)
                        .padding(5.dp),
                ) {
                    Icon(Icons.Filled.CameraAlt, contentDescription = null, tint = AppColors.textDarkPrimary, modifier = Modifier.size(11.dp))
                }
            }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f)) {
                Text("Foto Profil", style = jakarta(14.sp, FontWeight.Bold, AppColors.textWhite))
                Spacer(Modifier.height(3.dp))
                Text(
                    if (hasPhoto) "Foto kustom aktif • Ketuk untuk ganti" else "Ketuk untuk pilih dari galeri atau kamera",
                    style = AppTypography.listSubtitle.copy(
                        fontSize = 11.5.sp,
                        color = if (hasPhoto) AppColors.neoMint else AppColors.textMuted,
                    ),
                )
            }
            Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = AppColors.textMuted, modifier = Modifier.size(20.dp))
        }
    }

    // registers the gallery / camera launchers; the returned lambda starts a pick for a source.
    // the picked image is downscaled to maxDimension, re-encoded as jpeg 85 and copied into filesDir/avatars/
    @Composable
    fun rememberImagePicker(maxDimension: Int, onPicked: (String) -> Unit): (ImageSource) -> Unit {
        val context = LocalContext.current
        val host = LocalModalHost.current
        val scope = rememberCoroutineScope()
        val currentOnPicked by rememberUpdatedState(onPicked)

        fun save(load: () -> Bitmap?) {
            scope.launch {
                try {
                    val path = withContext(Dispatchers.IO) { saveAvatar(context, load(), maxDimension) }
                    if (path != null) currentOnPicked(path)
                } catch (e: Exception) {
                    host.showSnackBar("Gagal mengambil foto: $e", background = AppColors.neoCoral)
                }
            }
        }

        val gallery = rememberLauncherForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri: Uri? ->
            if (uri != null) save { context.contentResolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it) } }
        }
        val camera = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { bitmap: Bitmap? ->
            if (bitmap != null) save { bitmap }
        }
        return { source ->
            try {
                when (source) {
                    ImageSource.gallery -> gallery.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                    ImageSource.camera -> camera.launch(null)
                }
            } catch (e: Exception) {
                host.showSnackBar("Gagal mengambil foto: $e", background = AppColors.neoCoral)
            }
        }
    }

    private fun saveAvatar(context: Context, source: Bitmap?, maxDimension: Int): String? {
        if (source == null) return null
        val scale = minOf(1f, maxDimension.toFloat() / maxOf(source.width, source.height))
        val bitmap = if (scale < 1f) {
            Bitmap.createScaledBitmap(source, (source.width * scale).toInt(), (source.height * scale).toInt(), true)
        } else {
            source
        }
        val dir = File(context.filesDir, "avatars").apply { mkdirs() }
        val file = File(dir, "avatar_${System.currentTimeMillis()}.jpg")
        file.outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 85, it) }
        return file.absolutePath
    }

    fun showSourceDialog(
        host: ModalHost,
        hasPhoto: Boolean,
        onSelectSource: (ImageSource) -> Unit,
        onRemovePhoto: () -> Unit,
    ) {
        host.show(ModalKind.Sheet) { dismiss ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFF17181F), RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                    .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Bottom + WindowInsetsSides.Horizontal))
                    .padding(vertical = 20.dp, horizontal = 24.dp),
            ) {
                ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
                ModalHeader(title = "Pilih Sumber Foto", subtitle = "Galeri perangkat atau kamera", onClose = dismiss)
                SourceTile(
                    icon = Icons.Outlined.PhotoLibrary,
                    color = AppColors.neoChartreuse,
                    title = "Galeri Foto",
                    titleColor = AppColors.textWhite,
                    subtitle = "Pilih gambar dari galeri perangkat",
                ) {
                    dismiss()
                    onSelectSource(ImageSource.gallery)
                }
                SourceDivider()
                SourceTile(
                    icon = Icons.Outlined.CameraAlt,
                    color = AppColors.neoCyan,
                    title = "Kamera",
                    titleColor = AppColors.textWhite,
                    subtitle = "Ambil foto baru langsung dari kamera",
                ) {
                    dismiss()
                    onSelectSource(ImageSource.camera)
                }
                if (hasPhoto) {
                    SourceDivider()
                    SourceTile(
                        icon = Icons.Outlined.Delete,
                        color = Color(0xFFEF4444),
                        title = "Hapus Foto Profil",
                        titleColor = Color(0xFFEF4444),
                        subtitle = "Gunakan inisial nama sebagai avatar",
                    ) {
                        dismiss()
                        onRemovePhoto()
                    }
                }
            }
        }
    }

    @Composable
    private fun SourceDivider() {
        Box(Modifier.fillMaxWidth().height(20.dp), contentAlignment = Alignment.Center) {
            HorizontalDivider(thickness = 1.dp, color = AppColors.canvasBorder)
        }
    }

    // list tile with zero content padding (72dp two-line height)
    @Composable
    private fun SourceTile(
        icon: ImageVector,
        color: Color,
        title: String,
        titleColor: Color,
        subtitle: String,
        onTap: () -> Unit,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onTap)
                .padding(vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(Modifier.background(color.copy(alpha = 0.15f), RoundedCornerShape(12.dp)).padding(10.dp)) {
                Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
            }
            Spacer(Modifier.width(16.dp))
            Column {
                Text(title, style = jakarta(14.sp, FontWeight.SemiBold, titleColor))
                Text(subtitle, style = AppTypography.listSubtitle.copy(fontSize = 11.sp))
            }
        }
    }
}
