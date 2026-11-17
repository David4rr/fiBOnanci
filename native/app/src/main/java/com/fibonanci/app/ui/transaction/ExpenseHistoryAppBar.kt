package com.fibonanci.app.ui.transaction

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.foundation.layout.size
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

// drag callbacks report vertical deltas / velocities in px (positive = downward)
@Composable
fun ExpenseHistoryAppBar(
    totalFiltered: Double,
    currencyFormatter: (Double) -> String,
    onDragStart: (() -> Unit)? = null,
    onDragUpdate: ((Float) -> Unit)? = null,
    onDragEnd: ((Float) -> Unit)? = null,
    onDismiss: (() -> Unit)? = null,
    isEditing: Boolean = false,
    onReturnToHistory: (() -> Unit)? = null,
    customTitle: String? = null,
    customSubtitle: String? = null,
) {
    val dragState = rememberDraggableState { delta -> onDragUpdate?.invoke(delta) }
    Column(
        Modifier
            .fillMaxWidth()
            .draggable(
                dragState,
                Orientation.Vertical,
                onDragStarted = { onDragStart?.invoke() },
                onDragStopped = { v -> onDragEnd?.invoke(v) },
            ),
    ) {
        if (!isEditing) {
            Box(Modifier.fillMaxWidth().padding(top = 8.dp, bottom = 4.dp), contentAlignment = Alignment.Center) {
                ModalGrabHandle()
            }
        } else {
            Spacer(Modifier.height(16.dp))
        }
        Row(Modifier.fillMaxWidth().padding(start = 20.dp, top = 10.dp, end = 20.dp, bottom = 10.dp), verticalAlignment = Alignment.Top) {
            AnimatedContent(
                targetState = Triple(isEditing, customTitle, customSubtitle),
                transitionSpec = { SmoothPageView.headerTitleTransition(260) },
                contentAlignment = Alignment.TopStart,
                modifier = Modifier.weight(1f),
                label = "historyHeader",
            ) { (editing, title, subtitle) ->
                Column {
                    Text(
                        if (editing) (title ?: "Edit Transaksi") else "Riwayat\nPengeluaran",
                        style = AppTypography.modalTitle,
                        maxLines = if (editing) 1 else 2,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        if (editing) (subtitle ?: "Ubah rincian mutasi transaksi")
                        else "Total Terfilter: ${currencyFormatter(totalFiltered)}",
                        style = AppTypography.modalSubtitle,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            IconButton(onClick = {
                if (isEditing) onReturnToHistory?.invoke() else onDismiss?.invoke()
            }) {
                // rotate + fade in the new icon (quarter turn from the side it points to)
                val t = remember { Animatable(1f) }
                val shownFor = remember { mutableStateOf(isEditing) }
                LaunchedEffect(isEditing) {
                    if (shownFor.value != isEditing) {
                        shownFor.value = isEditing
                        t.snapTo(0f)
                        t.animateTo(1f, tween(320, easing = CubicBezierEasing(0.645f, 0.045f, 0.355f, 1f)))
                    }
                }
                Icon(
                    if (isEditing) Icons.AutoMirrored.Rounded.KeyboardArrowLeft else Icons.Rounded.KeyboardArrowDown,
                    contentDescription = null,
                    tint = AppColors.textWhite,
                    modifier = Modifier
                        .size(28.dp)
                        .graphicsLayer {
                            rotationZ = (if (isEditing) -90f else 90f) * (1f - t.value)
                            alpha = t.value
                        },
                )
            }
        }
    }
}
