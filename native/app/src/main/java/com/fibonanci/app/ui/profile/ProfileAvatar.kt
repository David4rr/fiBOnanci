package com.fibonanci.app.ui.profile

import android.graphics.BitmapFactory
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.BusinessCenter
import androidx.compose.material.icons.rounded.Explore
import androidx.compose.material.icons.rounded.Palette
import androidx.compose.material.icons.rounded.Person
import androidx.compose.material.icons.rounded.Spa
import androidx.compose.material.icons.rounded.SportsEsports
import androidx.compose.material.icons.rounded.TrendingUp
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import java.io.File

data class AvatarPreset(
    val id: String,
    val label: String,
    val icon: ImageVector,
    val color: Color,
    val bgTint: Color,
)

object ProfileAvatarPresets {
    val presets: List<AvatarPreset> = listOf(
        AvatarPreset("preset:avatar_1", "Default", Icons.Rounded.Person, AppColors.neoChartreuse, Color(0xFF1E212D)),
        AvatarPreset("preset:avatar_2", "Eksekutif", Icons.Rounded.BusinessCenter, AppColors.neoCyan, Color(0xFF122838)),
        AvatarPreset("preset:avatar_3", "Finansial", Icons.Rounded.TrendingUp, AppColors.neoChartreuse, Color(0xFF262C10)),
        AvatarPreset("preset:avatar_4", "Kreatif", Icons.Rounded.Palette, AppColors.neoCoral, Color(0xFF331B17)),
        AvatarPreset("preset:avatar_5", "Zen", Icons.Rounded.Spa, Color(0xFF10B981), Color(0xFF0F2D20)),
        AvatarPreset("preset:avatar_6", "Petualang", Icons.Rounded.Explore, Color(0xFFFBBF24), Color(0xFF2E240D)),
        AvatarPreset("preset:avatar_7", "Gamer", Icons.Rounded.SportsEsports, Color(0xFFA78BFA), Color(0xFF26193E)),
        AvatarPreset("preset:avatar_8", "Klasik", Icons.Rounded.Person, AppColors.textWhite, Color(0xFF1E212D)),
    )

    fun getById(id: String?): AvatarPreset {
        if (id == null) return presets.first()
        return presets.firstOrNull { it.id == id } ?: presets.first()
    }
}

@Composable
fun ProfileAvatar(
    avatarPath: String? = null,
    name: String,
    size: Dp = 42.dp,
    border: BorderStroke? = null,
    iconSize: Dp? = null,
    modifier: Modifier = Modifier,
) {
    val resolvedIconSize = iconSize ?: (size * 0.5f)

    // 1. local file avatar, decoded once per path
    if (avatarPath != null && !avatarPath.startsWith("preset:") && avatarPath.isNotEmpty()) {
        val bitmap = remember(avatarPath) {
            val file = File(avatarPath)
            if (file.exists()) BitmapFactory.decodeFile(file.path)?.asImageBitmap() else null
        }
        if (bitmap != null) {
            Image(
                bitmap = bitmap,
                contentDescription = name,
                contentScale = ContentScale.Crop,
                modifier = modifier
                    .size(size)
                    .clip(CircleShape)
                    .border(border ?: BorderStroke(1.5.dp, AppColors.canvasBorder), CircleShape),
            )
            return
        }
    }

    // 2. preset avatar
    val isPreset = avatarPath != null && avatarPath.startsWith("preset:")
    val preset = ProfileAvatarPresets.getById(avatarPath)
    if (isPreset) {
        Box(
            modifier = modifier
                .size(size)
                .background(preset.bgTint, CircleShape)
                .border(border ?: BorderStroke(1.5.dp, preset.color.copy(alpha = 0.5f)), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(preset.icon, contentDescription = null, tint = preset.color, modifier = Modifier.size(resolvedIconSize))
        }
        return
    }

    // 3. fallback: default person icon
    Box(
        modifier = modifier
            .size(size)
            .background(Color(0xFF1E212D), CircleShape)
            .border(border ?: BorderStroke(1.5.dp, AppColors.canvasBorder), CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        Icon(Icons.Rounded.Person, contentDescription = null, tint = AppColors.neoChartreuse, modifier = Modifier.size(resolvedIconSize))
    }
}
