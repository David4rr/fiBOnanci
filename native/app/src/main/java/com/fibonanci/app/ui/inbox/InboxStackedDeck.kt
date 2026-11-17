package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.notification.NotificationParser
import com.fibonanci.app.ui.theme.AppColors
import kotlin.math.abs

@Composable
fun InboxStackedDeck(
    items: List<Map<String, Any?>>,
    onConfirm: (Map<String, Any?>) -> Unit,
    onReject: (Map<String, Any?>) -> Unit,
    onReassign: ((Map<String, Any?>) -> Unit)? = null,
    onEdit: ((Map<String, Any?>) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val dragProgress = remember { mutableFloatStateOf(0f) }
    val count = items.size
    if (count == 0) return

    val density = LocalDensity.current
    val threshold = with(density) { LocalConfiguration.current.screenWidthDp.dp.toPx() } * 0.50f

    // minimalist clean: at most 1 subtle hint card behind active card
    val hasBackCard = count >= 2
    val bottomPad = if (hasBackCard) 10.dp else 0.dp

    Box(modifier = modifier.padding(bottom = bottomPad), contentAlignment = Alignment.TopCenter) {
        if (hasBackCard) {
            val item = items[1]
            Box(
                Modifier
                    .matchParentSize()
                    .graphicsLayer {
                        val progress = dragProgress.floatValue
                        val scale = 0.96f + (1.0f - 0.96f) * progress
                        val translateY = 10f + (0f - 10f) * progress
                        translationY = translateY * density.density
                        scaleX = scale
                        scaleY = scale
                        transformOrigin = TransformOrigin(0.5f, 1f)
                        alpha = (0.65f + (1.0f - 0.65f) * progress).coerceIn(0f, 1f)
                    },
            ) {
                CardContent(item, 1, count, isTopCard = false, onReassign = onReassign, onEdit = onEdit)
            }
        }

        val top = items[0]
        val pkg = (top["package"] ?: "").toString()
        val text = (top["text"] ?: "").toString()
        key(top["transactionId"] ?: "${pkg}_${text}_0") {
            SpringSwipeableCard(
                accentColor = resolveAccentColor(top),
                onConfirmed = { onConfirm(top) },
                onRejected = { onReject(top) },
                onDragOffsetChanged = { offset ->
                    dragProgress.floatValue = (abs(offset).toFloat() / threshold).coerceIn(0f, 1f)
                },
            ) {
                CardContent(top, 0, count, isTopCard = true, onReassign = onReassign, onEdit = onEdit)
            }
        }
    }
}

@Composable
private fun CardContent(
    item: Map<String, Any?>,
    index: Int,
    totalCount: Int,
    isTopCard: Boolean,
    onReassign: ((Map<String, Any?>) -> Unit)?,
    onEdit: ((Map<String, Any?>) -> Unit)?,
) {
    val pkg = (item["package"] ?: "").toString()
    val title = (item["title"] ?: "").toString()
    val text = (item["text"] ?: "").toString()
    val parsed = remember(pkg, title, text) {
        NotificationParser.parse(packageName = pkg, title = title, body = text, timestamp = null)
    }

    val amount = (item["amount"] as? Number)?.toDouble() ?: parsed?.amount ?: 0.0
    val type = (item["type"] as? String) ?: parsed?.type ?: "expense"
    val counterparty = (item["counterparty"] as? String) ?: parsed?.counterparty ?: ""
    InboxNotificationCard(
        bankLabel = resolveBankLabel(pkg, title),
        type = type,
        amount = amount,
        counterparty = counterparty,
        walletName = item["walletName"] as? String,
        profileName = item["profileName"] as? String,
        onSwitchWallet = if (isTopCard && onReassign != null) ({ onReassign(item) }) else null,
        onEdit = if (isTopCard && onEdit != null) ({ onEdit(item) }) else null,
        text = text,
        cardAccent = resolveAccentColor(item, type),
        currentIndex = index,
        totalCount = totalCount,
        isTopCard = isTopCard,
    )
}

private fun resolveBankLabel(pkg: String, title: String): String {
    val p = pkg.lowercase()
    return when {
        p.contains("bca") -> "BCA"
        p.contains("mandiri") || p.contains("livin") -> "Mandiri"
        p.contains("bri") || p.contains("brimo") -> "BRI"
        p.contains("bni") -> "BNI"
        p.contains("jago") -> "Bank Jago"
        p.contains("seabank") -> "SeaBank"
        p.contains("gopay") -> "GoPay"
        p.contains("ovo") -> "OVO"
        p.contains("dana") -> "DANA"
        p.contains("shopee") -> "ShopeePay"
        else -> title.ifEmpty { "Bank" }
    }
}

private fun resolveAccentColor(item: Map<String, Any?>, typeHint: String? = null): Color {
    val type = (item["type"] as? String) ?: typeHint ?: "expense"
    if (type == "income") return AppColors.neoMint
    val pkg = (item["package"] ?: "").toString().lowercase()
    return when {
        pkg.contains("bca") -> Color(0xFF005E9E)
        pkg.contains("mandiri") -> Color(0xFFFFB300)
        pkg.contains("bri") -> Color(0xFF00529C)
        pkg.contains("bni") -> Color(0xFFF15A24)
        pkg.contains("jago") -> Color(0xFFFF7A00)
        pkg.contains("seabank") -> Color(0xFFFF5722)
        pkg.contains("gopay") -> Color(0xFF00AED6)
        pkg.contains("ovo") -> Color(0xFF4C2A86)
        pkg.contains("dana") -> Color(0xFF118EEA)
        else -> AppColors.neoCoral
    }
}
