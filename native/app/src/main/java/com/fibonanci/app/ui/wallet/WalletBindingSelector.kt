package com.fibonanci.app.ui.wallet

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.EditNote
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.outlined.NotificationsActive
import androidx.compose.material.icons.rounded.Apps
import androidx.compose.material.icons.rounded.Search
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.notification.kPopularBankAppPresets
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

private const val CUSTOM_VALUE = "__custom__"

// dart TextEditingController customPackageController -> customPackageText + onCustomPackageTextChange
@Composable
fun WalletBindingSelector(
    selectedPackage: String?,
    isCustomPackage: Boolean,
    customPackageText: String,
    onCustomPackageTextChange: (String) -> Unit,
    onPackageChanged: (String?, Boolean) -> Unit,
    onOpenAppPicker: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    var menuOpen by remember { mutableStateOf(false) }

    fun openPicker() {
        if (onOpenAppPicker != null) {
            onOpenAppPicker()
            return
        }
        showInstalledAppPickerModal(host) { picked ->
            onCustomPackageTextChange(picked)
            onPackageChanged(picked, true)
        }
    }

    val currentValue = if (isCustomPackage) CUSTOM_VALUE else selectedPackage

    Column(modifier.fillMaxWidth()) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                "Hubungkan Notifikasi Aplikasi (Opsional)",
                style = AppTypography.badgeLabel.copy(color = AppColors.textMuted),
                overflow = TextOverflow.Ellipsis,
                maxLines = 1,
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(8.dp))
            Row(
                Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .clickable { openPicker() }
                    .padding(horizontal = 6.dp, vertical = 2.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Rounded.Search, contentDescription = null, tint = AppColors.neoCyan, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(4.dp))
                Text(
                    "Cari App",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.W700,
                        color = AppColors.neoCyan,
                    ),
                )
            }
        }
        Spacer(Modifier.height(6.dp))
        Box(
            Modifier
                .fillMaxWidth()
                .background(AppColors.canvasInputSearch, RoundedCornerShape(16.dp))
                .clip(RoundedCornerShape(16.dp))
                .clickable { menuOpen = true }
                .padding(horizontal = 14.dp, vertical = 2.dp)
                .heightIn(min = 48.dp),
        ) {
            Row(Modifier.fillMaxWidth().align(Alignment.CenterStart), verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.weight(1f)) { DropdownItemContent(currentValue) }
                Icon(Icons.Filled.KeyboardArrowDown, contentDescription = null, tint = AppColors.textMuted)
            }
            DropdownMenu(
                expanded = menuOpen,
                onDismissRequest = { menuOpen = false },
                containerColor = AppColors.canvasCardSurface,
            ) {
                val values = listOf<String?>(null) + kPopularBankAppPresets.map { it.packageName } + CUSTOM_VALUE
                for (value in values) {
                    DropdownMenuItem(
                        text = { DropdownItemContent(value) },
                        onClick = {
                            menuOpen = false
                            if (value == CUSTOM_VALUE) onPackageChanged(null, true) else onPackageChanged(value, false)
                        },
                    )
                }
            }
        }
        if (isCustomPackage) {
            Spacer(Modifier.height(8.dp))
            TextField(
                value = customPackageText,
                onValueChange = onCustomPackageTextChange,
                modifier = Modifier.fillMaxWidth(),
                textStyle = AppTypography.listTitle,
                placeholder = { Text("Package Name (contoh: id.krom.bank)", style = AppTypography.listSubtitle) },
                trailingIcon = {
                    // tooltip: pilih dari aplikasi terpasang
                    IconButton(onClick = { openPicker() }) {
                        Icon(
                            Icons.Rounded.Apps,
                            contentDescription = "Pilih dari Aplikasi Terpasang",
                            tint = AppColors.neoCyan,
                            modifier = Modifier.size(18.dp),
                        )
                    }
                },
                singleLine = true,
                shape = RoundedCornerShape(16.dp),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = AppColors.canvasInputSearch,
                    unfocusedContainerColor = AppColors.canvasInputSearch,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                ),
            )
        }
    }
}

// a value that matches no item shows the hint, like DropdownButton
@Composable
private fun DropdownItemContent(value: String?) {
    val preset = kPopularBankAppPresets.firstOrNull { it.packageName == value }
    when {
        value == CUSTOM_VALUE -> Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Filled.EditNote, contentDescription = null, tint = AppColors.neoCyan, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(8.dp))
            Text(
                "Cari / Input Package Lain...",
                style = TextStyle(color = AppColors.neoCyan),
                overflow = TextOverflow.Ellipsis,
                maxLines = 1,
                modifier = Modifier.weight(1f),
            )
        }
        preset != null -> Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Outlined.NotificationsActive, contentDescription = null, tint = AppColors.neoChartreuse, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(8.dp))
            Text(
                "${preset.name} (${preset.packageName})",
                style = AppTypography.listTitle,
                overflow = TextOverflow.Ellipsis,
                maxLines = 1,
                modifier = Modifier.weight(1f),
            )
        }
        else -> Text("Tidak Terhubung (Input Manual)", style = AppTypography.listSubtitle)
    }
}
