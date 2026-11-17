package com.fibonanci.app.ui.profile

import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.offset
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.LocalModalProgress
import androidx.compose.ui.graphics.Color
import com.fibonanci.app.ui.health.FinancialHealthTab
import com.fibonanci.app.ui.report.FinancialReportTab
import com.fibonanci.app.ui.settings.ProfileSettingsTab
import com.fibonanci.app.ui.settings.SettingsSubRoute
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.roundToInt

fun showProfileModal(host: ModalHost, walletCount: Int, txCount: Int) {
    // non-opaque fade route with a black 0.6 barrier
    host.show(ModalKind.Overlay) { dismiss ->
        val progress = LocalModalProgress.current
        Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.6f * progress))) {
            Box(Modifier.fillMaxSize().graphicsLayer { alpha = FlutterCurves.easeOutCubic.transform(progress) }) {
                ProfileModal(walletCount = walletCount, txCount = txCount, onDismiss = dismiss)
            }
        }
    }
}

@Composable
fun ProfileModal(
    walletCount: Int,
    txCount: Int,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val focusManager = LocalFocusManager.current
    val density = LocalDensity.current
    val scope = rememberCoroutineScope()

    var currentTab by remember { mutableIntStateOf(0) }
    var subTab by remember { mutableIntStateOf(4) }
    var editingProfile by remember { mutableStateOf<ProfileEntry?>(null) }
    var settingsRoute by remember { mutableStateOf<SettingsSubRoute?>(null) }
    var dragOffset by remember { mutableFloatStateOf(0f) }
    // smooth page view position: 0 = summary, 1 = sub tab
    val page = remember { Animatable(0f) }

    fun goToTab(tab: Int, target: ProfileEntry? = null) {
        focusManager.clearFocus()
        if (tab != 0) {
            subTab = tab
            editingProfile = target
            settingsRoute = null
        }
        currentTab = tab
        scope.launch { page.animateTo(if (tab == 0) 0f else 1f, tween(340, easing = FlutterCurves.smoothPage)) }
    }

    fun goToSummary() = goToTab(0)

    fun handleBack() {
        if (currentTab == 4 && settingsRoute != null) {
            settingsRoute = null
        } else if (currentTab != 0) {
            goToSummary()
        } else {
            onDismiss()
        }
    }

    BackHandler(enabled = currentTab != 0) { handleBack() }

    val headerTitle = when (currentTab) {
        1 -> if (editingProfile != null) "Edit Profil" else "Tambah Profil Baru"
        2 -> "Audit Kesehatan Finansial"
        3 -> "Laporan Keuangan"
        4 -> settingsRoute?.title ?: "Pengaturan"
        else -> "Profil Pengguna"
    }
    val headerSubtitle = when (currentTab) {
        1 -> if (editingProfile != null) "Perbarui informasi dan identitas profil" else "Tambah akun profil baru di perangkat"
        2 -> "Berdasarkan rasio arus kas, aset, & tagihan riil"
        3 -> "Analisis arus kas, kategori, & distribusi rekening"
        4 -> settingsRoute?.subtitle ?: "Preferensi finansial, kategori, otomasi, & data lokal"
        else -> "Ringkasan identitas & performa finansial"
    }

    val profile = state.profile
    val profiles = state.profiles.ifEmpty { listOf(profile) }
    val dragState = rememberDraggableState { delta ->
        if (currentTab == 0 && (delta > 0 || dragOffset > 0)) dragOffset = max(0f, dragOffset + delta)
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(AppColors.canvasBg)
            .windowInsetsPadding(WindowInsets.safeDrawing),
    ) {
        Column(Modifier.fillMaxSize().offset { IntOffset(0, dragOffset.roundToInt()) }) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .draggable(
                        state = dragState,
                        orientation = Orientation.Vertical,
                        onDragStopped = { velocity ->
                            if (currentTab == 0) {
                                val threshold = with(density) { 60.dp.toPx() }
                                val minVelocity = with(density) { 180.dp.toPx() }
                                if (velocity > minVelocity || dragOffset > threshold) onDismiss() else dragOffset = 0f
                            }
                        },
                    ),
            ) {
                if (currentTab == 0) {
                    ModalGrabHandle(padding = PaddingValues(top = 8.dp, bottom = 4.dp))
                } else {
                    Spacer(Modifier.height(16.dp))
                }
                Box(Modifier.padding(start = 24.dp, top = 8.dp, end = 24.dp, bottom = 8.dp)) {
                    ModalHeader(
                        title = headerTitle,
                        subtitle = headerSubtitle,
                        padding = PaddingValues(0.dp),
                        closeIcon = if (currentTab == 0) Icons.Rounded.KeyboardArrowDown else Icons.AutoMirrored.Rounded.KeyboardArrowLeft,
                        onClose = { handleBack() },
                    )
                }
            }
            BoxWithConstraints(Modifier.weight(1f).fillMaxWidth()) {
                val widthPx = constraints.maxWidth.toFloat()
                // smooth page view: slide + cross-fade + depth scale per page
                for (index in 0..1) {
                    Box(
                        Modifier
                            .fillMaxSize()
                            .graphicsLayer {
                                val delta = abs(page.value - index).coerceIn(0f, 1f)
                                translationX = (index - page.value) * widthPx
                                if (delta > 0.001f) {
                                    alpha = (1f - delta * 0.5f).coerceIn(0f, 1f)
                                    val scale = 1f - delta * 0.04f
                                    scaleX = scale
                                    scaleY = scale
                                }
                            },
                    ) {
                        if (index == 0) {
                            LazyColumn(
                                modifier = Modifier.fillMaxSize(),
                                contentPadding = PaddingValues(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 36.dp),
                            ) {
                                item {
                                    ProfileCardCarousel(
                                        profiles = profiles,
                                        currentProfileId = profile.id,
                                        walletCount = state.wallets.size,
                                        txCount = state.transactions.size,
                                        onEditProfile = { goToTab(1, profile) },
                                        onNewProfile = { goToTab(1) },
                                        onHealthDetails = { goToTab(2) },
                                        onFinancialReport = { goToTab(3) },
                                        onSettings = { goToTab(4) },
                                    )
                                    Spacer(Modifier.height(16.dp))
                                    ProfileGeneralDataCard(
                                        profile = profile,
                                        walletCount = state.wallets.size,
                                        txCount = state.transactions.size,
                                    )
                                }
                            }
                        } else {
                            when (subTab) {
                                1 -> key(editingProfile?.id ?: "new_profile") {
                                    ProfileEditTab(initialProfile = editingProfile, onSaved = { goToSummary() })
                                }
                                2 -> FinancialHealthTab(report = state.healthReport)
                                3 -> FinancialReportTab(state = state)
                                else -> ProfileSettingsTab(
                                    state = state,
                                    activeRoute = settingsRoute,
                                    onNavigate = { settingsRoute = it },
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
