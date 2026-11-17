package com.fibonanci.app.ui.transaction

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ArrowDropDown
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.BorderStroke
import com.fibonanci.app.core.smartinput.SmartInputBridge
import com.fibonanci.app.core.smartinput.SmartInputSource
import com.fibonanci.app.core.smartinput.SmartTransactionDraft
import com.fibonanci.app.core.smartinput.SmartTransactionParser
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

suspend fun executeSmartTransactionCapture(
    host: ModalHost,
    source: SmartInputSource,
    wallets: List<WalletEntry>,
    categories: List<CategoryEntry>,
    preferredWalletId: String? = null,
): SmartTransactionDraft? {
    val rawText: String?
    if (source == SmartInputSource.voice) {
        val override = SmartInputBridge.testVoiceOverride
        rawText = if (override != null) {
            override()
        } else {
            suspendCancellableCoroutine { cont ->
                showSmartInputFallbackSheet(host, source) { text -> if (cont.isActive) cont.resume(text) }
            }
        }
    } else {
        val res = SmartInputBridge.capturePhotoAndExtractText(fromCamera = source == SmartInputSource.camera)
        if (res.canceled) return null
        rawText = res.ocrText
    }
    if (rawText == null || rawText.trim().isEmpty()) return null

    return SmartTransactionParser.parse(
        rawText = rawText,
        source = source,
        wallets = wallets,
        categories = categories,
        preferredWalletId = preferredWalletId,
    )
}

@Composable
fun TransactionTypeToggle(
    selectedType: String,
    onTypeChanged: (String) -> Unit,
) {
    val haptic = LocalHapticFeedback.current

    @Composable
    fun RowScope.Pill(label: String, value: String, activeColor: Color) {
        val isSelected = selectedType == value
        val bg by animateColorAsState(if (isSelected) activeColor else AppColors.canvasInputSearch, tween(180), label = "pillBg")
        val border by animateColorAsState(if (isSelected) activeColor else AppColors.canvasBorder, tween(180), label = "pillBorder")
        Box(
            Modifier
                .weight(1f)
                .clickable(remember { MutableInteractionSource() }, null) {
                    haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                    onTypeChanged(value)
                }
                .background(bg, RoundedCornerShape(14.dp))
                .border(1.2.dp, border, RoundedCornerShape(14.dp))
                .padding(vertical = 10.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                label,
                style = AppTypography.listTitle.copy(
                    color = if (isSelected) AppColors.textDarkPrimary else AppColors.textWhite,
                    fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.Medium,
                    fontSize = 13.sp,
                ),
            )
        }
    }

    Row(Modifier.fillMaxWidth()) {
        Pill("Pengeluaran", "expense", AppColors.neoCoral)
        Spacer(Modifier.width(8.dp))
        Pill("Pemasukan", "income", AppColors.neoMint)
        Spacer(Modifier.width(8.dp))
        Pill("Transfer", "transfer", AppColors.neoCyan)
    }
}

@Composable
fun TransactionDropdownContainer(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    Box(
        modifier
            .fillMaxWidth()
            .background(AppColors.canvasInputSearch, RoundedCornerShape(16.dp))
            .border(0.8.dp, AppColors.canvasBorder, RoundedCornerShape(16.dp))
            .padding(horizontal = 16.dp, vertical = 4.dp),
    ) { content() }
}

// compose stand-in for flutter's DropdownButton<String> (underline hidden, isExpanded: true)
@Composable
fun <T> TransactionDropdownButton(
    value: T?,
    items: List<T>,
    onChanged: (T) -> Unit,
    hint: (@Composable () -> Unit)? = null,
    itemContent: @Composable (T) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    Box(Modifier.fillMaxWidth()) {
        Row(
            Modifier
                .fillMaxWidth()
                .height(48.dp)
                .clickable(remember { MutableInteractionSource() }, null, enabled = items.isNotEmpty()) { expanded = true },
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(Modifier.weight(1f)) {
                if (value != null && items.contains(value)) itemContent(value) else hint?.invoke()
            }
            Icon(Icons.Rounded.ArrowDropDown, null, tint = if (items.isNotEmpty()) AppColors.textMuted else AppColors.textSubtle)
        }
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
            containerColor = AppColors.canvasCardSurface,
        ) {
            items.forEach { item ->
                DropdownMenuItem(
                    text = { itemContent(item) },
                    onClick = {
                        expanded = false
                        onChanged(item)
                    },
                )
            }
        }
    }
}

@Composable
fun TransactionActionFooter(
    onCancel: () -> Unit,
    onSave: () -> Unit,
) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        OutlinedButton(
            onClick = onCancel,
            modifier = Modifier.weight(1f).height(52.dp),
            shape = RoundedCornerShape(16.dp),
            border = BorderStroke(1.dp, AppColors.canvasBorder),
        ) {
            Text("Batal", style = AppTypography.listTitle.copy(color = AppColors.textMuted, fontWeight = FontWeight.SemiBold))
        }
        Box(Modifier.weight(2f)) {
            PrimaryActionButton(text = "Simpan Transaksi", onPressed = onSave)
        }
    }
}
