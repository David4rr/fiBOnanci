package com.fibonanci.app.ui.onboarding

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.expandHorizontally
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkHorizontally
import androidx.compose.animation.shrinkVertically
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.automirrored.rounded.ArrowForward
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.LinearWavyProgressIndicator
import androidx.compose.material3.LoadingIndicator
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.ui.LocalFinance

// first run: five short questions, then the profile, first wallet and look are saved in one go.
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun OnboardingScreen() {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val form = rememberOnboardingForm()
    val haptic = LocalHapticFeedback.current
    val snackbar = remember { SnackbarHostState() }
    val currency = state.profile.currency

    fun advance() {
        if (form.saving || !form.isStepValid(currency)) return
        haptic.performHapticFeedback(HapticFeedbackType.Confirm)
        if (form.step < ONBOARDING_STEPS) {
            form.step++
            return
        }
        vm.clearError()
        form.errorBeforeSave = null
        form.saving = true
        vm.completeOnboarding(
            fullName = form.fullName.text.trim(),
            username = form.username.text,
            occupation = form.occupation.text.trim().ifBlank { null },
            monthlyIncomeTarget = form.incomeIdr(currency).takeIf { it > 0 },
            walletName = form.walletName.text.trim(),
            walletType = form.walletType,
            walletBalance = form.balanceIdr(currency),
            style = form.style,
        )
    }

    fun skip() {
        haptic.performHapticFeedback(HapticFeedbackType.Confirm)
        form.clearIncome()
        form.step++
    }

    fun back() {
        form.step--
    }

    BackHandler(enabled = form.step > 1 && !form.saving) { back() }

    // a save that fails leaves the user here: stop the spinner and say what went wrong
    val error = state.errorMessage
    LaunchedEffect(error) {
        if (form.saving && error != null && error != form.errorBeforeSave) {
            form.saving = false
            snackbar.showSnackbar(error)
        }
    }

    val slide = MaterialTheme.motionScheme.defaultSpatialSpec<IntOffset>()
    val fade = MaterialTheme.motionScheme.defaultEffectsSpec<Float>()
    Scaffold(
        topBar = {
            OnboardingTopBar(step = form.step, canGoBack = form.step > 1 && !form.saving, onBack = { back() })
        },
        bottomBar = {
            OnboardingBottomBar(
                isLastStep = form.step == ONBOARDING_STEPS,
                canSkip = form.step == 3,
                canContinue = form.isStepValid(currency),
                saving = form.saving,
                onSkip = { skip() },
                onContinue = { advance() },
            )
        },
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        AnimatedContent(
            targetState = form.step,
            modifier = Modifier.padding(padding).fillMaxSize(),
            transitionSpec = {
                val direction = if (targetState > initialState) 1 else -1
                (slideInHorizontally(slide) { width -> width / 3 * direction } + fadeIn(fade)) togetherWith
                    (slideOutHorizontally(slide) { width -> -width / 3 * direction } + fadeOut(fade))
            },
            label = "onboarding step",
        ) { step ->
            Column(
                Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(24.dp),
            ) {
                when (step) {
                    1 -> NameStep(form, onAdvance = { advance() })
                    2 -> UsernameStep(form, onAdvance = { advance() })
                    3 -> IncomeStep(form, currency, onAdvance = { advance() })
                    4 -> WalletStep(form, currency, onAdvance = { advance() })
                    else -> StyleStep(form)
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun OnboardingTopBar(step: Int, canGoBack: Boolean, onBack: () -> Unit) {
    val motion = MaterialTheme.motionScheme
    val progress by animateFloatAsState(
        targetValue = step / ONBOARDING_STEPS.toFloat(),
        animationSpec = motion.defaultSpatialSpec(),
        label = "onboarding progress",
    )
    Column(
        Modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .padding(top = 16.dp),
    ) {
        LinearWavyProgressIndicator(
            // the expressive spring may overshoot; the bar itself must not
            progress = { progress.coerceIn(0f, 1f) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp),
        )
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 64.dp)
                .padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            AnimatedVisibility(
                visible = canGoBack,
                enter = fadeIn(motion.defaultEffectsSpec()) + expandHorizontally(motion.defaultSpatialSpec()),
                exit = fadeOut(motion.defaultEffectsSpec()) + shrinkHorizontally(motion.defaultSpatialSpec()),
            ) {
                IconButton(onClick = onBack, shapes = IconButtonDefaults.shapes()) {
                    Icon(Icons.AutoMirrored.Rounded.ArrowBack, contentDescription = "Kembali")
                }
            }
            Text(
                text = "Langkah $step dari $ONBOARDING_STEPS",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = 12.dp),
            )
        }
    }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun OnboardingBottomBar(
    isLastStep: Boolean,
    canSkip: Boolean,
    canContinue: Boolean,
    saving: Boolean,
    onSkip: () -> Unit,
    onContinue: () -> Unit,
) {
    val motion = MaterialTheme.motionScheme
    val height = ButtonDefaults.MediumContainerHeight
    Column(
        Modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .imePadding()
            .padding(24.dp),
    ) {
        AnimatedVisibility(
            visible = canSkip,
            enter = fadeIn(motion.defaultEffectsSpec()) + expandVertically(motion.defaultSpatialSpec()),
            exit = fadeOut(motion.defaultEffectsSpec()) + shrinkVertically(motion.defaultSpatialSpec()),
        ) {
            TextButton(
                onClick = onSkip,
                shapes = ButtonDefaults.shapes(),
                enabled = !saving,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 8.dp),
            ) {
                Text("Lewati")
            }
        }
        Button(
            onClick = onContinue,
            shapes = ButtonDefaults.shapesFor(height),
            enabled = canContinue && !saving,
            contentPadding = ButtonDefaults.contentPaddingFor(height),
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = height),
        ) {
            if (saving) {
                LoadingIndicator(color = LocalContentColor.current)
            } else {
                Text(
                    text = if (isLastStep) "Mulai" else "Lanjut",
                    style = ButtonDefaults.textStyleFor(height),
                )
                Spacer(Modifier.width(ButtonDefaults.iconSpacingFor(height)))
                Icon(
                    imageVector = Icons.AutoMirrored.Rounded.ArrowForward,
                    contentDescription = null,
                    modifier = Modifier.size(ButtonDefaults.iconSizeFor(height)),
                )
            }
        }
    }
}
