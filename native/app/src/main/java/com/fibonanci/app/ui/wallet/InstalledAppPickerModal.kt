package com.fibonanci.app.ui.wallet

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Android
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material.icons.rounded.Search
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.notification.InstalledApp
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.notification.kPopularBankAppPresets
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

// sheet variant; the picked package name is delivered through onResult
fun showInstalledAppPickerModal(host: ModalHost, onResult: (String) -> Unit) {
    host.show { dismiss ->
        InstalledAppPickerModal(
            onAppSelected = { picked ->
                dismiss()
                onResult(picked)
            },
            onClose = dismiss,
        )
    }
}

private fun presetApps(): List<InstalledApp> =
    kPopularBankAppPresets.map { InstalledApp(packageName = it.packageName, appName = it.name) }

@Composable
fun InstalledAppPickerModal(
    isInline: Boolean = false,
    onAppSelected: ((String) -> Unit)? = null,
    onClose: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    var searchText by rememberSaveable { mutableStateOf("") }
    // initial state mirrors initState: cache first, presets when inline, otherwise loading
    val initial = remember {
        val cached = NotificationBridge.cachedInstalledBankApps
        when {
            !cached.isNullOrEmpty() -> cached
            isInline -> presetApps()
            else -> null
        }
    }
    var allApps by remember { mutableStateOf(initial ?: emptyList()) }
    var isLoading by remember { mutableStateOf(initial == null) }

    LaunchedEffect(Unit) {
        val apps = NotificationBridge.getInstalledBankApps(context)
        allApps = if (apps.isEmpty()) presetApps() else apps
        isLoading = false
    }

    val q = searchText.trim().lowercase()
    val filteredApps = if (q.isEmpty()) {
        allApps
    } else {
        allApps.filter { it.appName.lowercase().contains(q) || it.packageName.lowercase().contains(q) }
    }

    val content: @Composable () -> Unit = {
        Column(Modifier.fillMaxSize()) {
            if (!isInline) {
                ModalGrabHandle()
                ModalHeader(
                    title = "Pilih Aplikasi",
                    subtitle = "Cari bank atau e-wallet di HP Anda",
                    onClose = onClose,
                )
            }
            TextField(
                value = searchText,
                onValueChange = { searchText = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 20.dp, top = if (isInline) 4.dp else 8.dp, end = 20.dp, bottom = 8.dp),
                textStyle = AppTypography.listTitle,
                placeholder = { Text("Cari nama app atau package...", style = AppTypography.listSubtitle) },
                leadingIcon = { Icon(Icons.Rounded.Search, contentDescription = null, tint = AppColors.textMuted) },
                singleLine = true,
                shape = RoundedCornerShape(16.dp),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = AppColors.canvasInputSearch,
                    unfocusedContainerColor = AppColors.canvasInputSearch,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                ),
            )
            Box(Modifier.fillMaxWidth().weight(1f)) {
                when {
                    isLoading -> CircularProgressIndicator(color = AppColors.neoMint, modifier = Modifier.align(Alignment.Center))
                    filteredApps.isEmpty() -> Text(
                        "Aplikasi tidak ditemukan",
                        style = AppTypography.listSubtitle,
                        modifier = Modifier.align(Alignment.Center),
                    )
                    else -> LazyColumn(
                        Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 4.dp),
                    ) {
                        items(filteredApps) { app ->
                            AppRow(app) {
                                if (onAppSelected != null) onAppSelected(app.packageName) else onClose?.invoke()
                            }
                        }
                    }
                }
            }
        }
    }

    if (isInline) {
        Box(modifier.fillMaxSize().background(AppColors.canvasCardSurface)) { content() }
    } else {
        val height = LocalConfiguration.current.screenHeightDp.dp * 0.75f
        Box(
            modifier
                .fillMaxWidth()
                .height(height)
                .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)),
        ) { content() }
    }
}

@Composable
private fun AppRow(app: InstalledApp, onTap: () -> Unit) {
    Column(Modifier.fillMaxWidth().height(64.dp)) {
        Row(
            Modifier
                .fillMaxWidth()
                .weight(1f)
                .clickable(onClick = onTap)
                .padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier
                    .size(36.dp)
                    .background(AppColors.neoChartreuse.copy(alpha = 0.15f), RoundedCornerShape(10.dp)),
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.Rounded.Android, contentDescription = null, tint = AppColors.neoChartreuse, modifier = Modifier.size(20.dp))
            }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f).fillMaxHeight(), verticalArrangement = Arrangement.Center) {
                Text(app.appName.ifEmpty { "App" }, style = AppTypography.listTitle, maxLines = 1, overflow = TextOverflow.Ellipsis)
                Text(
                    app.packageName,
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textMuted, fontSize = 11.sp),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            Spacer(Modifier.width(16.dp))
            Icon(Icons.Rounded.ChevronRight, contentDescription = null, tint = AppColors.textMuted)
        }
        HorizontalDivider(thickness = 0.8.dp, color = AppColors.canvasBorder)
    }
}
