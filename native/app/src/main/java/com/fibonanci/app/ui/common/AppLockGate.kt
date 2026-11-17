package com.fibonanci.app.ui.common

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Fingerprint
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.fibonanci.app.core.security.SecurityVault
import com.fibonanci.app.ui.dashboard.FolderTabBorderPainter
import com.fibonanci.app.ui.dashboard.FolderTabClipper
import com.fibonanci.app.ui.shell.FibonanciLogoMark
import com.fibonanci.app.ui.shell.FibonanciSplashGate
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.flow.first

private const val UNLOCK_REASON = "Verifikasi sidik jari atau PIN untuk membuka brankas fiBOnanci"

// re-lock only after the app stayed in the background this long
private const val RELOCK_AFTER_MILLIS = 15_000L

private tailrec fun Context.findActivity(): Activity? = when (this) {
    is Activity -> this
    is ContextWrapper -> baseContext.findActivity()
    else -> null
}

@Composable
fun AppLockGate(content: @Composable () -> Unit) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current

    var isLocked by remember { mutableStateOf(false) }
    var isAuthenticating by remember { mutableStateOf(false) }
    val lastPausedAt = remember { longArrayOf(0L) } // 0 = not paused

    fun unlock() {
        if (isAuthenticating) return
        val activity = context.findActivity() ?: return
        isAuthenticating = true
        SecurityVault.authenticate(activity, UNLOCK_REASON) { ok ->
            isAuthenticating = false
            if (ok) isLocked = false
        }
    }

    fun checkLockOnResume() {
        if (SecurityVault.isBiometricLockEnabled(context) && !isLocked) {
            isLocked = true
            unlock()
        }
    }

    // initial lock: wait for the splash to finish before prompting
    LaunchedEffect(Unit) {
        if (SecurityVault.isBiometricLockEnabled(context)) {
            isLocked = true
            if (FibonanciSplashGate.isSplashActive.value) {
                snapshotFlow { FibonanciSplashGate.isSplashActive.value }.first { !it }
                if (isLocked) unlock()
            } else {
                unlock()
            }
        }
    }

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_STOP -> lastPausedAt[0] = System.currentTimeMillis()
                Lifecycle.Event.ON_RESUME -> {
                    val pausedAt = lastPausedAt[0]
                    lastPausedAt[0] = 0L
                    if (pausedAt != 0L &&
                        System.currentTimeMillis() - pausedAt >= RELOCK_AFTER_MILLIS &&
                        !isAuthenticating
                    ) {
                        checkLockOnResume()
                    }
                }
                else -> Unit
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    Box(Modifier.fillMaxSize()) {
        content()
        if (isLocked) {
            LockOverlay(isAuthenticating = isAuthenticating, onUnlock = { unlock() })
        }
    }
}

@Composable
private fun LockOverlay(isAuthenticating: Boolean, onUnlock: () -> Unit) {
    val clipper = remember { FolderTabClipper() }
    val borderPainter = remember {
        FolderTabBorderPainter(clipper = clipper, borderColor = Color(0xFF262936), borderWidth = 1.1f)
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(AppColors.canvasBg)
            // opaque material: nothing below receives touches
            .pointerInput(Unit) { detectTapGestures { } }
            .windowInsetsPadding(WindowInsets.safeDrawing)
            .padding(horizontal = 28.dp),
    ) {
        Column(
            Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .drawWithContent {
                        drawContent()
                        with(borderPainter) { paint() }
                    }
                    .clip(clipper)
                    .background(AppColors.carbonBlack)
                    .padding(start = 22.dp, top = 18.dp, end = 22.dp, bottom = 24.dp),
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier
                            .size(6.dp)
                            .background(AppColors.neoChartreuse, CircleShape),
                    )
                    Spacer(Modifier.width(7.dp))
                    Text(
                        "TERKUNCI • AES-256 VAULT",
                        style = TextStyle(
                            fontFamily = PlusJakartaSans,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.W800,
                            color = AppColors.neoChartreuse,
                            letterSpacing = 0.9.sp,
                        ),
                    )
                }
                Spacer(Modifier.height(20.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    FibonanciLogoMark(size = 34.dp)
                    Spacer(Modifier.width(12.dp))
                    Text(
                        "Brankas Terkunci",
                        style = TextStyle(
                            fontFamily = PlusJakartaSans,
                            fontSize = 22.sp,
                            fontWeight = FontWeight.W800,
                            color = AppColors.textWhite,
                            letterSpacing = (-0.6).sp,
                        ),
                    )
                }
                Spacer(Modifier.height(8.dp))
                Text(
                    "Data keuangan dienkripsi di perangkat. Gunakan sidik jari, wajah, atau PIN untuk membuka.",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 13.sp,
                        color = AppColors.textMuted,
                        lineHeight = 1.45.em,
                    ),
                )
                Spacer(Modifier.height(24.dp))
                PrimaryActionButton(
                    text = "Buka Kunci Aplikasi",
                    icon = Icons.Rounded.Fingerprint,
                    isLoading = isAuthenticating,
                    onPressed = onUnlock,
                )
            }
        }
    }
}
