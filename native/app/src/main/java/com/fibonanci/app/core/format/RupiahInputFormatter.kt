package com.fibonanci.app.core.format

import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue

/**
 * dynamic real-time thousands separator formatter for idr amounts.
 * automatically formats user input (e.g. "100000" -> "100.000", "1500000" -> "1.500.000").
 */
object RupiahInputFormatter {
    private val nonDigit = Regex("[^\\d]")

    /** use as `onValueChange = { value = RupiahInputFormatter.formatEditUpdate(value, it) }`. */
    fun formatEditUpdate(old: TextFieldValue, new: TextFieldValue): TextFieldValue {
        if (new.text.isEmpty()) return new.copy(text = "")

        // strip everything except digits
        val cleanDigits = new.text.replace(nonDigit, "")
        if (cleanDigits.isEmpty()) return TextFieldValue(text = "", selection = TextRange(0))

        val number = cleanDigits.toLongOrNull() ?: return old
        val formatted = groupDigits(number)
        return TextFieldValue(text = formatted, selection = TextRange(formatted.length))
    }

    /** extracts numeric double from formatted text (e.g. "100.000" -> 100000.0) */
    fun parse(formattedText: String): Double {
        val clean = formattedText.replace(nonDigit, "")
        return clean.toDoubleOrNull() ?: 0.0
    }

    /** formats raw numeric value into thousands separated string (e.g. 100000 -> "100.000") */
    fun format(value: Double): String = groupDigits(value.toLong())

    // id_ID decimal pattern grouping: dot thousands separator, leading minus
    internal fun groupDigits(value: Long): String {
        val digits = if (value < 0) value.toString().substring(1) else value.toString()
        val sb = StringBuilder()
        digits.forEachIndexed { i, c ->
            if (i > 0 && (digits.length - i) % 3 == 0) sb.append('.')
            sb.append(c)
        }
        return if (value < 0) "-$sb" else sb.toString()
    }
}
