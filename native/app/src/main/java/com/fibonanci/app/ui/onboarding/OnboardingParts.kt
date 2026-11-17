package com.fibonanci.app.ui.onboarding

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.toShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.graphics.shapes.RoundedPolygon
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.simple.AtelierFonts
import kotlinx.coroutines.launch

// the hero shape springs in, then keeps turning slowly so the step feels alive.
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun StepHero(shape: RoundedPolygon, icon: ImageVector) {
    val spatial = MaterialTheme.motionScheme.defaultSpatialSpec<Float>()
    val entryScale = remember { Animatable(0.4f) }
    val entryRotation = remember { Animatable(-90f) }
    LaunchedEffect(Unit) {
        launch { entryScale.animateTo(1f, spatial) }
        entryRotation.animateTo(0f, spatial)
    }
    val spin by rememberInfiniteTransition(label = "hero").animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(durationMillis = 20_000, easing = LinearEasing), RepeatMode.Restart),
        label = "hero spin",
    )
    Box(
        modifier = Modifier
            .size(96.dp)
            .graphicsLayer {
                scaleX = entryScale.value
                scaleY = entryScale.value
            },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .fillMaxSize()
                .graphicsLayer { rotationZ = entryRotation.value + spin }
                .background(MaterialTheme.colorScheme.primaryContainer, shape.toShape()),
        )
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onPrimaryContainer,
            modifier = Modifier.size(40.dp),
        )
    }
}

// hero, question and helper line that open every step.
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun StepHeader(shape: RoundedPolygon, icon: ImageVector, question: String, helper: String) {
    Column(Modifier.fillMaxWidth()) {
        StepHero(shape, icon)
        Spacer(Modifier.height(32.dp))
        Text(text = question, style = MaterialTheme.typography.displaySmallEmphasized)
        Spacer(Modifier.height(12.dp))
        Text(
            text = helper,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(Modifier.height(32.dp))
    }
}

// focuses the step's first field and brings the keyboard up as soon as the step appears.
@Composable
fun rememberAutoFocus(): FocusRequester {
    val requester = remember { FocusRequester() }
    val keyboard = LocalSoftwareKeyboardController.current
    LaunchedEffect(Unit) {
        requester.requestFocus()
        keyboard?.show()
    }
    return requester
}

// money input with live thousands grouping; big mono digits for the hero amount, regular otherwise.
@Composable
fun AmountField(
    value: TextFieldValue,
    onValueChange: (TextFieldValue) -> Unit,
    label: String,
    supportingText: String,
    currency: String,
    onImeAction: () -> Unit,
    modifier: Modifier = Modifier,
    large: Boolean = false,
    leadingIcon: ImageVector? = null,
) {
    val base = if (large) MaterialTheme.typography.displaySmall else MaterialTheme.typography.bodyLarge
    val textStyle = base.copy(fontFamily = AtelierFonts.mono, fontFeatureSettings = "tnum")
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier.fillMaxWidth(),
        textStyle = textStyle,
        label = { Text(label) },
        placeholder = { Text("0", style = textStyle) },
        leadingIcon = leadingIcon?.let { { Icon(it, contentDescription = null) } },
        prefix = {
            Text(
                text = AppCurrency.symbolFor(currency),
                style = textStyle,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        },
        supportingText = { Text(supportingText) },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = ImeAction.Next),
        keyboardActions = KeyboardActions(onNext = { onImeAction() }),
        singleLine = true,
        shape = MaterialTheme.shapes.large,
    )
}
