@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SegmentedListItem
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.UiStyle

@Composable
fun SettingsSheet(state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    val profile = state.profile
    var name by remember { mutableStateOf(profile.fullName) }
    var target by remember {
        mutableStateOf(TextFieldValue(profile.monthlyIncomeTarget?.let { AppCurrency.formatIdrForInput(it, profile.currency) } ?: ""))
    }
    val targetValue = target.text.takeIf { it.isNotBlank() }?.let { AppCurrency.parseInputToIdr(it, profile.currency) }
    val changed = name.trim() != profile.fullName || targetValue != profile.monthlyIncomeTarget

    SimpleSheet(title = "Pengaturan", onDismiss = onDismiss) { close ->
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("Tampilan", style = MaterialTheme.typography.titleSmall)
            ConnectedChoice(
                options = listOf(UiStyle.iblameraihan to "Sederhana", UiStyle.david4rr to "Lengkap"),
                selected = UiStyle.iblameraihan,
                onSelect = { style ->
                    if (style != UiStyle.iblameraihan) close { vm.setUiStyle(style) }
                },
            )
            Text(
                "Kantong, inbox notifikasi, dan laporan ada di tampilan Lengkap.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        SegmentedListItem(
            checked = state.isBalanceHidden,
            onCheckedChange = { hidden ->
                haptic.performHapticFeedback(if (hidden) HapticFeedbackType.ToggleOn else HapticFeedbackType.ToggleOff)
                vm.toggleBalanceVisibility(hidden)
            },
            shapes = groupShapes(0, 1),
            colors = groupColors(MaterialTheme.colorScheme.surfaceContainerHigh),
            supportingContent = { Text("Nominal tampil sebagai ••••••") },
            trailingContent = { Switch(checked = state.isBalanceHidden, onCheckedChange = null) },
        ) {
            Text("Sembunyikan saldo")
        }
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Nama") },
            isError = name.isBlank(),
            supportingText = if (name.isBlank()) ({ Text("Nama wajib diisi") }) else null,
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Next),
        )
        AmountField(
            value = target,
            onValueChange = { target = it },
            label = "Target pemasukan per bulan",
            currency = profile.currency,
            supporting = "Kosongkan kalau belum punya target",
        )
        PrimaryAction(text = "Simpan", enabled = changed && name.isNotBlank()) {
            haptic.performHapticFeedback(HapticFeedbackType.Confirm)
            close {
                vm.updateProfile(
                    profileId = profile.id,
                    username = profile.username,
                    fullName = name.trim(),
                    email = profile.email,
                    phone = profile.phone,
                    avatarPath = profile.avatarPath,
                    occupation = profile.occupation,
                    bio = profile.bio,
                    currency = profile.currency,
                    monthlyIncomeTarget = targetValue,
                )
                onSaved("Profil tersimpan")
            }
        }
    }
}
