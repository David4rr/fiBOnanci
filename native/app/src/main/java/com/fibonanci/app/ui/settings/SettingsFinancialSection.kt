package com.fibonanci.app.ui.settings

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Sync
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun SettingsFinancialSection(state: FinanceState, onNavigate: (SettingsSubRoute) -> Unit) {
    val profile = state.profile
    val target = profile.monthlyIncomeTarget
    val hasTarget = target != null && target > 0
    Column {
        SettingsStyle.sectionHeader("PENGATURAN PROFIL • @${profile.username.uppercase()}")
        Spacer(Modifier.height(6.dp))
        SettingsStyle.menuRow(
            key = "settings_currency_menu_row", title = "Mata Uang Utama",
            valueText = profile.currency, onTap = { onNavigate(SettingsSubRoute.currency) },
        )
        SettingsStyle.menuRow(
            key = "settings_income_target_row", title = "Target Pemasukan Bulanan",
            valueText = if (hasTarget) AppCurrency.format(target!!, profile.currency) else "Atur",
            onTap = { onNavigate(SettingsSubRoute.incomeTarget) },
        )
    }
}

private val currencies = listOf(
    "IDR" to "Rupiah Indonesia (Rp)", "USD" to "US Dollar ($)", "EUR" to "Euro (€)",
    "SGD" to "Singapore Dollar (S$)", "MYR" to "Malaysian Ringgit (RM)", "JPY" to "Japanese Yen (¥)",
)

@Composable
fun SettingsCurrencySubPage(state: FinanceState) {
    val vm = LocalFinance.current
    var editingRate by rememberSaveable { mutableStateOf(false) }
    var rateCtrl by rememberSaveable(stateSaver = TextFieldValue.Saver) {
        mutableStateOf(textValue(RupiahInputFormatter.format(AppCurrency.rateFor(state.profile.currency))))
    }

    fun selectCurrency(code: String) {
        val p = state.profile
        if (p.currency == code) return
        editingRate = false
        vm.updateProfile(
            profileId = p.id, username = p.username, fullName = p.fullName, email = p.email, phone = p.phone,
            avatarPath = p.avatarPath, occupation = p.occupation, bio = p.bio, currency = code, monthlyIncomeTarget = p.monthlyIncomeTarget,
        )
    }

    fun saveRate() {
        val parsed = RupiahInputFormatter.parse(rateCtrl.text.trim())
        if (parsed > 0) vm.setExchangeRate(state.profile.currency, parsed)
        editingRate = false
    }

    val code = state.profile.currency
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp)) {
        item { SettingsStyle.sectionHeader("PILIH MATA UANG") }
        item { Spacer(Modifier.height(6.dp)) }
        items(currencies.size) { i ->
            val (c, label) = currencies[i]
            SettingsStyle.optionRow(key = "settings_currency_$c", title = "$c — $label", selected = code == c, onTap = { selectCurrency(c) })
        }
        if (code != "IDR") {
            item { Spacer(Modifier.height(24.dp)) }
            item { SettingsStyle.sectionHeader("KURS KONVERSI (1 $code KE IDR)") }
            item { Spacer(Modifier.height(6.dp)) }
            item {
                SettingsStyle.menuRow(
                    key = "settings_exchange_rate_row", title = "Kurs 1 $code",
                    valueText = "Rp ${RupiahInputFormatter.format(AppCurrency.rateFor(code))}",
                    trailingAction = {
                        Icon(
                            Icons.Rounded.Sync, contentDescription = null,
                            tint = if (AppCurrency.isLiveRate) AppColors.neoMint else AppColors.textMuted,
                            modifier = Modifier.testTag("settings_sync_rate_button").plainClickable { vm.syncExchangeRates() }.size(16.dp),
                        )
                    },
                    onTap = {
                        editingRate = !editingRate
                        if (editingRate) rateCtrl = textValue(RupiahInputFormatter.format(AppCurrency.rateFor(code)))
                    },
                )
            }
            if (editingRate) {
                item {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        SettingsUnderlineField(
                            value = rateCtrl, onValueChange = { rateCtrl = it }, textStyle = SettingsStyle.title,
                            prefixText = "Rp ", hintText = "16.000", hintStyle = SettingsStyle.sub,
                            numberKeyboard = true, rupiahFormat = true,
                            modifier = Modifier.weight(1f).testTag("settings_exchange_rate_input"),
                        )
                        Spacer(Modifier.width(12.dp))
                        Text("Simpan", style = SettingsStyle.accent, modifier = Modifier.testTag("settings_exchange_rate_save").plainClickable { saveRate() })
                    }
                }
            }
        }
    }
}

@Composable
fun SettingsIncomeTargetSubPage(state: FinanceState, onSaved: () -> Unit) {
    val vm = LocalFinance.current
    var ctrl by rememberSaveable(stateSaver = TextFieldValue.Saver) {
        val p = state.profile
        val t = p.monthlyIncomeTarget
        mutableStateOf(textValue(if (t != null && t > 0) AppCurrency.formatIdrForInput(t, p.currency) else ""))
    }

    fun save() {
        val p = state.profile
        val parsedIdr = AppCurrency.parseInputToIdr(ctrl.text.trim(), p.currency)
        vm.updateProfile(
            profileId = p.id, username = p.username, fullName = p.fullName, email = p.email, phone = p.phone,
            avatarPath = p.avatarPath, occupation = p.occupation, bio = p.bio, currency = p.currency,
            monthlyIncomeTarget = if (parsedIdr > 0) parsedIdr else null,
        )
        onSaved()
    }

    val c = state.profile.currency
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp)) {
        item { SettingsStyle.sectionHeader("NOMINAL TARGET BULANAN ($c)") }
        item { Spacer(Modifier.height(12.dp)) }
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                SettingsUnderlineField(
                    value = ctrl, onValueChange = { ctrl = it },
                    textStyle = TextStyle(fontFamily = PlusJakartaSans, fontSize = 18.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite),
                    prefixText = AppCurrency.symbolFor(c), prefixStyle = SettingsStyle.value, hintText = "0", hintStyle = SettingsStyle.sub,
                    numberKeyboard = true, rupiahFormat = true, autofocus = true, enabledBorderAlpha = 0.15f,
                    contentPadding = PaddingValues(vertical = 12.dp),
                    modifier = Modifier.weight(1f).testTag("settings_income_target_input"),
                )
                Spacer(Modifier.width(14.dp))
                Text("Simpan", style = SettingsStyle.accent, modifier = Modifier.testTag("settings_income_target_save").plainClickable { save() })
            }
        }
    }
}
