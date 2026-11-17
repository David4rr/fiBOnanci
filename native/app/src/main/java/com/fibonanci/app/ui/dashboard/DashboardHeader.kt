package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Inbox
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.inbox.showPendingInboxModal
import com.fibonanci.app.ui.profile.ProfileAvatar
import com.fibonanci.app.ui.profile.showProfileModal
import com.fibonanci.app.ui.shell.FibonanciLogoMark
import com.fibonanci.app.ui.shell.FibonanciSplashGate
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun DashboardHeader(
    profileId: String? = null,
    username: String,
    avatarPath: String? = null,
    walletCount: Int,
    txCount: Int,
) {
    val host = LocalModalHost.current
    val pendingCount by NotificationBridge.pendingCountNotifier.collectAsStateWithLifecycle()
    val isSplashActive = FibonanciSplashGate.isSplashActive.value

    Row(
        Modifier.padding(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f)) {
            Row(
                Modifier.alpha(if (isSplashActive) 0f else 1f),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                FibonanciLogoMark(
                    size = 24.dp,
                    modifier = Modifier.onGloballyPositioned { FibonanciSplashGate.dashboardLogoBounds = it.boundsInWindow() },
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    buildAnnotatedString {
                        append("fi")
                        withStyle(SpanStyle(color = AppColors.neoChartreuse)) { append("BO") }
                        append("nanci")
                    },
                    style = AppTypography.heroGreeting,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier
                        .weight(1f, fill = false)
                        .onGloballyPositioned { FibonanciSplashGate.dashboardTextBounds = it.boundsInWindow() },
                )
            }
            Spacer(Modifier.height(2.dp))
            Text(
                "Hallo $username selamat datang kembali!",
                style = AppTypography.listSubtitle,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.pointerInput(Unit) { detectTapGestures { showPendingInboxModal(host) } }) {
                Box(
                    Modifier
                        .size(42.dp)
                        .background(Color(0xFF1E212D), CircleShape)
                        .border(1.5.dp, AppColors.canvasBorder, CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(Icons.Outlined.Inbox, null, tint = AppColors.textWhite, modifier = Modifier.size(20.dp))
                }
                if (pendingCount > 0) {
                    Box(
                        Modifier
                            .align(Alignment.TopEnd)
                            .size(10.dp)
                            .background(AppColors.neoChartreuse, CircleShape)
                            .border(1.5.dp, AppColors.canvasBg, CircleShape),
                    )
                }
            }
            Spacer(Modifier.width(10.dp))
            Box(Modifier.pointerInput(walletCount, txCount) { detectTapGestures { showProfileModal(host, walletCount = walletCount, txCount = txCount) } }) {
                ProfileAvatar(avatarPath = avatarPath, name = username, size = 42.dp)
            }
        }
    }
}
