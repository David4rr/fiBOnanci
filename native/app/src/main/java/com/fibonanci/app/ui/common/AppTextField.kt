package com.fibonanci.app.ui.common

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

// flutter ColorScheme.dark() error color, used by InputDecoration.errorText
internal val inputErrorColor = Color(0xFFCF6679)

@Composable
fun AppTextField(
    value: String,
    onValueChange: (String) -> Unit,
    hintText: String,
    hintStyle: TextStyle? = null,
    style: TextStyle? = null,
    prefixIcon: (@Composable () -> Unit)? = null,
    suffixIcon: (@Composable () -> Unit)? = null,
    keyboardType: KeyboardType? = null,
    textCapitalization: KeyboardCapitalization = KeyboardCapitalization.None,
    onChanged: ((String) -> Unit)? = null,
    maxLines: Int = 1,
    autofocus: Boolean = false,
    borderRadius: Dp = 16.dp,
    fillColor: Color = AppColors.canvasInputSearch,
    errorText: String? = null,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    val focusRequester = remember { FocusRequester() }
    if (autofocus) LaunchedEffect(Unit) { focusRequester.requestFocus() }

    BasicTextField(
        value = value,
        onValueChange = {
            if (it != value) {
                onValueChange(it)
                onChanged?.invoke(it)
            }
        },
        modifier = modifier.fillMaxWidth().focusRequester(focusRequester),
        textStyle = style ?: AppTypography.listTitle,
        keyboardOptions = KeyboardOptions(
            capitalization = textCapitalization,
            keyboardType = keyboardType ?: KeyboardType.Text,
        ),
        singleLine = maxLines == 1,
        maxLines = maxLines,
        cursorBrush = SolidColor(AppColors.neoChartreuse),
        interactionSource = interaction,
        decorationBox = { inner ->
            AppInputDecoration(
                innerTextField = inner,
                isEmpty = value.isEmpty(),
                isFocused = focused,
                hintText = hintText,
                hintStyle = hintStyle ?: AppTypography.listSubtitle,
                labelText = null,
                labelStyle = null,
                prefixText = null,
                prefixStyle = null,
                prefixIcon = prefixIcon,
                suffixIcon = suffixIcon,
                errorText = errorText,
                fillColor = fillColor,
                borderRadius = borderRadius,
                singleLine = maxLines == 1,
            )
        },
    )
}

/**
 * filled InputDecoration with a borderless OutlineInputBorder: 12/16 content padding,
 * 48dp icon slots, outline-style floating label, prefix text and error line.
 */
@Composable
internal fun AppInputDecoration(
    innerTextField: @Composable () -> Unit,
    isEmpty: Boolean,
    isFocused: Boolean,
    hintText: String?,
    hintStyle: TextStyle,
    labelText: String?,
    labelStyle: TextStyle?,
    prefixText: String?,
    prefixStyle: TextStyle?,
    prefixIcon: (@Composable () -> Unit)?,
    suffixIcon: (@Composable () -> Unit)?,
    errorText: String?,
    fillColor: Color,
    borderRadius: Dp,
    singleLine: Boolean,
) {
    val floating = isFocused || !isEmpty
    val inlineLabel = labelText != null && !floating
    val labelProgress by animateFloatAsState(
        targetValue = if (floating) 1f else 0f,
        animationSpec = tween(167, easing = FastOutSlowInEasing),
        label = "inputLabel",
    )
    var boxHeight by remember { mutableIntStateOf(0) }
    val density = LocalDensity.current
    val inputStart = if (prefixIcon != null) 48.dp else 12.dp

    Column {
        Box(Modifier.onSizeChanged { boxHeight = it.height }) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .background(fillColor, RoundedCornerShape(borderRadius))
                    .heightIn(min = 48.dp),
                verticalAlignment = if (singleLine) Alignment.CenterVertically else Alignment.Top,
            ) {
                if (prefixIcon != null) {
                    Box(Modifier.size(48.dp), contentAlignment = Alignment.Center) {
                        CompositionLocalProvider(LocalContentColor provides Color.White) { prefixIcon() }
                    }
                }
                Row(
                    Modifier
                        .weight(1f)
                        .padding(
                            start = if (prefixIcon != null) 0.dp else 12.dp,
                            end = if (suffixIcon != null) 0.dp else 12.dp,
                            top = 16.dp,
                            bottom = 16.dp,
                        ),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    // prefix is hidden while the label sits inline
                    if (prefixText != null) {
                        Text(
                            prefixText,
                            style = prefixStyle ?: hintStyle,
                            modifier = Modifier.graphicsLayer { alpha = if (inlineLabel) 0f else 1f },
                        )
                    }
                    Box(Modifier.weight(1f)) {
                        if (hintText != null && isEmpty && !inlineLabel) {
                            Text(hintText, style = hintStyle, maxLines = if (singleLine) 1 else Int.MAX_VALUE)
                        }
                        innerTextField()
                    }
                }
                if (suffixIcon != null) {
                    Box(Modifier.size(48.dp), contentAlignment = Alignment.Center) {
                        CompositionLocalProvider(LocalContentColor provides Color.White) { suffixIcon() }
                    }
                }
            }
            if (labelText != null) {
                // outline label: inline in the input slot, floats onto the top edge at 75% scale
                Box(Modifier.matchParentSize(), contentAlignment = Alignment.CenterStart) {
                    Text(
                        labelText,
                        style = labelStyle ?: hintStyle,
                        maxLines = 1,
                        modifier = Modifier
                            .padding(start = inputStart)
                            .graphicsLayer {
                                transformOrigin = TransformOrigin(0f, 0.5f)
                                val scale = 1f - 0.25f * labelProgress
                                scaleX = scale
                                scaleY = scale
                                translationY = -(boxHeight / 2f) * labelProgress
                                translationX = with(density) { (12.dp - inputStart).toPx() } * labelProgress
                            },
                    )
                }
            }
        }
        if (errorText != null) {
            Text(
                errorText,
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, color = inputErrorColor),
                modifier = Modifier.padding(start = 12.dp, end = 12.dp, top = 4.dp),
            )
        }
    }
}
