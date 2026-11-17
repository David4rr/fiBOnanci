package com.fibonanci.app.ui.walletdetail

import android.view.HapticFeedbackConstants
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import com.fibonanci.app.ui.wallet.WalletCard
import com.fibonanci.app.ui.wallet.WalletCardDeck
import kotlinx.coroutines.delay

private val easeOutCubic = CubicBezierEasing(0.33f, 1f, 0.68f, 1f)

@Composable
fun PressableScale(
    onTap: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val view = LocalView.current
    var isPressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.97f else 1f,
        animationSpec = tween(140, easing = easeOutCubic),
        label = "pressable_scale",
    )
    Box(
        modifier = modifier
            .pointerInput(onTap) {
                detectTapGestures(
                    onPress = {
                        if (onTap != null) {
                            isPressed = true
                            view.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
                        }
                        tryAwaitRelease()
                        if (onTap != null) isPressed = false
                    },
                    onTap = { onTap?.invoke() },
                )
            }
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            },
    ) {
        content()
    }
}

@Composable
fun TactileHeroCard(
    wallet: WalletEntry,
    cardIndex: Int,
    fmt: (Double) -> String,
    cardColor: Color,
    allWallets: List<WalletEntry>? = null,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    val view = LocalView.current
    val clipboard = LocalClipboardManager.current
    var isCopied by remember { mutableStateOf(false) }
    // bumped on every tap so the reset timer restarts like the dart timer cancel
    var copyTick by remember { mutableIntStateOf(0) }

    LaunchedEffect(copyTick) {
        if (copyTick == 0) return@LaunchedEffect
        delay(1400)
        isCopied = false
    }

    BoxWithConstraints(modifier = modifier) {
        val cardW = maxWidth
        val cardH = cardW * WalletCardDeck.atmRatio

        Box(
            modifier = Modifier
                .size(cardW, cardH)
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                    view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                    isCopied = true
                    val accNum = wallet.accountNumber?.trim()
                    val textToCopy = if (!accNum.isNullOrEmpty()) accNum else wallet.name
                    clipboard.setText(AnnotatedString(textToCopy))
                    host.showSnackBar(
                        message = if (!accNum.isNullOrEmpty()) "Nomor rekening $accNum disalin" else "Nama rekening ${wallet.name} disalin",
                        background = AppColors.canvasCardSurface,
                        contentColor = AppColors.textWhite,
                        icon = Icons.Rounded.CheckCircle,
                    )
                    copyTick++
                },
        ) {
            // the dart backdrop blur is emulated by blurring the card itself while the copied overlay is shown
            Box(modifier = Modifier.fillMaxSize().then(if (isCopied) Modifier.blur(4.dp) else Modifier)) {
                WalletCard(
                    wallet = wallet,
                    index = cardIndex,
                    fmt = fmt,
                    cardH = cardH,
                    isLifted = true,
                    showBottomLayout = true,
                    animate = false,
                    allWallets = allWallets,
                )
            }
            if (isCopied) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(26.dp))
                        .background(Color.Black.copy(alpha = 0.35f)),
                    contentAlignment = Alignment.Center,
                ) {
                    Row(
                        modifier = Modifier
                            .background(AppColors.canvasBg.copy(alpha = 0.92f), RoundedCornerShape(12.dp))
                            .border(1.dp, cardColor.copy(alpha = 0.5f), RoundedCornerShape(12.dp))
                            .padding(horizontal = 14.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Icon(Icons.Rounded.CheckCircle, contentDescription = null, tint = cardColor, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(8.dp))
                        Text(
                            "Disalin",
                            style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textWhite, fontSize = 12.sp, fontWeight = FontWeight.W700),
                        )
                    }
                }
            }
        }
    }
}
