package com.fibonanci.app.ui.walletdetail

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterExitState
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

private val easeInOutCubic = CubicBezierEasing(0.65f, 0f, 0.35f, 1f)

// dart ValueListenable<double> headerOpacityListenable → a provider read lazily so only the badge recomposes
@Composable
fun WalletDetailAppBar(
    wallet: WalletEntry,
    headerBalanceOpacity: Float = 0f,
    headerOpacityListenable: (() -> Float)? = null,
    fmt: (Double) -> String,
    onDismiss: (() -> Unit)? = null,
    isEditing: Boolean = false,
    onReturnToDetails: (() -> Unit)? = null,
    customTitle: String? = null,
    customSubtitle: String? = null,
    modifier: Modifier = Modifier,
) {
    val title = customTitle ?: if (isEditing) "Penyesuaian Saldo: ${wallet.name}" else "Detail Rekening"
    val subtitle = customSubtitle ?: if (isEditing) "Ubah saldo awal & preferensi rekening" else "Informasi & Mutasi"
    val onClose: () -> Unit = if (isEditing) {
        onReturnToDetails ?: onDismiss ?: {}
    } else {
        onDismiss ?: {}
    }

    Column(modifier = modifier.fillMaxWidth()) {
        if (!isEditing) {
            Box(modifier = Modifier.fillMaxWidth().padding(top = 8.dp, bottom = 4.dp), contentAlignment = Alignment.Center) {
                ModalGrabHandle()
            }
        } else {
            Spacer(Modifier.height(16.dp))
        }
        Row(
            modifier = Modifier.fillMaxWidth().padding(start = 20.dp, top = 10.dp, end = 20.dp, bottom = 10.dp),
            verticalAlignment = Alignment.Top,
        ) {
            AnimatedContent(
                targetState = title to subtitle,
                transitionSpec = { SmoothPageView.headerTitleTransition(260).using(SizeTransform(clip = false)) },
                contentAlignment = Alignment.TopStart,
                modifier = Modifier.weight(1f),
                label = "wallet_detail_title",
            ) { (t, s) ->
                Column {
                    Text(t, style = AppTypography.modalTitle, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            s,
                            style = AppTypography.modalSubtitle,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f, fill = false),
                        )
                        if (!isEditing) {
                            val opacity = headerOpacityListenable?.invoke() ?: headerBalanceOpacity
                            if (opacity > 0.1f) {
                                Text(
                                    fmt(wallet.balance),
                                    style = TextStyle(
                                        fontFamily = PlusJakartaSans,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.W800,
                                        color = AppColors.neoChartreuse,
                                        fontFeatureSettings = "tnum",
                                    ),
                                    modifier = Modifier
                                        .padding(start = 8.dp)
                                        .alpha(opacity)
                                        .background(AppColors.neoChartreuse.copy(alpha = 0.15f), RoundedCornerShape(6.dp))
                                        .border(0.6.dp, AppColors.neoChartreuse.copy(alpha = 0.35f), RoundedCornerShape(6.dp))
                                        .padding(horizontal = 7.dp, vertical = 2.dp),
                                )
                            }
                        }
                    }
                }
            }
            IconButton(onClick = onClose) {
                AnimatedContent(
                    targetState = isEditing,
                    transitionSpec = {
                        val spec = tween<Float>(320, easing = easeInOutCubic)
                        fadeIn(spec) togetherWith fadeOut(spec)
                    },
                    label = "wallet_detail_close_icon",
                ) { editing ->
                    // entering icon rotates from a quarter turn to rest, like the dart RotationTransition
                    val startTurns = if (editing) -0.25f else 0.25f
                    val progress = transition.animateFloat(
                        transitionSpec = { tween(320, easing = easeInOutCubic) },
                        label = "close_icon_turns",
                    ) { state -> if (state == EnterExitState.Visible) 0f else startTurns }
                    Icon(
                        imageVector = if (editing) Icons.AutoMirrored.Rounded.KeyboardArrowLeft else Icons.Rounded.KeyboardArrowDown,
                        contentDescription = null,
                        tint = AppColors.textWhite,
                        modifier = Modifier
                            .size(28.dp)
                            .graphicsLayer { rotationZ = progress.value * 360f },
                    )
                }
            }
        }
    }
}
