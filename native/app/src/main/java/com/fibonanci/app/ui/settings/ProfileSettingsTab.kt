package com.fibonanci.app.ui.settings

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.notification.kPopularBankAppPresets
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch
import kotlin.math.abs

enum class SettingsSubRoute(val title: String, val subtitle: String) {
    currency("Mata Uang Utama", "Pilih mata uang tampilan & atur kurs patokan IDR"),
    incomeTarget("Target Pemasukan Bulanan", "Patokan rasio tagihan & tabungan di Audit Kesehatan"),
    cycleDay("Tanggal Mulai Siklus", "Tanggal awal perhitungan siklus anggaran bulanan"),
    stsWallets("Rekening Safe-to-Spend", "Pilih rekening yang dihitung dalam dana aman harian"),
    categories("Kategori Transaksi", "Kelola daftar kategori pengeluaran & pemasukan"),
    bankApps("Aplikasi Bank & E-Wallet", "Daftar aplikasi finansial yang didukung parser otomatis"),
    exportData("Ekspor Data Transaksi", "Simpan laporan transaksi ke file CSV atau Excel (.xls)"),
    clearTransactions("Bersihkan Riwayat Transaksi", "Hapus seluruh mutasi & reset saldo profil aktif"),
    deleteProfile("Hapus Profil", "Hapus atau reset akun profil aktif dari perangkat"),
}

// smooth page view timing (smooth_page_view.dart)
private val pageEasing = CubicBezierEasing(0.22f, 1.0f, 0.36f, 1.0f)
private const val PAGE_DURATION_MS = 340

@Composable
fun ProfileSettingsTab(
    state: FinanceState,
    activeRoute: SettingsSubRoute? = null,
    onNavigate: ((SettingsSubRoute?) -> Unit)? = null,
) {
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    var localRoute by remember { mutableStateOf<SettingsSubRoute?>(null) }
    val route = if (onNavigate != null) activeRoute else localRoute
    var displayedSubRoute by remember { mutableStateOf(route) }
    val page = remember { Animatable(if (route != null) 1f else 0f) }

    // controlled mode: follow the parent's route like didUpdateWidget
    LaunchedEffect(route) {
        if (route != null) displayedSubRoute = route
    }
    LaunchedEffect(route != null) {
        val target = if (route != null) 1f else 0f
        if (page.value != target) {
            focusManager.clearFocus()
            page.animateTo(target, tween(PAGE_DURATION_MS, easing = pageEasing))
        }
    }

    fun navigate(r: SettingsSubRoute?) {
        focusManager.clearFocus()
        if (r != null) displayedSubRoute = r
        if (onNavigate != null) {
            onNavigate(r)
        } else {
            localRoute = r
            scope.launch { page.animateTo(if (r != null) 1f else 0f, tween(PAGE_DURATION_MS, easing = pageEasing)) }
        }
    }

    val subRoute = route ?: displayedSubRoute

    BoxWithConstraints(Modifier.fillMaxSize().clipToBounds()) {
        val widthPx = constraints.maxWidth.toFloat()
        for (index in 0..1) {
            val delta = abs(page.value - index).coerceIn(0f, 1f)
            if (delta >= 1f) continue
            Box(
                Modifier
                    .fillMaxSize()
                    .graphicsLayer {
                        translationX = (index - page.value) * widthPx
                        if (delta > 0.001f) {
                            alpha = (1f - delta * 0.5f).coerceIn(0f, 1f)
                            val s = 1f - delta * 0.04f
                            scaleX = s
                            scaleY = s
                        }
                    },
            ) {
                if (index == 0) {
                    LazyColumn(
                        Modifier.fillMaxSize().testTag("settings_root"),
                        contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp),
                    ) {
                        item { SettingsAutomationDataSection(state = state, onNavigate = { navigate(it) }, isGlobal = true) }
                        item { Spacer(Modifier.height(28.dp)) }
                        item { SettingsFinancialSection(state = state, onNavigate = { navigate(it) }) }
                        item { SettingsBudgetCycleSection(state = state, onNavigate = { navigate(it) }) }
                        item { Spacer(Modifier.height(28.dp)) }
                        item { SettingsAutomationDataSection(state = state, onNavigate = { navigate(it) }, isGlobal = false) }
                    }
                } else {
                    when (subRoute) {
                        SettingsSubRoute.currency -> SettingsCurrencySubPage(state = state)
                        SettingsSubRoute.incomeTarget -> SettingsIncomeTargetSubPage(state = state, onSaved = { navigate(null) })
                        SettingsSubRoute.cycleDay -> SettingsCycleDaySubPage(state = state)
                        SettingsSubRoute.stsWallets -> SettingsStsWalletsSubPage(state = state)
                        SettingsSubRoute.categories -> SettingsCategorySection(categories = state.categories)
                        SettingsSubRoute.bankApps -> SettingsBankAppsSubPage()
                        SettingsSubRoute.exportData -> SettingsExportSubPage(state = state)
                        SettingsSubRoute.clearTransactions -> SettingsClearTxSubPage(state = state, onCleared = { navigate(null) })
                        SettingsSubRoute.deleteProfile -> SettingsDeleteProfileSubPage(state = state, onDeleted = { navigate(null) })
                        null -> Unit
                    }
                }
            }
        }
    }
}

@Composable
fun SettingsDeleteProfileSubPage(state: FinanceState, onDeleted: () -> Unit) {
    val vm = LocalFinance.current
    val isMulti = state.profiles.size > 1
    val u = state.profile.username
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 48.dp)) {
        item {
            Text(
                if (isMulti) "Profil @$u beserta seluruh rekening, transaksi, kantong dana, dan langganannya akan dihapus dari perangkat. Anda akan beralih ke profil lain yang tersimpan."
                else "Profil @$u adalah satu-satunya profil. Menghapus profil ini akan meresetnya kembali ke pengaturan default.",
                style = SettingsStyle.title,
            )
        }
        item { Spacer(Modifier.height(20.dp)) }
        item {
            Text(
                if (isMulti) "Ya, Hapus Profil @$u" else "Ya, Reset Profil @$u",
                style = SettingsStyle.accent.copy(color = AppColors.neoCoral),
                modifier = Modifier.testTag("settings_confirm_delete_profile_button").plainClickable {
                    vm.deleteProfile(state.profile.id)
                    onDeleted()
                },
            )
        }
    }
}

@Composable
fun SettingsBankAppsSubPage() {
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 8.dp, end = 24.dp, bottom = 48.dp)) {
        items(kPopularBankAppPresets.size) { i ->
            Row(Modifier.fillMaxWidth().padding(vertical = 12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(kPopularBankAppPresets[i].name, style = SettingsStyle.title)
                Text(kPopularBankAppPresets[i].packageName, style = SettingsStyle.sub)
            }
        }
    }
}

@Composable
fun SettingsClearTxSubPage(state: FinanceState, onCleared: () -> Unit) {
    val vm = LocalFinance.current
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 48.dp)) {
        item {
            Text(
                "Semua riwayat transaksi pada profil @${state.profile.username} akan dihapus dan saldo rekening dikembalikan ke 0.",
                style = SettingsStyle.title,
            )
        }
        item { Spacer(Modifier.height(20.dp)) }
        item {
            Text(
                "Ya, Bersihkan Semua Transaksi",
                style = SettingsStyle.accent.copy(color = AppColors.neoCoral),
                modifier = Modifier.testTag("settings_confirm_clear_tx_button").plainClickable {
                    vm.clearProfileTransactions(state.profile.id)
                    onCleared()
                },
            )
        }
    }
}
