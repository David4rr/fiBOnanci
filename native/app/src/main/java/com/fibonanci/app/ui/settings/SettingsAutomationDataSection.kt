package com.fibonanci.app.ui.settings

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.app.NotificationManagerCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LifecycleEventEffect
import com.fibonanci.app.core.notification.kPopularBankAppPresets
import com.fibonanci.app.core.security.SecurityVault
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.toJson
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.UiStyle
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

private fun Context.findActivity(): Activity? {
    var c: Context? = this
    while (c is ContextWrapper) {
        if (c is Activity) return c
        c = c.baseContext
    }
    return null
}

private fun isNotificationPermissionGranted(context: Context): Boolean =
    NotificationManagerCompat.getEnabledListenerPackages(context).contains(context.packageName)

// display name of a document picked/created through the storage access framework
private fun displayName(context: Context, uri: Uri): String {
    context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
        if (c.moveToFirst()) c.getString(0)?.let { return it }
    }
    return uri.lastPathSegment ?: uri.toString()
}

private suspend fun writeDocument(context: Context, uri: Uri, content: String) = withContext(Dispatchers.IO) {
    context.contentResolver.openOutputStream(uri, "wt")!!.use { it.write(content.toByteArray(Charsets.UTF_8)) }
}

@Composable
fun SettingsAutomationDataSection(state: FinanceState, onNavigate: (SettingsSubRoute) -> Unit, isGlobal: Boolean = true) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var permissionGranted by remember { mutableStateOf(false) }
    var biometricEnabled by remember { mutableStateOf(false) }
    var privacyScreenEnabled by remember { mutableStateOf(false) }

    fun checkPermission() {
        permissionGranted = isNotificationPermissionGranted(context)
        biometricEnabled = SecurityVault.isBiometricLockEnabled(context)
        privacyScreenEnabled = SecurityVault.isPrivacyScreenEnabled(context)
    }
    // initState + re-check when returning from the listener settings screen
    LifecycleEventEffect(Lifecycle.Event.ON_RESUME) { checkPermission() }

    fun toggleBiometric(v: Boolean) {
        val apply = {
            SecurityVault.setBiometricLockEnabled(context, v)
            biometricEnabled = v
        }
        val activity = context.findActivity()
        if (v && activity != null) {
            SecurityVault.authenticate(activity, "Konfirmasi untuk mengaktifkan Kunci Biometrik / PIN") { ok ->
                activity.runOnUiThread { if (ok) apply() }
            }
        } else {
            apply()
        }
    }

    fun togglePrivacyScreen(v: Boolean) {
        context.findActivity()?.let { SecurityVault.applyPrivacyScreen(it, v) }
        privacyScreenEnabled = v
    }

    val exportLauncher = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("application/json")) { uri ->
        if (uri == null) return@rememberLauncherForActivityResult
        val s = state
        val payload = JSONObject()
            .put("exportedAt", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
            .put("profile", JSONObject().put("id", s.profile.id).put("username", s.profile.username).put("currency", s.profile.currency))
            .put("walletsCount", s.wallets.size).put("pocketsCount", s.pockets.size)
            .put("subscriptionsCount", s.subscriptions.size).put("transactionsCount", s.transactions.size)
            .put("profiles", JSONArray(s.profiles.map { it.toJson() }))
            .put("categories", JSONArray(s.categories.map { it.toJson() }))
            .put("wallets", JSONArray(s.wallets.map { it.toJson() }))
            .put("pockets", JSONArray(s.pockets.map { it.toJson() }))
            .put("subscriptions", JSONArray(s.subscriptions.map { it.toJson() }))
            .put("transactions", JSONArray(s.transactions.map { it.toJson() }))
        scope.launch {
            writeDocument(context, uri, payload.toString(2))
            host.showSnackBar("File JSON disimpan: ${displayName(context, uri)}", background = AppColors.neoChartreuse)
        }
    }

    val importLauncher = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri == null) {
            host.showSnackBar("File cadangan fibonanci_backup_*.json tidak ditemukan di Download", background = AppColors.neoCoral)
            return@rememberLauncherForActivityResult
        }
        scope.launch {
            val text = withContext(Dispatchers.IO) {
                context.contentResolver.openInputStream(uri)!!.use { it.readBytes().toString(Charsets.UTF_8) }
            }
            vm.importJsonBackup(JSONObject(text))
            host.showSnackBar("Cadangan dipulihkan: ${displayName(context, uri)}", background = AppColors.neoMint)
        }
    }

    val s = state
    if (isGlobal) {
        val activeCatCount = s.categories.count { !it.isDeleted }
        Column {
            SettingsStyle.sectionHeader("PENGATURAN GLOBAL • SEMUA PROFIL")
            Spacer(Modifier.height(6.dp))
            SettingsStyle.switchRow(switchKey = "settings_privacy_switch", title = "Samarkan Nominal Saldo", value = s.isBalanceHidden, onChanged = { vm.toggleBalanceVisibility(it) })
            SettingsStyle.switchRow(switchKey = "settings_refresh_rate_switch", title = "Mode Layar 120Hz (High FPS)", value = s.isHighRefreshRate, onChanged = { vm.setHighRefreshRate(it) })
            SettingsStyle.switchRow(switchKey = "settings_simple_style_switch", title = "Tampilan Sederhana (iblameraihan)", value = s.uiStyle == UiStyle.iblameraihan, onChanged = { vm.setUiStyle(if (it) UiStyle.iblameraihan else UiStyle.david4rr) })
            SettingsStyle.switchRow(switchKey = "settings_biometric_switch", title = "Kunci Biometrik / PIN Aplikasi", value = biometricEnabled, onChanged = { toggleBiometric(it) })
            SettingsStyle.switchRow(switchKey = "settings_privacy_screen_switch", title = "Pelindung Layar Privasi (Recent Apps)", value = privacyScreenEnabled, onChanged = { togglePrivacyScreen(it) })
            SettingsStyle.menuRow(key = "settings_encryption_status_row", title = "Enkripsi Database (SQLCipher)", valueText = "AES-256 Aktif", valueColor = AppColors.neoChartreuse, onTap = {})
            SettingsStyle.menuRow(key = "settings_category_menu_row", title = "Kategori Transaksi", valueText = "$activeCatCount Kategori", onTap = { onNavigate(SettingsSubRoute.categories) })
            SettingsStyle.menuRow(
                key = "settings_notif_permission_row", title = "Listener Notifikasi Bank",
                valueText = if (permissionGranted) "Aktif" else "Mati", valueColor = if (permissionGranted) AppColors.neoMint else null,
                onTap = {
                    context.startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    checkPermission()
                },
            )
            SettingsStyle.menuRow(key = "settings_bank_apps_row", title = "Aplikasi Bank & E-Wallet", valueText = "${kPopularBankAppPresets.size} Didukung", onTap = { onNavigate(SettingsSubRoute.bankApps) })
        }
        return
    }

    val unsyncedCount = s.wallets.count { !it.isSynced } + s.transactions.count { !it.isSynced } +
        s.subscriptions.count { !it.isSynced } + s.pockets.count { !it.isSynced }
    val uUpper = s.profile.username.uppercase()
    Column {
        SettingsStyle.sectionHeader("DATA & CADANGAN • @$uUpper")
        Spacer(Modifier.height(6.dp))
        SettingsStyle.menuRow(
            key = "settings_export_csv_row", title = "Ekspor Transaksi (CSV / Excel)",
            valueText = "${s.transactions.size} Baris", onTap = { onNavigate(SettingsSubRoute.exportData) },
        )
        SettingsStyle.menuRow(
            key = "settings_export_json_row", title = "Simpan Cadangan (JSON)",
            valueText = "File .json", onTap = { exportLauncher.launch("fibonanci_backup_${s.profile.username}.json") },
        )
        SettingsStyle.menuRow(
            key = "settings_import_json_row", title = "Pulihkan Cadangan (Import JSON)",
            valueText = "Pulihkan", valueColor = AppColors.neoMint, onTap = { importLauncher.launch(arrayOf("application/json", "text/plain", "application/octet-stream")) },
        )
        Spacer(Modifier.height(28.dp))
        SettingsStyle.sectionHeader("ZONA BAHAYA • @$uUpper", color = AppColors.neoCoral.copy(alpha = 0.85f))
        Spacer(Modifier.height(6.dp))
        SettingsStyle.menuRow(
            key = "settings_clear_tx_row", title = "Bersihkan Riwayat Transaksi", valueText = "Reset",
            titleColor = AppColors.neoCoral, valueColor = AppColors.neoCoral.copy(alpha = 0.8f),
            onTap = { onNavigate(SettingsSubRoute.clearTransactions) },
        )
        SettingsStyle.menuRow(
            key = "settings_delete_profile_row",
            title = if (s.profiles.size > 1) "Hapus Profil (@${s.profile.username})" else "Reset Profil (@${s.profile.username})",
            valueText = if (s.profiles.size > 1) "Hapus" else "Reset",
            titleColor = AppColors.neoCoral, valueColor = AppColors.neoCoral.copy(alpha = 0.8f),
            onTap = { onNavigate(SettingsSubRoute.deleteProfile) },
        )
        Text(
            "SQLite Drift v6 • $unsyncedCount belum sinkron • 100% On-Device Offline",
            style = SettingsStyle.sub.copy(fontSize = 10.5.sp, color = Color.White.copy(alpha = 0.24f)),
        )
    }
}

private fun isoDate(millis: Long): String = millis.toLocalDate().toString()

private fun amount0(v: Double): String = String.format(Locale.US, "%.0f", v)

@Composable
fun SettingsExportSubPage(state: FinanceState) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var savedPath by rememberSaveable { mutableStateOf<String?>(null) }
    var pendingContent by remember { mutableStateOf("") }

    val saveLauncher = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("*/*")) { uri ->
        if (uri == null) return@rememberLauncherForActivityResult
        val content = pendingContent
        scope.launch {
            writeDocument(context, uri, content)
            savedPath = displayName(context, uri)
        }
    }

    fun export(asExcel: Boolean) {
        val s = state
        val wMap = s.wallets.associate { it.id to it.name }
        val cMap = s.categories.associate { it.id to it.name }
        val u = s.profile.username.lowercase()
        if (!asExcel) {
            val b = StringBuilder("\uFEFFTanggal,Tipe,Rekening,Kategori,Nominal (IDR),Catatan\n")
            for (t in s.transactions) {
                val d = isoDate(t.transactionDate)
                val n = (t.notes ?: "").replace("\"", "\"\"").replace("\n", " ")
                b.append("$d,${t.type},\"${wMap[t.walletId] ?: "-"}\",\"${cMap[t.categoryId] ?: "-"}\",${amount0(t.amount)},\"$n\"\n")
            }
            pendingContent = b.toString()
            saveLauncher.launch("fibonanci_transaksi_$u.csv")
        } else {
            val b = StringBuilder(
                "<?xml version=\"1.0\"?><?mso-application progid=\"Excel.Sheet\"?><Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"><Worksheet ss:Name=\"Transaksi\"><Table>" +
                    "<Row><Cell><Data ss:Type=\"String\">Tanggal</Data></Cell><Cell><Data ss:Type=\"String\">Tipe</Data></Cell><Cell><Data ss:Type=\"String\">Rekening</Data></Cell><Cell><Data ss:Type=\"String\">Kategori</Data></Cell><Cell><Data ss:Type=\"String\">Nominal (IDR)</Data></Cell><Cell><Data ss:Type=\"String\">Catatan</Data></Cell></Row>",
            )
            for (t in s.transactions) {
                val d = isoDate(t.transactionDate)
                val n = (t.notes ?: "").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                b.append("<Row><Cell><Data ss:Type=\"String\">$d</Data></Cell><Cell><Data ss:Type=\"String\">${t.type}</Data></Cell><Cell><Data ss:Type=\"String\">${wMap[t.walletId] ?: "-"}</Data></Cell><Cell><Data ss:Type=\"String\">${cMap[t.categoryId] ?: "-"}</Data></Cell><Cell><Data ss:Type=\"Number\">${amount0(t.amount)}</Data></Cell><Cell><Data ss:Type=\"String\">$n</Data></Cell></Row>")
            }
            b.append("</Table></Worksheet></Workbook>")
            pendingContent = b.toString()
            saveLauncher.launch("fibonanci_transaksi_$u.xls")
        }
    }

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp)) {
        item { SettingsStyle.sectionHeader("PILIH FORMAT FILE LAPORAN") }
        item { Spacer(Modifier.height(6.dp)) }
        item {
            SettingsStyle.optionRow(
                key = "settings_export_csv_file_btn", title = "Simpan File CSV (.csv)",
                subtitle = "Format koma terpisah (UTF-8 BOM), kompatibel semua spreadsheet",
                selected = savedPath?.endsWith(".csv") ?: false, onTap = { export(asExcel = false) },
            )
        }
        item {
            SettingsStyle.optionRow(
                key = "settings_export_excel_file_btn", title = "Simpan File Excel (.xls)",
                subtitle = "Format tabel buku kerja Microsoft Excel / Google Sheets",
                selected = savedPath?.endsWith(".xls") ?: false, onTap = { export(asExcel = true) },
            )
        }
        savedPath?.let { path ->
            item { Spacer(Modifier.height(16.dp)) }
            item { Text("Berhasil disimpan ke:\n$path", style = SettingsStyle.accent, modifier = Modifier.testTag("settings_export_saved_path")) }
        }
    }
}
