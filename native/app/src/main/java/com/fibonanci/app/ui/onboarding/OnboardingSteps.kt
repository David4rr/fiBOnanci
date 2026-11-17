package com.fibonanci.app.ui.onboarding

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccountBalance
import androidx.compose.material.icons.rounded.AccountBalanceWallet
import androidx.compose.material.icons.rounded.AlternateEmail
import androidx.compose.material.icons.rounded.CalendarToday
import androidx.compose.material.icons.rounded.Payments
import androidx.compose.material.icons.rounded.Person
import androidx.compose.material.icons.rounded.Savings
import androidx.compose.material.icons.rounded.Smartphone
import androidx.compose.material.icons.rounded.WavingHand
import androidx.compose.material.icons.rounded.Work
import androidx.compose.material3.ButtonGroupDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialShapes
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SuggestionChip
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.ToggleButton
import androidx.compose.material3.ToggleButtonDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.format.AppCurrency

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun NameStep(form: OnboardingForm, onAdvance: () -> Unit) {
    val focus = rememberAutoFocus()
    StepHeader(
        shape = MaterialShapes.Cookie9Sided,
        icon = Icons.Rounded.WavingHand,
        question = "Halo! Siapa namamu?",
        helper = "Kami pakai untuk menyapamu di aplikasi.",
    )
    OutlinedTextField(
        value = form.fullName,
        onValueChange = form::updateFullName,
        modifier = Modifier.fillMaxWidth().focusRequester(focus),
        label = { Text("Nama lengkap") },
        leadingIcon = { Icon(Icons.Rounded.Person, contentDescription = null) },
        supportingText = { Text("Wajib diisi") },
        keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Next),
        keyboardActions = KeyboardActions(onNext = { onAdvance() }),
        singleLine = true,
        shape = MaterialTheme.shapes.large,
    )
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun UsernameStep(form: OnboardingForm, onAdvance: () -> Unit) {
    val focus = rememberAutoFocus()
    val occupationFocus = remember { FocusRequester() }
    StepHeader(
        shape = MaterialShapes.Flower,
        icon = Icons.Rounded.AlternateEmail,
        question = "Senang kenal, ${form.firstName}.",
        helper = "Pilih username untuk profilmu. Pekerjaan boleh dikosongkan.",
    )
    OutlinedTextField(
        value = form.username,
        onValueChange = form::updateUsername,
        modifier = Modifier.fillMaxWidth().focusRequester(focus),
        label = { Text("Username") },
        leadingIcon = { Icon(Icons.Rounded.AlternateEmail, contentDescription = null) },
        prefix = { Text("@") },
        supportingText = { Text("Huruf kecil a–z, angka 0–9 dan garis bawah _") },
        keyboardOptions = KeyboardOptions(
            capitalization = KeyboardCapitalization.None,
            autoCorrectEnabled = false,
            keyboardType = KeyboardType.Ascii,
            imeAction = ImeAction.Next,
        ),
        keyboardActions = KeyboardActions(onNext = { occupationFocus.requestFocus() }),
        singleLine = true,
        shape = MaterialTheme.shapes.large,
    )
    Spacer(Modifier.height(8.dp))
    OutlinedTextField(
        value = form.occupation,
        onValueChange = { form.occupation = it },
        modifier = Modifier.fillMaxWidth().focusRequester(occupationFocus),
        label = { Text("Pekerjaan (opsional)") },
        leadingIcon = { Icon(Icons.Rounded.Work, contentDescription = null) },
        supportingText = { Text("Misalnya mahasiswa atau desainer") },
        keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences, imeAction = ImeAction.Next),
        keyboardActions = KeyboardActions(onNext = { onAdvance() }),
        singleLine = true,
        shape = MaterialTheme.shapes.large,
    )
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun IncomeStep(form: OnboardingForm, currency: String, onAdvance: () -> Unit) {
    val focus = rememberAutoFocus()
    val motion = MaterialTheme.motionScheme
    val monthly = form.incomeIdr(currency)
    StepHeader(
        shape = MaterialShapes.Pill,
        icon = Icons.Rounded.Payments,
        question = "Berapa pemasukanmu per bulan?",
        helper = "Gaji, uang saku, atau rata-rata penghasilan. Bisa diubah nanti.",
    )
    AmountField(
        value = form.income,
        onValueChange = form::updateIncome,
        label = "Pemasukan bulanan",
        supportingText = "Perkiraan saja sudah cukup",
        currency = currency,
        onImeAction = onAdvance,
        modifier = Modifier.focusRequester(focus),
        large = true,
    )
    AnimatedVisibility(
        visible = monthly > 0,
        enter = fadeIn(motion.defaultEffectsSpec()) + expandVertically(motion.defaultSpatialSpec()),
        exit = fadeOut(motion.defaultEffectsSpec()) + shrinkVertically(motion.defaultSpatialSpec()),
    ) {
        Surface(
            modifier = Modifier.padding(top = 16.dp),
            shape = MaterialTheme.shapes.small,
            color = MaterialTheme.colorScheme.secondaryContainer,
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Rounded.CalendarToday, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "≈ ${AppCurrency.format(monthly / 30, currency)} per hari",
                    style = MaterialTheme.typography.labelLarge,
                )
            }
        }
    }
}

private data class WalletSuggestion(val name: String, val type: String)

private val walletSuggestions = listOf(
    WalletSuggestion("BCA", "bank"),
    WalletSuggestion("Mandiri", "bank"),
    WalletSuggestion("BRI", "bank"),
    WalletSuggestion("BNI", "bank"),
    WalletSuggestion("Jago", "bank"),
    WalletSuggestion("SeaBank", "bank"),
    WalletSuggestion("GoPay", "ewallet"),
    WalletSuggestion("OVO", "ewallet"),
    WalletSuggestion("DANA", "ewallet"),
    WalletSuggestion("Tunai", "cash"),
)

private data class WalletTypeOption(val type: String, val label: String, val icon: ImageVector)

private val walletTypes = listOf(
    WalletTypeOption("bank", "Bank", Icons.Rounded.AccountBalance),
    WalletTypeOption("ewallet", "E-wallet", Icons.Rounded.Smartphone),
    WalletTypeOption("cash", "Tunai", Icons.Rounded.Payments),
)

@OptIn(ExperimentalMaterial3ExpressiveApi::class, ExperimentalLayoutApi::class)
@Composable
fun WalletStep(form: OnboardingForm, currency: String, onAdvance: () -> Unit) {
    val focus = rememberAutoFocus()
    val balanceFocus = remember { FocusRequester() }
    val haptic = LocalHapticFeedback.current
    StepHeader(
        shape = MaterialShapes.Clover4Leaf,
        icon = Icons.Rounded.AccountBalanceWallet,
        question = "Di mana uangmu sekarang?",
        helper = "Tambahkan rekening pertamamu. Yang lain bisa menyusul.",
    )
    OutlinedTextField(
        value = form.walletName,
        onValueChange = { form.walletName = it },
        modifier = Modifier.fillMaxWidth().focusRequester(focus),
        label = { Text("Nama rekening") },
        leadingIcon = { Icon(Icons.Rounded.AccountBalanceWallet, contentDescription = null) },
        supportingText = { Text("Wajib diisi, atau pilih di bawah") },
        keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Next),
        keyboardActions = KeyboardActions(onNext = { balanceFocus.requestFocus() }),
        singleLine = true,
        shape = MaterialTheme.shapes.large,
    )
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        walletSuggestions.forEach { suggestion ->
            SuggestionChip(
                onClick = {
                    haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                    form.pickWallet(suggestion.name, suggestion.type)
                },
                label = { Text(suggestion.name) },
            )
        }
    }
    Spacer(Modifier.height(16.dp))
    Text(
        text = "Jenis rekening",
        style = MaterialTheme.typography.labelLarge,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
    )
    Spacer(Modifier.height(8.dp))
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(ButtonGroupDefaults.ConnectedSpaceBetween),
    ) {
        walletTypes.forEachIndexed { index, option ->
            ToggleButton(
                checked = form.walletType == option.type,
                onCheckedChange = {
                    haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                    form.walletType = option.type
                },
                modifier = Modifier.weight(1f).semantics { role = Role.RadioButton },
                shapes = when (index) {
                    0 -> ButtonGroupDefaults.connectedLeadingButtonShapes()
                    walletTypes.lastIndex -> ButtonGroupDefaults.connectedTrailingButtonShapes()
                    else -> ButtonGroupDefaults.connectedMiddleButtonShapes()
                },
            ) {
                Icon(option.icon, contentDescription = null, modifier = Modifier.size(ToggleButtonDefaults.IconSize))
                Spacer(Modifier.width(ToggleButtonDefaults.IconSpacing))
                Text(option.label, maxLines = 1)
            }
        }
    }
    Spacer(Modifier.height(24.dp))
    AmountField(
        value = form.balance,
        onValueChange = form::updateBalance,
        label = "Saldo saat ini",
        supportingText = "Kosongkan kalau belum tahu",
        currency = currency,
        onImeAction = onAdvance,
        modifier = Modifier.focusRequester(balanceFocus),
        leadingIcon = Icons.Rounded.Savings,
    )
}
