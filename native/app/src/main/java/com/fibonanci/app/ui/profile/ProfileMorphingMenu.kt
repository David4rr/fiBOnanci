package com.fibonanci.app.ui.profile

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupPositionProvider
import androidx.compose.ui.window.PopupProperties
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch

@Composable
fun ProfileMorphingMenu(
    profile: ProfileEntry,
    totalProfiles: Int,
    onEditProfile: (() -> Unit)? = null,
    onNewProfile: (() -> Unit)? = null,
    onHealthDetails: (() -> Unit)? = null,
    onFinancialReport: (() -> Unit)? = null,
    onSettings: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    val clipboard = LocalClipboardManager.current
    val haptics = LocalHapticFeedback.current
    val scope = rememberCoroutineScope()
    // linear controller value; forward 240ms, reverse 180ms
    val anim = remember { Animatable(0f) }
    var isExpanded by remember { mutableStateOf(false) }
    var overlayVisible by remember { mutableStateOf(false) }
    var reversing by remember { mutableStateOf(false) }
    var anchor by remember { mutableStateOf(IntRect.Zero) }

    fun openMenu() {
        isExpanded = true
        overlayVisible = true
        reversing = false
        scope.launch {
            anim.snapTo(0f)
            anim.animateTo(1f, tween(240, easing = LinearEasing))
        }
    }

    fun closeMenu(onComplete: (() -> Unit)? = null) {
        if (!isExpanded) return
        reversing = true
        scope.launch {
            anim.animateTo(0f, tween((180 * anim.value).toInt(), easing = LinearEasing))
            isExpanded = false
            overlayVisible = false
            onComplete?.invoke()
        }
    }

    fun shareProfile() {
        clipboard.setText(AnnotatedString("${profile.fullName} (@${profile.username}) - fiBOnanci"))
        host.showSnackBar("Kartu profil berhasil disalin!")
    }

    val bg by animateColorAsState(
        if (isExpanded) AppColors.neoChartreuse.copy(alpha = 0.15f) else Color.Transparent,
        tween(200, easing = LinearEasing),
        label = "menuBg",
    )
    val borderColor by animateColorAsState(
        if (isExpanded) AppColors.neoChartreuse.copy(alpha = 0.4f) else Color.Transparent,
        tween(200, easing = LinearEasing),
        label = "menuBorder",
    )
    val dotColor by animateColorAsState(
        if (isExpanded) AppColors.neoChartreuse else Color(0xFF8E92A0),
        tween(200, easing = LinearEasing),
        label = "menuDots",
    )

    Box(
        modifier = modifier
            .size(44.dp, 24.dp)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
                if (isExpanded) closeMenu() else openMenu()
            }
            .background(bg, RoundedCornerShape(12.dp))
            .border(1.dp, borderColor, RoundedCornerShape(12.dp)),
        contentAlignment = Alignment.Center,
    ) {
        Row {
            repeat(3) { i ->
                Box(
                    Modifier
                        .padding(start = if (i > 0) 5.5.dp else 0.dp)
                        .size(7.dp)
                        .background(dotColor, CircleShape),
                )
            }
        }

        if (overlayVisible) {
            val provider = remember {
                object : PopupPositionProvider {
                    override fun calculatePosition(
                        anchorBounds: IntRect,
                        windowSize: IntSize,
                        layoutDirection: LayoutDirection,
                        popupContentSize: IntSize,
                    ): IntOffset {
                        anchor = anchorBounds
                        return IntOffset.Zero
                    }
                }
            }
            Popup(
                popupPositionProvider = provider,
                onDismissRequest = { closeMenu() },
                properties = PopupProperties(focusable = true, clippingEnabled = false),
            ) {
                Box(Modifier.fillMaxSize()) {
                    Box(
                        Modifier
                            .fillMaxSize()
                            .background(Color.Black.copy(alpha = 0.35f * anim.value))
                            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { closeMenu() },
                    )
                    ProfileMorphingMenuOverlay(
                        profile = profile,
                        totalProfiles = totalProfiles,
                        onClose = { closeMenu() },
                        onAction = { action -> closeMenu(onComplete = action) },
                        onEditProfile = onEditProfile,
                        onNewProfile = onNewProfile,
                        onHealthDetails = onHealthDetails,
                        onFinancialReport = onFinancialReport,
                        onSettings = onSettings,
                        onShareProfile = { shareProfile() },
                        modifier = Modifier
                            .layout { measurable, constraints ->
                                val placeable = measurable.measure(constraints.copy(minWidth = 0, minHeight = 0))
                                layout(constraints.maxWidth, constraints.maxHeight) {
                                    // follower top-right anchored to the trigger's bottom-right, 6px below
                                    placeable.place(anchor.right - placeable.width, anchor.bottom + 6.dp.roundToPx())
                                }
                            }
                            .graphicsLayer {
                                val progress = anim.value
                                val curved = if (reversing) FlutterCurves.easeInCubic.transform(progress) else FlutterCurves.easeOutBack.transform(progress)
                                val s = 0.84f + 0.16f * curved
                                scaleX = s
                                scaleY = s
                                alpha = (progress / 0.65f).coerceIn(0f, 1f)
                                transformOrigin = TransformOrigin(1f, 0f)
                            },
                    )
                }
            }
        }
    }
}
