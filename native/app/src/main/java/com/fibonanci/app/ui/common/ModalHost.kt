package com.fibonanci.app.ui.common

import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Easing
import androidx.compose.animation.core.FastOutLinearInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.ProvidableCompositionLocal
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.delay

// Overlay: no host scrim/transform, the content draws its own barrier and morph from LocalModalProgress
enum class ModalKind { Sheet, Dialog, FullScreen, Overlay }

/**
 * imperative modal / route stack replacing showModalBottomSheet, showDialog,
 * Navigator.push and ScaffoldMessenger. drawn by [ModalHostLayer].
 */
class ModalHost {
    internal class Entry(
        val kind: ModalKind,
        val dismissOnScrim: Boolean,
        val content: @Composable (dismiss: () -> Unit) -> Unit,
    ) {
        val progress = Animatable(0f)
        var closing by mutableStateOf(false)
        val dismiss: () -> Unit = { closing = true }
    }

    internal class SnackBarEntry(
        val message: String,
        val background: Color,
        val contentColor: Color,
        val icon: ImageVector?,
    )

    internal val entries = mutableStateListOf<Entry>()
    internal var snackBar by mutableStateOf<SnackBarEntry?>(null)

    // content gets a dismiss lambda (== Navigator.pop). rendered above the shell, inside all composition locals.
    fun show(
        kind: ModalKind = ModalKind.Sheet,
        dismissOnScrim: Boolean = true,
        content: @Composable (dismiss: () -> Unit) -> Unit,
    ) {
        entries.add(Entry(kind, dismissOnScrim, content))
    }

    fun showSnackBar(
        message: String,
        background: Color = AppColors.canvasCardSurface,
        contentColor: Color = AppColors.textWhite,
        icon: ImageVector? = null,
    ) {
        snackBar = SnackBarEntry(message, background, contentColor, icon)
    }
}

val LocalModalHost: ProvidableCompositionLocal<ModalHost> =
    staticCompositionLocalOf { error("ModalHost not provided") }

// dismiss lambda of the modal entry that is currently composing (null outside a modal)
val LocalModalDismiss: ProvidableCompositionLocal<(() -> Unit)?> = compositionLocalOf { null }

// route animation value (0 = hidden, 1 = shown) of the modal entry that is currently composing
val LocalModalProgress: ProvidableCompositionLocal<Float> = compositionLocalOf { 1f }

// flutter Curves.decelerate
private val decelerate = Easing { t -> 1f - (1f - t) * (1f - t) }

private const val SCRIM_ALPHA = 0.6f
private const val SNACK_BAR_MILLIS = 3000L

// floating dock: 56 tall + 12 bottom padding, snackbar keeps a 10 gap above it
private val snackBarBottomGap = 78.dp

@Composable
fun ModalHostLayer(host: ModalHost) {
    val top = host.entries.lastOrNull { !it.closing }
    BackHandler(enabled = top != null) { top?.dismiss() }

    Box(Modifier.fillMaxSize()) {
        host.entries.forEach { entry ->
            key(entry) { ModalEntryLayer(host, entry) }
        }
        host.snackBar?.let { data ->
            key(data) { SnackBarLayer(host, data) }
        }
    }
}

@Composable
private fun ModalEntryLayer(host: ModalHost, entry: ModalHost.Entry) {
    val focusManager = LocalFocusManager.current
    LaunchedEffect(entry, entry.closing) {
        if (!entry.closing) {
            val enter = when (entry.kind) {
                ModalKind.Dialog -> tween<Float>(150, easing = LinearOutSlowInEasing)
                ModalKind.Overlay -> tween<Float>(280, easing = LinearEasing)
                else -> tween<Float>(300, easing = decelerate)
            }
            entry.progress.animateTo(1f, enter)
        } else {
            focusManager.clearFocus()
            val exit = when (entry.kind) {
                ModalKind.Dialog -> tween<Float>(150, easing = FastOutLinearInEasing)
                ModalKind.Overlay -> tween<Float>(280, easing = LinearEasing)
                else -> tween<Float>(250, easing = FastOutLinearInEasing)
            }
            entry.progress.animateTo(0f, exit)
            host.entries.remove(entry)
        }
    }

    val body: @Composable () -> Unit = {
        CompositionLocalProvider(
            LocalModalDismiss provides entry.dismiss,
            LocalModalProgress provides entry.progress.value,
        ) {
            entry.content(entry.dismiss)
        }
    }

    Box(Modifier.fillMaxSize()) {
        if (entry.kind != ModalKind.FullScreen && entry.kind != ModalKind.Overlay) {
            Box(
                Modifier
                    .fillMaxSize()
                    .graphicsLayer { alpha = entry.progress.value }
                    .background(Color.Black.copy(alpha = SCRIM_ALPHA))
                    .pointerInput(entry) {
                        detectTapGestures { if (entry.dismissOnScrim) entry.dismiss() }
                    },
            )
        }
        when (entry.kind) {
            ModalKind.Sheet -> Box(
                Modifier.fillMaxSize().imePadding(),
                contentAlignment = Alignment.BottomCenter,
            ) {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .graphicsLayer { translationY = size.height * (1f - entry.progress.value) },
                ) { body() }
            }

            ModalKind.Dialog -> Box(
                Modifier
                    .fillMaxSize()
                    .imePadding()
                    // flutter Dialog insetPadding
                    .padding(horizontal = 40.dp, vertical = 24.dp),
                contentAlignment = Alignment.Center,
            ) {
                Box(
                    Modifier.graphicsLayer {
                        val p = entry.progress.value
                        alpha = p
                        scaleX = 0.9f + 0.1f * p
                        scaleY = 0.9f + 0.1f * p
                    },
                ) { body() }
            }

            ModalKind.FullScreen -> Box(
                Modifier
                    .fillMaxSize()
                    .graphicsLayer { translationY = size.height * (1f - entry.progress.value) }
                    // opaque route: swallow taps so nothing below reacts
                    .pointerInput(entry) { detectTapGestures { } },
            ) { body() }

            ModalKind.Overlay -> Box(Modifier.fillMaxSize()) { body() }
        }
    }
}

@Composable
private fun SnackBarLayer(host: ModalHost, data: ModalHost.SnackBarEntry) {
    val alpha = remember(data) { Animatable(0f) }
    LaunchedEffect(data) {
        alpha.animateTo(1f, tween(250, easing = LinearOutSlowInEasing))
        delay(SNACK_BAR_MILLIS)
        alpha.animateTo(0f, tween(250, easing = FastOutLinearInEasing))
        if (host.snackBar === data) host.snackBar = null
    }

    val shape = RoundedCornerShape(16.dp)
    Box(
        Modifier
            .fillMaxSize()
            .windowInsetsPadding(WindowInsets.navigationBars)
            .padding(start = 15.dp, end = 15.dp, bottom = snackBarBottomGap),
        contentAlignment = Alignment.BottomCenter,
    ) {
        Row(
            Modifier
                .fillMaxWidth()
                .graphicsLayer { this.alpha = alpha.value }
                .shadow(6.dp, shape)
                .background(data.background, shape)
                .padding(horizontal = 16.dp, vertical = 14.dp),
            horizontalArrangement = Arrangement.Start,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            data.icon?.let {
                Icon(it, contentDescription = null, tint = data.contentColor, modifier = Modifier.size(24.dp))
                Spacer(Modifier.width(12.dp))
            }
            Text(
                text = data.message,
                modifier = Modifier.weight(1f),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.W600,
                    color = data.contentColor,
                ),
            )
        }
    }
}
