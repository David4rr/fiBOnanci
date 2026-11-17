package com.fibonanci.app.ui.profile

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.snapping.SnapPosition
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsDraggedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch
import kotlin.math.abs

@Composable
fun ProfileCardCarousel(
    profiles: List<ProfileEntry>,
    currentProfileId: String,
    walletCount: Int? = null,
    txCount: Int? = null,
    onEditProfile: (() -> Unit)? = null,
    onNewProfile: (() -> Unit)? = null,
    onHealthDetails: (() -> Unit)? = null,
    onFinancialReport: (() -> Unit)? = null,
    onSettings: (() -> Unit)? = null,
) {
    if (profiles.isEmpty()) return

    @Composable
    fun Card(p: ProfileEntry) {
        ProfileHeaderCard(
            profile = p,
            totalProfiles = profiles.size,
            walletCount = walletCount,
            txCount = txCount,
            onEditProfile = onEditProfile,
            onNewProfile = onNewProfile,
            onHealthDetails = onHealthDetails,
            onFinancialReport = onFinancialReport,
            onSettings = onSettings,
        )
    }

    if (profiles.size == 1) {
        Card(profiles.first())
        return
    }

    val vm = LocalFinance.current
    val scope = rememberCoroutineScope()
    val initialIdx = remember { profiles.indexOfFirst { it.id == currentProfileId }.let { if (it >= 0) it else 0 } }
    val pagerState = rememberPagerState(initialPage = initialIdx) { profiles.size }
    var currentPage by remember { mutableIntStateOf(initialIdx) }
    val isDragged by pagerState.interactionSource.collectIsDraggedAsState()
    var isUserScrolling by remember { mutableStateOf(false) }
    val latestProfiles by rememberUpdatedState(profiles)
    val latestCurrentId by rememberUpdatedState(currentProfileId)
    val pageSpec = tween<Float>(320, easing = FlutterCurves.smoothPage)

    fun syncActiveProfile(index: Int) {
        if (index >= 0 && index < latestProfiles.size) {
            val target = latestProfiles[index]
            if (target.id != latestCurrentId) vm.setActiveProfile(target.id)
        }
    }

    // page change notifications (dart onPageChanged fires at the half-way point)
    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.currentPage }.collect { if (currentPage != it) currentPage = it }
    }
    // scroll start by drag / scroll end
    LaunchedEffect(isDragged) { if (isDragged) isUserScrolling = true }
    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.isScrollInProgress }.drop(1).collect { scrolling ->
            if (!scrolling) {
                isUserScrolling = false
                syncActiveProfile(currentPage)
            }
        }
    }
    // follow external active-profile changes
    val activeIdx = profiles.indexOfFirst { it.id == currentProfileId }
    LaunchedEffect(activeIdx) {
        if (!isUserScrolling && activeIdx >= 0 && activeIdx != currentPage) {
            currentPage = activeIdx
            pagerState.animateScrollToPage(activeIdx, animationSpec = pageSpec)
        }
    }

    Column(Modifier.fillMaxWidth()) {
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxWidth().height(310.dp),
            snapPosition = SnapPosition.Start,
            verticalAlignment = Alignment.Top,
            key = { "profile_card_${profiles[it].id}" },
        ) { index ->
            Box(
                Modifier.graphicsLayer {
                    val page = pagerState.currentPage + pagerState.currentPageOffsetFraction
                    val delta = abs(page - index).coerceIn(0f, 1f)
                    val scale = 1f - delta * 0.04f
                    scaleX = scale
                    scaleY = scale
                    alpha = (1f - delta * 0.25f).coerceIn(0f, 1f)
                },
            ) {
                Card(profiles[index])
            }
        }
        Spacer(Modifier.height(6.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
            profiles.indices.forEach { i ->
                val isCurrent = i == currentPage
                val width by animateDpAsState(if (isCurrent) 24.dp else 6.dp, tween(240, easing = FlutterCurves.easeInOut), label = "dotWidth")
                val color by animateColorAsState(
                    if (isCurrent) AppColors.neoChartreuse else Color.White.copy(alpha = 0.22f),
                    tween(240, easing = FlutterCurves.easeInOut),
                    label = "dotColor",
                )
                Box(
                    modifier = Modifier
                        .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                            if (currentPage == i) return@clickable
                            currentPage = i
                            scope.launch {
                                pagerState.animateScrollToPage(i, animationSpec = pageSpec)
                                syncActiveProfile(i)
                            }
                        }
                        .padding(horizontal = 5.dp, vertical = 8.dp),
                ) {
                    Box(Modifier.size(width, 5.dp).background(color, RoundedCornerShape(3.dp)))
                }
            }
        }
    }
}
