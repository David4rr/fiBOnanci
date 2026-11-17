package com.fibonanci.app.ui.onboarding

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.Palette
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialShapes
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.toShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.UiStyle

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun StyleStep(form: OnboardingForm) {
    val keyboard = LocalSoftwareKeyboardController.current
    val focusManager = LocalFocusManager.current
    val haptic = LocalHapticFeedback.current
    LaunchedEffect(Unit) {
        focusManager.clearFocus()
        keyboard?.hide()
    }
    StepHeader(
        shape = MaterialShapes.Sunny,
        icon = Icons.Rounded.Palette,
        question = "Pilih tampilanmu",
        helper = "Keduanya memakai data yang sama. Bisa diganti kapan saja di pengaturan.",
    )
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        StyleCard(
            title = "Sederhana",
            description = "Satu halaman, cepat dicatat",
            selected = form.style == UiStyle.iblameraihan,
            onClick = {
                haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                form.style = UiStyle.iblameraihan
            },
            preview = { SimplePreview() },
        )
        StyleCard(
            title = "Lengkap",
            description = "Kartu, grafik, kantong, laporan",
            selected = form.style == UiStyle.david4rr,
            onClick = {
                haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                form.style = UiStyle.david4rr
            },
            preview = { FullPreview() },
        )
    }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun StyleCard(
    title: String,
    description: String,
    selected: Boolean,
    onClick: () -> Unit,
    preview: @Composable () -> Unit,
) {
    val motion = MaterialTheme.motionScheme
    val colors = MaterialTheme.colorScheme
    val container by animateColorAsState(
        targetValue = if (selected) colors.secondaryContainer else colors.surfaceContainerHigh,
        animationSpec = motion.defaultEffectsSpec(),
        label = "style card container",
    )
    Card(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .semantics {
                this.selected = selected
                role = Role.RadioButton
            },
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(containerColor = container),
        border = if (selected) BorderStroke(2.dp, colors.primary) else null,
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier
                    .size(width = 88.dp, height = 72.dp)
                    .clip(MaterialTheme.shapes.medium),
            ) {
                preview()
            }
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 16.dp),
            ) {
                Text(text = title, style = MaterialTheme.typography.titleMediumEmphasized)
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.onSurfaceVariant,
                )
            }
            SelectedBadge(selected)
        }
    }
}

// the check that pops in on the chosen card
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
private fun SelectedBadge(selected: Boolean) {
    val colors = MaterialTheme.colorScheme
    val motion = MaterialTheme.motionScheme
    Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) {
        AnimatedVisibility(
            visible = selected,
            enter = scaleIn(motion.fastSpatialSpec()) + fadeIn(motion.defaultEffectsSpec()),
            exit = scaleOut(motion.fastSpatialSpec()) + fadeOut(motion.defaultEffectsSpec()),
        ) {
            Surface(shape = MaterialShapes.Circle.toShape(), color = colors.primary) {
                Icon(
                    imageVector = Icons.Rounded.Check,
                    contentDescription = null,
                    modifier = Modifier.padding(4.dp).size(16.dp),
                )
            }
        }
    }
}

// a tiny picture of the plain look: one hero block and a few list rows
@Composable
private fun SimplePreview() {
    val colors = MaterialTheme.colorScheme
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .background(colors.surfaceContainerLowest)
            .padding(8.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        Box(
            Modifier
                .fillMaxWidth(0.75f)
                .height(20.dp)
                .background(colors.primaryContainer, MaterialTheme.shapes.extraSmall),
        )
        Spacer(Modifier.height(2.dp))
        listOf(1f, 0.8f, 0.6f).forEach { width ->
            Box(
                Modifier
                    .fillMaxWidth(width)
                    .height(6.dp)
                    .background(colors.onSurfaceVariant, MaterialTheme.shapes.extraSmall),
            )
        }
    }
}

// a tiny picture of the full look, drawn in that look's own neon palette
private val fullLookBackground = Color(0xFF0C0D11)
private val fullLookTiles = listOf(Color(0xFFD4F442), Color(0xFF7DF24E), Color(0xFFFF7052), Color(0xFF26D9D9))

@Composable
private fun FullPreview() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .background(fullLookBackground)
            .padding(8.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        fullLookTiles.chunked(2).forEach { row ->
            Row(
                modifier = Modifier.weight(1f),
                horizontalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                row.forEach { tile ->
                    Box(
                        Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .background(tile, MaterialTheme.shapes.small),
                    )
                }
            }
        }
    }
}
