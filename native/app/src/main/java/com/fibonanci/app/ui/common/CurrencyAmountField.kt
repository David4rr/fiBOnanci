package com.fibonanci.app.ui.common

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

/** amount input with the active currency symbol as prefix and live thousands grouping. */
@Composable
fun CurrencyAmountField(
    value: String,
    onValueChange: (String) -> Unit,
    prefixColor: Color? = null,
    autofocus: Boolean = false,
    focusNode: FocusRequester? = null,
    onChanged: ((String) -> Unit)? = null,
    style: TextStyle? = null,
    prefixStyle: TextStyle? = null,
    borderRadius: Dp = 16.dp,
    fillColor: Color = AppColors.canvasInputSearch,
    labelText: String? = null,
    hintText: String? = null,
    labelStyle: TextStyle? = null,
    errorText: String? = null,
    modifier: Modifier = Modifier,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val symbol = AppCurrency.symbolFor(state.profile.currency)

    val effectivePrefixColor = prefixColor ?: AppColors.neoChartreuse
    val effectiveStyle = style ?: AppTypography.heroGreeting.copy(color = AppColors.textWhite)
    val effectivePrefixStyle = prefixStyle ?: AppTypography.heroGreeting.copy(color = effectivePrefixColor)
    // m3 inline hint: input style merged with bodyLarge in onSurfaceVariant
    val hintStyle = effectiveStyle.merge(
        MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.onSurfaceVariant),
    )

    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    val fallbackRequester = remember { FocusRequester() }
    val requester = focusNode ?: fallbackRequester
    if (autofocus) LaunchedEffect(Unit) { requester.requestFocus() }

    // selection is kept locally; the formatter always parks the cursor at the end after an edit
    var local by remember { mutableStateOf(TextFieldValue(value, TextRange(value.length))) }
    val shown = if (local.text == value) local else TextFieldValue(value, TextRange(value.length))

    BasicTextField(
        value = shown,
        onValueChange = { next ->
            if (next.text == shown.text) {
                local = next
            } else {
                val formatted = RupiahInputFormatter.formatEditUpdate(shown, next)
                local = formatted
                if (formatted.text != shown.text) {
                    onValueChange(formatted.text)
                    onChanged?.invoke(formatted.text)
                }
            }
        },
        modifier = modifier.fillMaxWidth().focusRequester(requester),
        textStyle = effectiveStyle,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        singleLine = true,
        cursorBrush = SolidColor(AppColors.neoChartreuse),
        interactionSource = interaction,
        decorationBox = { inner ->
            AppInputDecoration(
                innerTextField = inner,
                isEmpty = shown.text.isEmpty(),
                isFocused = focused,
                hintText = hintText,
                hintStyle = hintStyle,
                labelText = labelText,
                labelStyle = labelStyle ?: if (labelText != null) AppTypography.listSubtitle else null,
                prefixText = symbol,
                prefixStyle = effectivePrefixStyle,
                prefixIcon = null,
                suffixIcon = null,
                errorText = errorText,
                fillColor = fillColor,
                borderRadius = borderRadius,
                singleLine = true,
            )
        },
    )
}
