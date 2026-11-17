@file:OptIn(ExperimentalMaterial3ExpressiveApi::class, ExperimentalLayoutApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Remove
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SegmentedListItem
import androidx.compose.material3.Slider
import androidx.compose.material3.SuggestionChip
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.data.db.TRANSFER_CATEGORY_ID
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import java.time.LocalDate
import kotlin.math.roundToInt

// "catat": expense, income or a move between wallets
@Composable
fun EntrySheet(initial: EntryType, state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    val currency = state.profile.currency
    var type by remember { mutableStateOf(initial) }
    var amount by remember { mutableStateOf(TextFieldValue("")) }
    var fromPick by remember { mutableStateOf<String?>(null) }
    var toPick by remember { mutableStateOf<String?>(null) }
    var categoryPick by remember { mutableStateOf<String?>(null) }
    var notes by remember { mutableStateOf("") }
    val focus = remember { FocusRequester() }
    LaunchedEffect(Unit) { focus.requestFocus() }

    val wallets = state.wallets
    val fromId = fromPick?.takeIf { id -> wallets.any { it.id == id } } ?: wallets.firstOrNull()?.id
    val destinations = wallets.filter { it.id != fromId }
    val toId = toPick?.takeIf { id -> destinations.any { it.id == id } } ?: destinations.firstOrNull()?.id
    val categories = state.categories.filter { it.type == type.apiType && it.id != TRANSFER_CATEGORY_ID }
    val categoryId = if (type == EntryType.Transfer) TRANSFER_CATEGORY_ID
    else categoryPick?.takeIf { id -> categories.any { it.id == id } } ?: categories.firstOrNull()?.id
    val value = AppCurrency.parseInputToIdr(amount.text, currency)
    val amountError = amount.text.isNotEmpty() && value <= 0
    val canSave = value > 0 && fromId != null && categoryId != null &&
        (type != EntryType.Transfer || (toId != null && toId != fromId))

    SimpleSheet(title = "Catat", onDismiss = onDismiss) { close ->
        ConnectedChoice(
            options = EntryType.entries.map { it to it.label },
            selected = type,
            onSelect = { type = it },
        )
        TextField(
            value = amount,
            onValueChange = { amount = RupiahInputFormatter.formatEditUpdate(amount, it) },
            modifier = Modifier.fillMaxWidth().focusRequester(focus),
            label = { Text("Nominal") },
            placeholder = { Text("0", style = MaterialTheme.typography.displaySmall.money()) },
            prefix = { Text(AppCurrency.symbolFor(currency), style = MaterialTheme.typography.displaySmall.money()) },
            textStyle = MaterialTheme.typography.displaySmall.money(),
            supportingText = { Text(if (amountError) "Nominal harus lebih dari 0" else "Isi berapa yang ${verb(type)}") },
            isError = amountError,
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = ImeAction.Next),
        )
        WalletChips(
            title = if (type == EntryType.Income) "Masuk ke rekening" else "Dari rekening",
            wallets = wallets,
            selectedId = fromId,
            onSelect = { fromPick = it },
            error = if (wallets.isEmpty()) "Belum ada rekening. Tambah rekening dulu." else null,
        )
        if (type == EntryType.Transfer) {
            WalletChips(
                title = "Ke rekening",
                wallets = destinations,
                selectedId = toId,
                onSelect = { toPick = it },
                error = if (destinations.isEmpty()) "Butuh minimal dua rekening untuk pindah saldo" else null,
            )
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text("Kategori", style = MaterialTheme.typography.titleSmall)
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    categories.forEach { category ->
                        FilterChip(
                            selected = category.id == categoryId,
                            onClick = { categoryPick = category.id },
                            label = { Text(category.name) },
                        )
                    }
                }
                if (categories.isEmpty()) {
                    Text(
                        "Belum ada kategori ${type.label.lowercase()}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.error,
                    )
                }
            }
        }
        OutlinedTextField(
            value = notes,
            onValueChange = { notes = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Catatan (opsional)") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences, imeAction = ImeAction.Done),
        )
        PrimaryAction(text = "Simpan", enabled = canSave) {
            haptic.performHapticFeedback(HapticFeedbackType.Confirm)
            close {
                vm.addTransaction(
                    walletId = fromId!!,
                    categoryId = categoryId!!,
                    amount = value,
                    type = type.apiType,
                    destinationWalletId = if (type == EntryType.Transfer) toId else null,
                    notes = notes.trim().ifBlank { null },
                )
                onSaved("Tersimpan")
            }
        }
    }
}

private fun verb(type: EntryType): String = when (type) {
    EntryType.Expense -> "keluar"
    EntryType.Income -> "masuk"
    EntryType.Transfer -> "dipindah"
}

@Composable
fun NewBillSheet(state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    val currency = state.profile.currency
    var title by remember { mutableStateOf("") }
    var amount by remember { mutableStateOf(TextFieldValue("")) }
    var dueDay by remember { mutableFloatStateOf(LocalDate.now().dayOfMonth.toFloat()) }
    var isInstallment by remember { mutableStateOf(false) }
    var cycles by remember { mutableIntStateOf(3) }
    var walletPick by remember { mutableStateOf<String?>(null) }
    var titleTouched by remember { mutableStateOf(false) }

    val walletId = walletPick?.takeIf { id -> state.wallets.any { it.id == id } } ?: state.wallets.firstOrNull()?.id
    val category = state.categories.firstOrNull { it.name == "Tagihan & Utilitas" }
        ?: state.categories.firstOrNull { it.type == "expense" && it.id != TRANSFER_CATEGORY_ID }
    val cost = AppCurrency.parseInputToIdr(amount.text, currency)
    val day = dueDay.roundToInt()
    val canSave = title.isNotBlank() && cost > 0 && walletId != null && category != null

    SimpleSheet(title = "Tagihan baru", onDismiss = onDismiss) { close ->
        OutlinedTextField(
            value = title,
            onValueChange = {
                title = it
                titleTouched = true
            },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Nama") },
            placeholder = { Text("Listrik, internet, cicilan HP") },
            isError = titleTouched && title.isBlank(),
            supportingText = if (titleTouched && title.isBlank()) ({ Text("Nama tagihan wajib diisi") }) else null,
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences, imeAction = ImeAction.Next),
        )
        AmountField(
            value = amount,
            onValueChange = { amount = it },
            label = "Nominal per bayar",
            currency = currency,
            isError = amount.text.isNotEmpty() && cost <= 0,
            supporting = if (amount.text.isNotEmpty() && cost <= 0) "Nominal harus lebih dari 0" else null,
        )
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Jatuh tempo", style = MaterialTheme.typography.titleSmall, modifier = Modifier.weight(1f))
                Text("Tiap tanggal $day", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.primary)
            }
            Slider(
                value = dueDay,
                onValueChange = {
                    if (it.roundToInt() != day) haptic.performHapticFeedback(HapticFeedbackType.SegmentFrequentTick)
                    dueDay = it
                },
                valueRange = 1f..31f,
                steps = 29,
            )
        }
        Column {
            SegmentedListItem(
                checked = isInstallment,
                onCheckedChange = { isInstallment = it },
                shapes = groupShapes(0, 1),
                colors = groupColors(MaterialTheme.colorScheme.surfaceContainerHigh),
                supportingContent = { Text("Dibayar beberapa kali sampai lunas") },
                trailingContent = { Switch(checked = isInstallment, onCheckedChange = null) },
            ) {
                Text("Ini cicilan")
            }
            AnimatedVisibility(
                visible = isInstallment,
                enter = expandVertically(MaterialTheme.motionScheme.defaultSpatialSpec()) +
                    fadeIn(MaterialTheme.motionScheme.defaultEffectsSpec()),
                exit = shrinkVertically(MaterialTheme.motionScheme.fastSpatialSpec()) +
                    fadeOut(MaterialTheme.motionScheme.fastEffectsSpec()),
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text("Berapa kali bayar", style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
                    FilledTonalIconButton(
                        onClick = { cycles-- },
                        enabled = cycles > 1,
                        shapes = IconButtonDefaults.shapes(),
                    ) { Icon(Icons.Rounded.Remove, contentDescription = "Kurangi") }
                    Text(
                        "${cycles}x",
                        style = MaterialTheme.typography.titleLarge.money(),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.widthIn(min = 48.dp),
                    )
                    FilledTonalIconButton(
                        onClick = { cycles++ },
                        shapes = IconButtonDefaults.shapes(),
                    ) { Icon(Icons.Rounded.Add, contentDescription = "Tambah") }
                }
            }
        }
        WalletChips(
            title = "Dibayar dari",
            wallets = state.wallets,
            selectedId = walletId,
            onSelect = { walletPick = it },
            error = if (state.wallets.isEmpty()) "Belum ada rekening. Tambah rekening dulu." else null,
        )
        if (category == null) {
            Text("Belum ada kategori pengeluaran", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.error)
        }
        PrimaryAction(text = "Simpan", enabled = canSave) {
            haptic.performHapticFeedback(HapticFeedbackType.Confirm)
            close {
                vm.addSubscription(
                    title = title.trim(),
                    cost = cost,
                    dueDay = day,
                    walletId = walletId!!,
                    categoryId = category!!.id,
                    isInstallment = isInstallment,
                    totalCycles = if (isInstallment) cycles else null,
                )
                onSaved("Tagihan tersimpan")
            }
        }
    }
}

private val walletSuggestions = listOf(
    "BCA" to "bank", "Mandiri" to "bank", "BRI" to "bank", "BNI" to "bank", "Jago" to "bank", "SeaBank" to "bank",
    "GoPay" to "ewallet", "OVO" to "ewallet", "DANA" to "ewallet", "Tunai" to "cash",
)

@Composable
fun NewWalletSheet(state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    val currency = state.profile.currency
    var name by remember { mutableStateOf("") }
    var type by remember { mutableStateOf("bank") }
    var balance by remember { mutableStateOf(TextFieldValue("")) }

    SimpleSheet(title = "Rekening baru", onDismiss = onDismiss) { close ->
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Nama rekening") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Next),
        )
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            walletSuggestions.forEach { (label, kind) ->
                SuggestionChip(
                    onClick = {
                        name = label
                        type = kind
                    },
                    label = { Text(label) },
                )
            }
        }
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("Jenis", style = MaterialTheme.typography.titleSmall)
            ConnectedChoice(
                options = listOf("bank" to "Bank", "ewallet" to "E-wallet", "cash" to "Tunai"),
                selected = type,
                onSelect = { type = it },
            )
        }
        AmountField(
            value = balance,
            onValueChange = { balance = it },
            label = "Saldo awal",
            currency = currency,
            supporting = "Boleh dikosongkan kalau masih nol",
        )
        PrimaryAction(text = "Simpan", enabled = name.isNotBlank()) {
            haptic.performHapticFeedback(HapticFeedbackType.Confirm)
            close {
                vm.addWallet(
                    name = name.trim(),
                    type = type,
                    initialBalance = AppCurrency.parseInputToIdr(balance.text, currency),
                    colorHex = "#C2A878",
                    iconName = "wallet",
                )
                onSaved("Rekening tersimpan")
            }
        }
    }
}
