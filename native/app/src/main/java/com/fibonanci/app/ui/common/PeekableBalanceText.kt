package com.fibonanci.app.ui.common

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Visibility
import androidx.compose.material.icons.outlined.VisibilityOff
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.isSpecified
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.ui.LocalFinance

object PeekableBalanceText {
    fun mask(input: String): String {
        if (input.contains('•')) return input
        val prefix = Regex("^[^\\d]+").find(input)?.value ?: ""
        return "$prefix•••••••"
    }
}

/**
 * formatted currency balance that masks itself while privacy mode (isBalanceHidden)
 * is active, with an inline eye button to peek at this single value.
 */
@Composable
fun PeekableBalanceText(
    text: String,
    style: TextStyle,
    maskedText: String? = null,
    isHidden: Boolean? = null,
    iconColor: Color? = null,
    iconSize: Dp? = null,
    textAlign: TextAlign? = null,
    mainAxisAlignment: Arrangement.Horizontal = Arrangement.Start,
    modifier: Modifier = Modifier,
) {
    val hidden = isHidden ?: run {
        val state by LocalFinance.current.state.collectAsStateWithLifecycle()
        state.isBalanceHidden
    }
    var peeking by remember { mutableStateOf(false) }
    LaunchedEffect(hidden) { if (!hidden) peeking = false }

    if (!hidden) {
        Text(
            text,
            modifier = modifier,
            style = style,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = textAlign,
        )
        return
    }

    val display = if (peeking) text else maskedText ?: PeekableBalanceText.mask(text)
    val baseFontSize = if (style.fontSize.isSp) style.fontSize.value else 16f
    val effectiveSize = iconSize ?: (baseFontSize * 0.78f).coerceIn(13f, 18f).dp
    val effectiveColor = iconColor
        ?: (if (style.color.isSpecified) style.color else Color.White).copy(alpha = 0.72f)

    Row(
        modifier,
        horizontalArrangement = mainAxisAlignment,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            display,
            modifier = Modifier.weight(1f, fill = false),
            style = style,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = textAlign,
        )
        Spacer(Modifier.width(6.dp))
        Icon(
            if (peeking) Icons.Outlined.VisibilityOff else Icons.Outlined.Visibility,
            contentDescription = null,
            tint = effectiveColor,
            modifier = Modifier
                .clickable(interactionSource = null, indication = null) { peeking = !peeking }
                .padding(2.dp)
                .size(effectiveSize),
        )
    }
}
