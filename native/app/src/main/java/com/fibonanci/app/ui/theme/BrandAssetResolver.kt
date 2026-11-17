package com.fibonanci.app.ui.theme

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Cloud
import androidx.compose.material.icons.outlined.HealthAndSafety
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.FitnessCenter
import androidx.compose.material.icons.rounded.HomeWork
import androidx.compose.material.icons.rounded.MusicNote
import androidx.compose.material.icons.automirrored.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.Tv
import androidx.compose.material.icons.rounded.WaterDrop
import androidx.compose.material.icons.rounded.Wifi
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector

/** centralized resolver for icons and colors of indonesian & global brands/services. */
object BrandAssetResolver {
    private fun String.hasAny(vararg keys: String) = keys.any { contains(it) }

    fun resolveIcon(title: String): ImageVector {
        val lower = title.lowercase()
        if (lower.hasAny(
                "netflix", "disney", "prime", "tv", "hbo", "youtube", "cinema",
                "vidio", "iqiyi", "wetv", "viu", "film",
            )
        ) return Icons.Rounded.Tv
        if (lower.hasAny(
                "spotify", "apple music", "music", "lagu", "audio", "joox",
                "tidal", "deezer", "resso", "soundcloud",
            )
        ) return Icons.Rounded.MusicNote
        if (lower.hasAny(
                "wifi", "internet", "indihome", "biznet", "first media", "firstmedia",
                "myrepublic", "telkomsel", "indosat", "xl", "smartfren", "tri",
                "pulsa", "kuota", "fiber",
            )
        ) return Icons.Rounded.Wifi
        if (lower.hasAny("pln", "listrik", "token")) return Icons.Rounded.Bolt
        if (lower.hasAny("pdam", "air")) return Icons.Rounded.WaterDrop
        if (lower.hasAny(
                "kost", "kos", "sewa", "kontrakan", "apartemen", "rumah", "ipl", "kpr", "cicilan",
            )
        ) return Icons.Rounded.HomeWork
        if (lower.hasAny(
                "icloud", "google", "drive", "dropbox", "storage", "notion", "figma",
                "adobe", "canva", "office", "microsoft", "cursor", "chatgpt", "openai",
                "claude", "github", "cloud",
            )
        ) return Icons.Outlined.Cloud
        if (lower.hasAny("gym", "fitness", "f45", "celebrity", "gold", "member", "club")) {
            return Icons.Rounded.FitnessCenter
        }
        if (lower.hasAny("bpjs", "asuransi", "pajak", "pbb")) return Icons.Outlined.HealthAndSafety
        return Icons.AutoMirrored.Rounded.ReceiptLong
    }

    fun resolveColor(title: String): Color {
        val lower = title.lowercase()
        if (lower.hasAny("spotify", "music")) return AppColors.neoMint
        if (lower.hasAny("wifi", "internet", "cloud")) return AppColors.neoCyan
        if (lower.hasAny("pln", "listrik")) return Color(0xFFFFD166)
        if (lower.hasAny("kost", "sewa")) return AppColors.neoChartreuse
        return AppColors.neoCoral
    }
}
