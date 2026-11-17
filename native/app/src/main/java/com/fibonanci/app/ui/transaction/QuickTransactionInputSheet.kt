package com.fibonanci.app.ui.transaction

import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.CameraAlt
import androidx.compose.material.icons.rounded.EditNote
import androidx.compose.material.icons.rounded.Mic
import androidx.compose.material.icons.rounded.PhotoCamera
import androidx.compose.material.icons.rounded.PhotoLibrary
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.lerp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewModelScope
import com.fibonanci.app.core.smartinput.SmartInputBridge
import com.fibonanci.app.core.smartinput.SmartInputSource
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.LocalModalProgress
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.shell.AddActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.launch

// morphing input menu: the dock '+' button rotates in-place into '×' while
// 3 pill buttons morph directly upward out of the exact '+' button rect.
fun showQuickTransactionInputSheet(host: ModalHost) {
    AddActionButton.isMenuOpen.value = true
    host.show(ModalKind.Overlay) { dismiss ->
        DisposableEffect(Unit) {
            onDispose { AddActionButton.isMenuOpen.value = false }
        }
        QuickTransactionInputSheet(onDismiss = dismiss)
    }
}

@Composable
fun QuickTransactionInputSheet(onDismiss: () -> Unit) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val haptic = LocalHapticFeedback.current
    val density = LocalDensity.current
    val rawT = LocalModalProgress.current
    var showPhotoSources by remember { mutableStateOf(false) }
    // dart fires mediumImpact as the menu opens
    DisposableEffect(Unit) {
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        onDispose { }
    }

    fun openMode(source: SmartInputSource?) {
        haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
        onDismiss()
        if (source == null) {
            showTransactionModal(host)
            return
        }
        // runs past this overlay's lifetime, like the dart host context
        vm.viewModelScope.launch {
            val state = vm.state.value
            val draft = executeSmartTransactionCapture(host, source = source, wallets = state.wallets, categories = state.categories)
            if (draft == null || !draft.hasMeaningfulData) return@launch
            showTransactionModal(host, initialDraft = draft)
        }
    }

    val navBottom = with(density) { WindowInsets.navigationBars.getBottom(this).toDp() }
    val rotT = EaseOutCubic.transform(rawT)

    BoxWithConstraints(Modifier.fillMaxSize()) {
        val rect = AddActionButton.anchorRect
        val anchorRight: Dp = if (rect != null) with(density) { maxWidth - rect.right.toDp() } else 20.dp
        val anchorBottom: Dp = if (rect != null) with(density) { maxHeight - rect.bottom.toDp() } else 12.dp + navBottom

        // dart barrier (black 58%) + tap-to-close layer
        Box(
            Modifier
                .fillMaxSize()
                .alpha(rawT)
                .background(Color.Black.copy(alpha = 0.58f))
                .clickable(remember { MutableInteractionSource() }, null, onClick = onDismiss),
        )

        @Composable
        fun MorphPill(slotIndex: Int, icon: ImageVector, label: String, accent: Color, onTap: () -> Unit) {
            val start = slotIndex * 0.06f
            val localT = ((rawT - start) / (1f - start)).coerceIn(0f, 1f)
            val morphT = EaseOutCubic.transform(localT)
            val bottom = lerp(anchorBottom, anchorBottom + 68.dp + 56.dp * slotIndex, morphT)
            val width = lerp(56.dp, 176.dp, morphT)
            val height = lerp(56.dp, 48.dp, morphT)
            val bgColor = lerp(AppColors.neoChartreuse, AppColors.canvasCardSurface, (morphT * 1.35f).coerceIn(0f, 1f))
            val borderColor = lerp(AppColors.neoChartreuse, accent.copy(alpha = 0.55f), morphT)
            val textAlpha = ((morphT - 0.25f) / 0.75f).coerceIn(0f, 1f)
            val shape = RoundedCornerShape(24.dp)

            Box(
                Modifier
                    .align(Alignment.BottomEnd)
                    .offset(x = -anchorRight, y = -bottom)
                    .alpha((localT * 3f).coerceIn(0f, 1f))
                    .size(width, height)
                    .shadow(7.dp * morphT, shape, ambientColor = Color.Black.copy(alpha = 0.36f * morphT), spotColor = Color.Black.copy(alpha = 0.36f * morphT))
                    .clip(shape)
                    .background(bgColor)
                    .border(1.2.dp, borderColor, shape)
                    .clickable(remember { MutableInteractionSource() }, null, onClick = onTap),
            ) {
                Row(
                    Modifier
                        .fillMaxHeight()
                        .horizontalScroll(rememberScrollState(), enabled = false)
                        .padding(start = 12.8.dp, end = 16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(icon, null, Modifier.size(20.dp), tint = lerp(AppColors.textDarkPrimary, accent, morphT))
                    Spacer(Modifier.width(11.dp))
                    Text(
                        label,
                        maxLines = 1,
                        softWrap = false,
                        modifier = Modifier.alpha(textAlpha),
                        style = AppTypography.listTitle.copy(fontSize = 13.5.sp, fontWeight = FontWeight.Bold),
                    )
                }
            }
        }

        if (!showPhotoSources) {
            MorphPill(0, Icons.Rounded.EditNote, "Input Manual", AppColors.textWhite) { openMode(null) }
            MorphPill(1, Icons.Rounded.Mic, "Voice", AppColors.neoChartreuse) { openMode(SmartInputSource.voice) }
            MorphPill(2, Icons.Rounded.CameraAlt, "Foto", AppColors.neoCyan) {
                if (SmartInputBridge.testPhotoOcrOverride != null) {
                    openMode(SmartInputSource.camera)
                } else {
                    haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                    showPhotoSources = true
                }
            }
        } else {
            MorphPill(0, Icons.Rounded.PhotoLibrary, "Galeri (Transfer)", AppColors.neoMint) { openMode(SmartInputSource.gallery) }
            MorphPill(1, Icons.Rounded.PhotoCamera, "Kamera (Struk)", AppColors.neoCyan) { openMode(SmartInputSource.camera) }
        }

        Box(
            Modifier
                .align(Alignment.BottomEnd)
                .offset(x = -anchorRight, y = -anchorBottom)
                .size(56.dp)
                .background(AppColors.neoChartreuse, CircleShape)
                .clickable(remember { MutableInteractionSource() }, null, onClick = onDismiss),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                Icons.Rounded.Add,
                null,
                Modifier.size(30.dp).rotate(rotT * 45f),
                tint = AppColors.textDarkPrimary,
            )
        }
    }
}
