package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CheckCircleOutline
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.LocalOffer
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.delay
import kotlin.math.abs
import kotlin.math.round
import kotlin.math.roundToInt

private val presets = listOf(10, 20, 25, 50)

@Composable
fun SubscriptionDetailPayButton(
    subscription: SubscriptionEntry,
    wallet: WalletEntry,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val haptic = LocalHapticFeedback.current
    val state by vm.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val sub = subscription

    var isMorphed by remember { mutableStateOf(false) }
    var useCustomAmount by remember { mutableStateOf(false) }
    var selectedPresetPct by remember { mutableStateOf<Int?>(null) }
    var customAmountText by remember { mutableStateOf(AppCurrency.formatIdrForInput(sub.cost, currency)) }

    // morph controller (950ms): when it completes, close the route and confirm with a snackbar
    LaunchedEffect(isMorphed) {
        if (!isMorphed) return@LaunchedEffect
        delay(950)
        onDismiss()
        host.showSnackBar(
            "Tagihan ${sub.title} ditandai lunas! Saldo ${wallet.name} terpotong otomatis.",
            background = AppColors.neoMint,
            contentColor = AppColors.textDarkPrimary,
        )
    }

    fun applyPreset(pct: Int?) {
        haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
        val target = if (pct == null) sub.cost else round(sub.cost * (100 - pct) / 100)
        selectedPresetPct = pct
        customAmountText = AppCurrency.formatIdrForInput(target, currency)
    }

    fun toggleDiscount() {
        haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
        useCustomAmount = !useCustomAmount
        if (!useCustomAmount) {
            selectedPresetPct = null
            customAmountText = AppCurrency.formatIdrForInput(sub.cost, currency)
        }
    }

    fun handlePay() {
        if (isMorphed) return
        val parsed = if (useCustomAmount) AppCurrency.parseInputToIdr(customAmountText, currency) else 0.0
        isMorphed = true
        haptic.performHapticFeedback(HapticFeedbackType.Confirm)
        vm.markSubscriptionPaid(sub.id, actualAmount = if (parsed > 0) parsed else null)
    }

    val isPaidThisMonth = sub.isPaidThisMonth()
    val totalCycles = sub.totalCycles ?: 0
    val isCompleted = sub.status == "completed" || (sub.isInstallment && totalCycles > 0 && sub.paidCycles >= totalCycles)

    if ((isPaidThisMonth || isCompleted) && !isMorphed) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasCardSurface, RoundedCornerShape(18.dp))
                .border(1.dp, AppColors.neoChartreuse.copy(alpha = 0.28f), RoundedCornerShape(18.dp))
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(Modifier.size(28.dp).background(AppColors.neoChartreuse, CircleShape), contentAlignment = Alignment.Center) {
                Icon(Icons.Rounded.Check, contentDescription = null, tint = AppColors.textDarkPrimary, modifier = Modifier.size(17.dp))
            }
            Spacer(Modifier.width(12.dp))
            Text(
                if (isCompleted) "Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai." else "Tagihan periode bulan ini telah lunas tercatat di buku kas.",
                modifier = Modifier.weight(1f),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    color = AppColors.textWhite,
                    fontSize = 12.5.sp,
                    fontWeight = FontWeight.W600,
                    lineHeight = (12.5 * 1.35).sp,
                ),
            )
        }
        return
    }

    val fmt: (Double) -> String = { AppCurrency.format(it, currency) }
    val parsed = if (useCustomAmount) AppCurrency.parseInputToIdr(customAmountText, currency) else sub.cost
    val effectiveCost = if (parsed > 0) parsed else sub.cost
    val diff = sub.cost - effectiveCost
    val hasDiscount = useCustomAmount && diff > 0.01
    val savedPct = if (sub.cost > 0 && hasDiscount) ((diff / sub.cost) * 100).roundToInt().coerceIn(1, 99) else 0
    val baseLabel = if (sub.isInstallment) {
        "Bayar Cicilan Bulan Ini (${sub.paidCycles + 1}/${if (totalCycles > 0) totalCycles.toString() else "?"})"
    } else {
        "Tandai Sudah Lunas Bulan Ini"
    }
    val buttonText = if (useCustomAmount && abs(effectiveCost - sub.cost) > 0.01) "Bayar ${fmt(effectiveCost)} Bulan Ini" else baseLabel

    Column {
        val panelShape = RoundedCornerShape(16.dp)
        Column(
            modifier = Modifier
                .padding(bottom = 10.dp)
                .fillMaxWidth()
                .background(AppColors.canvasCardSurface, panelShape)
                .border(1.dp, if (useCustomAmount) AppColors.neoChartreuse.copy(alpha = 0.45f) else AppColors.canvasBorder, panelShape),
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { toggleDiscount() }
                    .padding(horizontal = 14.dp, vertical = 11.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(
                    Icons.Rounded.LocalOffer,
                    contentDescription = null,
                    modifier = Modifier.size(17.dp),
                    tint = if (useCustomAmount) AppColors.neoChartreuse else AppColors.textMuted,
                )
                Spacer(Modifier.width(10.dp))
                Column(Modifier.weight(1f)) {
                    Text(
                        "Diskon / Promo Bulan Ini",
                        style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.5.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite),
                    )
                    Text(
                        if (hasDiscount) "Hemat ${fmt(diff)} (-$savedPct%) dari harga normal" else "Sesuaikan nominal bayar tanpa ubah tarif tetap",
                        style = TextStyle(
                            fontFamily = PlusJakartaSans,
                            fontSize = 10.5.sp,
                            fontWeight = FontWeight.W600,
                            color = if (hasDiscount) AppColors.neoMint else AppColors.textMuted,
                        ),
                    )
                }
                Text(
                    if (useCustomAmount) "Tutup" else "Pakai Promo",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.W800,
                        color = if (useCustomAmount) AppColors.neoChartreuse else AppColors.textWhite,
                    ),
                )
            }
            if (useCustomAmount) {
                Column(Modifier.padding(start = 14.dp, end = 14.dp, bottom = 12.dp)) {
                    HorizontalDivider(modifier = Modifier.padding(vertical = 5.5.dp), thickness = 1.dp, color = AppColors.canvasBorder)
                    Row(Modifier.horizontalScroll(rememberScrollState())) {
                        for (pct in presets) {
                            PresetChip("-$pct%", selectedPresetPct == pct) { applyPreset(pct) }
                        }
                        PresetChip("Normal", selectedPresetPct == null && abs(effectiveCost - sub.cost) < 0.01) { applyPreset(null) }
                    }
                    Spacer(Modifier.height(10.dp))
                    CurrencyAmountField(
                        value = customAmountText,
                        onValueChange = { customAmountText = it },
                        labelText = "Nominal Bayar Aktual Bulan Ini",
                    )
                }
            }
        }
        PrimaryActionButton(
            text = if (isMorphed) "Berhasil Dibayar!" else buttonText,
            icon = if (isMorphed) Icons.Rounded.CheckCircle else Icons.Outlined.CheckCircleOutline,
            backgroundColor = if (isMorphed) AppColors.neoMint else AppColors.neoChartreuse,
            onPressed = { handlePay() },
        )
    }
}

@Composable
private fun PresetChip(label: String, active: Boolean, onTap: () -> Unit) {
    val shape = RoundedCornerShape(8.dp)
    Box(
        modifier = Modifier
            .padding(end = 6.dp)
            .background(if (active) AppColors.neoChartreuse else AppColors.canvasInputSearch, shape)
            .border(1.dp, if (active) AppColors.neoChartreuse else AppColors.canvasBorder, shape)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onTap)
            .padding(horizontal = 10.dp, vertical = 5.dp),
    ) {
        Text(
            label,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 11.sp,
                fontWeight = FontWeight.W800,
                color = if (active) AppColors.textDarkPrimary else AppColors.textWhite,
            ),
        )
    }
}
