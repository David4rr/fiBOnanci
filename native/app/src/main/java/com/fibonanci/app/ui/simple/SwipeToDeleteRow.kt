@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Delete
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.SwipeToDismissBoxState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp

// share of the row width a slow drag must travel before it deletes; a quick flick deletes from any distance
private const val DELETE_THRESHOLD = 0.4f

// a row the user can fling to the left to delete. the row follows the finger 1:1, and on release the
// stock anchored-drag spring finishes the motion from the finger's velocity. the trash icon swells and a
// haptic tick fires the moment letting go would delete, so the outcome is known before the finger lifts.
@Composable
fun SwipeToDeleteRow(
    shape: Shape,
    deleteLabel: String,
    onDelete: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val haptic = LocalHapticFeedback.current
    val colors = MaterialTheme.colorScheme
    // deliberately not saved: the list keeps saved state per row key, so a row brought back by undo would
    // restore its swiped-away position and be dismissed again on the spot. a fresh row always starts settled.
    val state = remember { SwipeToDismissBoxState(SwipeToDismissBoxValue.Settled) { distance -> distance * DELETE_THRESHOLD } }
    val armed = state.targetValue == SwipeToDismissBoxValue.EndToStart

    LaunchedEffect(armed) {
        if (armed) haptic.performHapticFeedback(HapticFeedbackType.GestureThresholdActivate)
    }
    // the box re-runs its dismiss effect whenever this callback changes identity, so it must stay the same
    // object across recompositions or one swipe would delete (and announce) several times
    val currentOnDelete by rememberUpdatedState(onDelete)
    val dismiss: (SwipeToDismissBoxValue) -> Unit = remember { { currentOnDelete() } }

    SwipeToDismissBox(
        state = state,
        modifier = modifier
            .clip(shape)
            .semantics {
                // swiping is not available to every user, so the same action is offered to accessibility services
                customActions = listOf(CustomAccessibilityAction(deleteLabel) { onDelete(); true })
            },
        enableDismissFromStartToEnd = false,
        onDismiss = dismiss,
        backgroundContent = {
            val iconScale by animateFloatAsState(
                targetValue = if (armed) 1.25f else 0.85f,
                animationSpec = MaterialTheme.motionScheme.fastSpatialSpec(),
                label = "deleteIcon",
            )
            Box(
                Modifier
                    .fillMaxSize()
                    .background(if (armed) colors.error else colors.errorContainer)
                    .padding(horizontal = 24.dp),
                contentAlignment = Alignment.CenterEnd,
            ) {
                Icon(
                    Icons.Rounded.Delete,
                    contentDescription = null,
                    tint = if (armed) colors.onError else colors.onErrorContainer,
                    modifier = Modifier.graphicsLayer {
                        scaleX = iconScale
                        scaleY = iconScale
                    },
                )
            }
        },
    ) {
        content()
    }
}
