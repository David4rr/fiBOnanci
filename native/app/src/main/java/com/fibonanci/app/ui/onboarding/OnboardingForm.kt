package com.fibonanci.app.ui.onboarding

import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableIntState
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.ui.UiStyle

const val ONBOARDING_STEPS = 5

// everything the user typed during onboarding; every piece survives rotation and process death.
class OnboardingForm(
    step: MutableIntState,
    fullName: MutableState<TextFieldValue>,
    username: MutableState<TextFieldValue>,
    usernameEdited: MutableState<Boolean>,
    occupation: MutableState<TextFieldValue>,
    income: MutableState<TextFieldValue>,
    walletName: MutableState<TextFieldValue>,
    walletType: MutableState<String>,
    balance: MutableState<TextFieldValue>,
    style: MutableState<UiStyle>,
    saving: MutableState<Boolean>,
    errorBeforeSave: MutableState<String?>,
) {
    var step by step
    var fullName by fullName
        private set
    var username by username
        private set
    private var usernameEdited by usernameEdited
    var occupation by occupation
    var income by income
        private set
    var walletName by walletName
    var walletType by walletType
    var balance by balance
        private set
    var style by style
    var saving by saving
    // the error already on screen when saving started, so only a new one stops the spinner
    var errorBeforeSave by errorBeforeSave

    val firstName: String
        get() = fullName.text.trim().substringBefore(' ')

    fun updateFullName(value: TextFieldValue) {
        fullName = value
        if (!usernameEdited) {
            val suggestion = sanitizeUsername(value.text.trim().replace(whitespace, "_"))
            username = TextFieldValue(suggestion, TextRange(suggestion.length))
        }
    }

    fun updateUsername(value: TextFieldValue) {
        usernameEdited = true
        val clean = sanitizeUsername(value.text)
        // keep the cursor where it was, minus the characters that were thrown away before it
        val cursor = sanitizeUsername(value.text.take(value.selection.end)).length
        username = TextFieldValue(clean, TextRange(cursor), value.composition?.takeIf { clean == value.text })
    }

    fun updateIncome(value: TextFieldValue) {
        income = RupiahInputFormatter.formatEditUpdate(income, value)
    }

    fun clearIncome() {
        income = TextFieldValue()
    }

    fun updateBalance(value: TextFieldValue) {
        balance = RupiahInputFormatter.formatEditUpdate(balance, value)
    }

    fun pickWallet(name: String, type: String) {
        walletName = TextFieldValue(name, TextRange(name.length))
        walletType = type
    }

    fun incomeIdr(currency: String): Double = AppCurrency.parseInputToIdr(income.text, currency)

    fun balanceIdr(currency: String): Double = AppCurrency.parseInputToIdr(balance.text, currency)

    fun isStepValid(currency: String): Boolean = when (step) {
        1 -> fullName.text.isNotBlank()
        2 -> username.text.isNotEmpty()
        3 -> incomeIdr(currency) > 0
        4 -> walletName.text.isNotBlank()
        else -> true
    }

    private companion object {
        val whitespace = Regex("\\s+")
        val notAllowed = Regex("[^a-z0-9_]")

        fun sanitizeUsername(text: String): String = text.lowercase().replace(notAllowed, "")
    }
}

@Composable
fun rememberOnboardingForm(): OnboardingForm {
    val step = rememberSaveable { mutableIntStateOf(1) }
    val fullName = rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue()) }
    val username = rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue()) }
    val usernameEdited = rememberSaveable { mutableStateOf(false) }
    val occupation = rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue()) }
    val income = rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue()) }
    val walletName = rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue()) }
    val walletType = rememberSaveable { mutableStateOf("bank") }
    val balance = rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(TextFieldValue()) }
    val style = rememberSaveable { mutableStateOf(UiStyle.iblameraihan) }
    val saving = rememberSaveable { mutableStateOf(false) }
    val errorBeforeSave = rememberSaveable { mutableStateOf<String?>(null) }
    return remember {
        OnboardingForm(
            step, fullName, username, usernameEdited, occupation, income,
            walletName, walletType, balance, style, saving, errorBeforeSave,
        )
    }
}
