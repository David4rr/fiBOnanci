package com.fibonanci.app.ui.profile

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawOutline
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.dashboard.FolderTabClipper
import com.fibonanci.app.ui.theme.AppColors
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale
import kotlin.math.roundToLong

private val burnFormat = DecimalFormat("#,###", DecimalFormatSymbols(Locale.forLanguageTag("id-ID")))

@Composable
fun ProfileHeaderCard(
    profile: ProfileEntry,
    totalProfiles: Int,
    walletCount: Int? = null,
    txCount: Int? = null,
    onEditProfile: (() -> Unit)? = null,
    onNewProfile: (() -> Unit)? = null,
    onHealthDetails: (() -> Unit)? = null,
    onFinancialReport: (() -> Unit)? = null,
    onSettings: (() -> Unit)? = null,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    val isActive = profile.id == state.profile.id
    val metrics = state.metrics
    val healthScore = state.healthReport.overallScore
    val wallets = walletCount ?: state.wallets.size
    val txs = txCount ?: state.transactions.size
    val subs = state.subscriptions.size
    val sym = if (state.profile.currency == "IDR") "" else AppCurrency.symbolFor(state.profile.currency)
    val convertedBurn = AppCurrency.fromBaseIdr(metrics.safeToSpendDaily, state.profile.currency)
    val burnFormatted = "$sym${burnFormat.format(convertedBurn.roundToLong())}"

    val clipper = remember { FolderTabClipper(tabWidthFactor = 0.58f, cornerRadius = 24f, stepDepth = 18f) }
    BoxWithConstraints(Modifier.fillMaxWidth()) {
        val w = maxWidth
        val tabW = w * 0.58f
        val dotCenterX = (tabW + 24.dp) + ((w - 24.dp) - (tabW + 24.dp)) * 0.44f
        val rightOffset = (w - dotCenterX - 22.dp).coerceIn(16.dp, w)
        Box(Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier
                    .padding(top = 14.dp)
                    .fillMaxWidth()
                    .drawWithContent {
                        drawContent()
                        // folder tab border painted in the foreground
                        drawOutline(
                            clipper.createOutline(size, layoutDirection, this),
                            color = Color(0xFF2E3244),
                            style = Stroke(width = 1.2.dp.toPx()),
                        )
                    }
                    .clip(clipper)
                    .background(AppColors.carbonBlack)
                    .padding(start = 16.dp, top = 24.dp, end = 16.dp, bottom = 16.dp),
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier.clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                            (onEditProfile ?: { showEditProfileModal(host, profile = profile) })()
                        },
                    ) {
                        ProfileAvatar(
                            avatarPath = profile.avatarPath,
                            name = profile.username,
                            size = 58.dp,
                            iconSize = 28.dp,
                            border = BorderStroke(1.5.dp, Color.White.copy(alpha = 0.22f)),
                        )
                    }
                    Spacer(Modifier.width(14.dp))
                    Column(Modifier.weight(1f), verticalArrangement = Arrangement.Center) {
                        Text(
                            profile.fullName,
                            style = jakarta(16.sp, FontWeight.Bold, Color.White, letterSpacing = (-0.4).sp),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                        Spacer(Modifier.height(1.dp))
                        Text(
                            if (!profile.email.isNullOrEmpty()) profile.email else "—",
                            style = jakarta(12.sp, FontWeight.Medium, Color.White.copy(alpha = 0.75f)),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                        Spacer(Modifier.height(1.dp))
                        Text(
                            "@${profile.username}",
                            style = jakarta(12.sp, FontWeight.Medium, AppColors.textMuted),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
                AnimatedContent(
                    targetState = isActive,
                    transitionSpec = {
                        fadeIn(tween(250, easing = FlutterCurves.easeOutCubic)) togetherWith
                            fadeOut(tween(250, easing = FlutterCurves.easeInCubic)) using
                            SizeTransform(clip = false) { _, _ -> snap() }
                    },
                    contentAlignment = Alignment.TopStart,
                    label = "profileCardBody",
                ) { active ->
                    if (active) {
                        ProfileActiveCardBody(
                            metrics = metrics,
                            healthReport = state.healthReport,
                            wallets = wallets,
                            txs = txs,
                            subs = subs,
                            burnFormatted = burnFormatted,
                            healthScore = healthScore,
                            onHealthDetails = onHealthDetails,
                        )
                    } else {
                        ProfileInactiveCardBody(
                            profile = profile,
                            onActivate = { vm.setActiveProfile(profile.id) },
                        )
                    }
                }
            }
            ProfileMorphingMenu(
                profile = profile,
                totalProfiles = totalProfiles,
                onEditProfile = onEditProfile,
                onNewProfile = onNewProfile,
                onHealthDetails = onHealthDetails,
                onFinancialReport = onFinancialReport,
                onSettings = onSettings,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = 5.dp, end = rightOffset),
            )
        }
    }
}
