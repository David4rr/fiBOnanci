package com.fibonanci.app.ui.common

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseInCubic
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionOnScreen
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupPositionProvider
import androidx.compose.ui.window.PopupProperties
import com.fibonanci.app.data.db.WalletEntry
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

// the overlay popup covers the whole window from its origin
private object WindowOriginPositionProvider : PopupPositionProvider {
    override fun calculatePosition(
        anchorBounds: IntRect,
        windowSize: IntSize,
        layoutDirection: LayoutDirection,
        popupContentSize: IntSize,
    ): IntOffset = IntOffset.Zero
}

/**
 * floating morphing search bar whose dropdown container expands on top of the
 * following widgets without pushing them down.
 */
@Composable
fun ExpandableSearchFilterBar(
    searchQuery: String,
    typeFilter: String,
    walletFilter: String? = null,
    wallets: List<WalletEntry> = emptyList(),
    showWalletFilter: Boolean = true,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onFilterApplied: (type: String, walletId: String?) -> Unit,
    onClearTypeFilter: (() -> Unit)? = null,
    onClearWalletFilter: (() -> Unit)? = null,
    hintText: String = "Cari transaksi, rekening, merchant...",
    headerTitle: String = "Filter Transaksi",
    primaryFilterTitle: String = "TIPE TRANSAKSI",
    primaryFilterChoices: List<FilterChoice> = kDefaultTransactionTypeChoices,
    padding: PaddingValues = PaddingValues(horizontal = 20.dp, vertical = 4.dp),
    borderRadius: Dp = 10.dp,
    showActiveChipsBelow: Boolean = true,
    modifier: Modifier = Modifier,
) {
    val scope = rememberCoroutineScope()
    val haptics = LocalHapticFeedback.current
    val focusManager = LocalFocusManager.current
    val density = LocalDensity.current

    val expand = remember { Animatable(0f) }
    var isExpanded by remember { mutableStateOf(false) }
    var tempType by remember { mutableStateOf(typeFilter) }
    var tempWalletId by remember { mutableStateOf(walletFilter) }
    var barScreenPos by remember { mutableStateOf(Offset.Zero) }
    var barWidthPx by remember { mutableIntStateOf(0) }
    var overlayScreenPos by remember { mutableStateOf(Offset.Zero) }

    fun openOverlay() {
        focusManager.clearFocus()
        tempType = typeFilter
        tempWalletId = walletFilter
        isExpanded = true
        scope.launch {
            expand.snapTo(0f)
            expand.animateTo(1f, tween(260, easing = FastOutSlowInEasing))
        }
    }

    fun closeOverlay() {
        if (!isExpanded) return
        scope.launch {
            expand.animateTo(0f, tween((200 * expand.value).roundToInt(), easing = EaseInCubic))
            isExpanded = false
        }
    }

    fun toggleExpanded() {
        haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
        if (isExpanded) closeOverlay() else openOverlay()
    }

    fun applyFilter() {
        haptics.performHapticFeedback(HapticFeedbackType.Confirm)
        onFilterApplied(tempType, tempWalletId)
        closeOverlay()
    }

    fun resetFilter() {
        haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
        tempType = "all"
        tempWalletId = null
        onFilterApplied("all", null)
        closeOverlay()
    }

    val typeChipLabel = primaryFilterChoices.firstOrNull { it.value == typeFilter }?.chipLabel
        ?: "Tipe: ${typeFilter.uppercase()}"
    val hasActiveFilter = typeFilter != "all" || walletFilter != null

    Column(modifier) {
        Box(Modifier.padding(padding)) {
            ExpandableSearchRestingBar(
                searchQuery = searchQuery,
                hintText = hintText,
                borderRadius = borderRadius,
                isExpanded = isExpanded,
                hasActiveFilter = hasActiveFilter,
                onSearchChanged = onSearchChanged,
                onClearSearch = onClearSearch,
                onToggleExpanded = { toggleExpanded() },
                modifier = Modifier.onGloballyPositioned {
                    barScreenPos = it.positionOnScreen()
                    barWidthPx = it.size.width
                },
            )
            if (isExpanded) {
                Popup(
                    popupPositionProvider = WindowOriginPositionProvider,
                    onDismissRequest = { closeOverlay() },
                    properties = PopupProperties(focusable = true, clippingEnabled = false),
                ) {
                    Box(Modifier.onGloballyPositioned { overlayScreenPos = it.positionOnScreen() }) {
                        ExpandableSearchDropdownOverlay(
                            searchQuery = searchQuery,
                            hintText = hintText,
                            barBorderRadius = borderRadius,
                            headerTitle = headerTitle,
                            primaryFilterTitle = primaryFilterTitle,
                            primaryFilterChoices = primaryFilterChoices,
                            wallets = wallets,
                            showWalletFilter = showWalletFilter,
                            onSearchChanged = onSearchChanged,
                            onClearSearch = onClearSearch,
                            anchorOffset = IntOffset(
                                (barScreenPos.x - overlayScreenPos.x).roundToInt(),
                                (barScreenPos.y - overlayScreenPos.y).roundToInt(),
                            ),
                            width = with(density) { barWidthPx.toDp() },
                            animation = expand.value,
                            tempType = tempType,
                            tempWalletId = tempWalletId,
                            hasActiveFilter = hasActiveFilter,
                            onSelectType = { tempType = it },
                            onSelectWallet = { tempWalletId = it },
                            onReset = { resetFilter() },
                            onApply = { applyFilter() },
                            onClose = { closeOverlay() },
                        )
                    }
                }
            }
        }
        if (showActiveChipsBelow && hasActiveFilter && !isExpanded) {
            ExpandableSearchActiveChips(
                typeChipLabel = typeChipLabel,
                hasTypeFilter = typeFilter != "all",
                walletFilter = walletFilter,
                wallets = wallets,
                onClearType = onClearTypeFilter ?: { onFilterApplied("all", walletFilter) },
                onClearWallet = onClearWalletFilter ?: { onFilterApplied(typeFilter, null) },
            )
        }
    }
}
