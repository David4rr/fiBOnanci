package com.fibonanci.app.ui.inbox

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun InboxInlineEditForm(
    initialAmount: Double,
    initialType: String,
    initialCounterparty: String,
    walletName: String? = null,
    onSave: (Map<String, Any?>) -> Unit,
    onCancel: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    var type by remember { mutableStateOf(initialType) }
    var amountText by remember { mutableStateOf(if (initialAmount > 0) initialAmount.toLong().toString() else "") }
    var notesText by remember { mutableStateOf(initialCounterparty) }

    fun submit() {
        val rawAmt = AppCurrency.parseInputToIdr(amountText, state.profile.currency)
        if (rawAmt <= 0) return
        onSave(mapOf("amount" to rawAmt, "type" to type, "counterparty" to notesText.trim()))
    }

    val isIncome = type == "income"
    val sectionLabel = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 10.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = 0.8.sp,
        color = AppColors.textMuted,
    )

    Column(modifier = modifier.fillMaxWidth()) {
        ModalHeader(
            title = "Sesuaikan Transaksi",
            subtitle = if (walletName != null) "Rekening: $walletName" else "Ubah nominal & tipe transaksi",
            closeIcon = Icons.AutoMirrored.Rounded.KeyboardArrowLeft,
            onClose = onCancel,
        )
        Spacer(Modifier.height(14.dp))
        Row {
            TypeButton(
                label = "Pengeluaran",
                isSelected = !isIncome,
                activeColor = AppColors.neoCoral,
                onTap = { type = "expense" },
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(10.dp))
            TypeButton(
                label = "Pemasukan",
                isSelected = isIncome,
                activeColor = AppColors.neoMint,
                onTap = { type = "income" },
                modifier = Modifier.weight(1f),
            )
        }
        Spacer(Modifier.height(16.dp))
        Text("NOMINAL TRANSAKSI", style = sectionLabel)
        Spacer(Modifier.height(6.dp))
        CurrencyAmountField(
            value = amountText,
            onValueChange = { amountText = it },
            prefixColor = if (isIncome) AppColors.neoMint else AppColors.neoCoral,
            hintText = "0",
        )
        Spacer(Modifier.height(14.dp))
        Text("MERCHANT / PENERIMA / CATATAN", style = sectionLabel)
        Spacer(Modifier.height(6.dp))
        AppTextField(
            value = notesText,
            onValueChange = { notesText = it },
            hintText = "Contoh: Kopi Kenangan, Transfer Budi",
        )
        Spacer(Modifier.height(18.dp))
        PrimaryActionButton(text = "Simpan Perubahan", onPressed = { submit() })
    }
}

@Composable
private fun TypeButton(
    label: String,
    isSelected: Boolean,
    activeColor: Color,
    onTap: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val spec = tween<Color>(180)
    val bg by animateColorAsState(if (isSelected) activeColor.copy(alpha = 0.15f) else AppColors.canvasInputSearch, spec, label = "bg")
    val borderColor by animateColorAsState(if (isSelected) activeColor else AppColors.canvasBorder, spec, label = "border")
    val borderWidth by animateDpAsState(if (isSelected) 1.2.dp else 0.8.dp, tween(180), label = "width")
    val shape = RoundedCornerShape(10.dp)
    Box(
        modifier = modifier
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onTap)
            .background(bg, shape)
            .border(borderWidth, borderColor, shape)
            .padding(vertical = 10.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 12.sp,
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                color = if (isSelected) activeColor else AppColors.textMuted,
            ),
        )
    }
}
