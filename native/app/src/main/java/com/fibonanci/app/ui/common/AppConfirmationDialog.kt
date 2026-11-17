package com.fibonanci.app.ui.common

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

/**
 * dart AppConfirmationDialog.show. [onResult] receives true for confirm, false for cancel;
 * a barrier dismiss (dart null) does not call it.
 */
fun showAppConfirmationDialog(
    host: ModalHost,
    title: String,
    content: String,
    confirmText: String = "Hapus",
    cancelText: String = "Batal",
    confirmColor: Color = AppColors.neoCoral,
    confirmTextColor: Color = AppColors.textDarkPrimary,
    titleLeading: (@Composable () -> Unit)? = null,
    onConfirm: (() -> Unit)? = null,
    onResult: (Boolean) -> Unit = {},
) {
    host.show(ModalKind.Dialog) { dismiss ->
        AppConfirmationDialog(
            title = title,
            content = content,
            confirmText = confirmText,
            cancelText = cancelText,
            confirmColor = confirmColor,
            confirmTextColor = confirmTextColor,
            titleLeading = titleLeading,
            onCancel = {
                dismiss()
                onResult(false)
            },
            onConfirmPressed = {
                dismiss()
                onResult(true)
                onConfirm?.invoke()
            },
        )
    }
}

@Composable
private fun AppConfirmationDialog(
    title: String,
    content: String,
    confirmText: String,
    cancelText: String,
    confirmColor: Color,
    confirmTextColor: Color,
    titleLeading: (@Composable () -> Unit)?,
    onCancel: () -> Unit,
    onConfirmPressed: () -> Unit,
) {
    val shape = RoundedCornerShape(20.dp)
    val titleStyle = AppTypography.sectionTitle.copy(color = AppColors.textWhite, fontSize = 18.sp)

    Column(
        Modifier
            .widthIn(min = 280.dp, max = 560.dp)
            .background(AppColors.canvasCardSurface, shape)
            .border(1.dp, AppColors.canvasBorder, shape),
    ) {
        Column(Modifier.padding(start = 24.dp, top = 24.dp, end = 24.dp, bottom = 24.dp)) {
            if (titleLeading != null) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    titleLeading()
                    Spacer(Modifier.width(10.dp))
                    Text(title, style = titleStyle, modifier = Modifier.weight(1f))
                }
            } else {
                Text(title, style = titleStyle)
            }
            Spacer(Modifier.height(16.dp))
            Text(
                content,
                style = AppTypography.listSubtitle.copy(
                    color = AppColors.textMuted,
                    fontSize = 14.sp,
                    lineHeight = 1.4.em,
                ),
            )
        }
        Row(
            Modifier
                .fillMaxWidth()
                .padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.End),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            TextButton(onClick = onCancel) {
                Text(cancelText, style = AppTypography.listTitle.copy(color = AppColors.textMuted, fontSize = 14.sp))
            }
            Button(
                onClick = onConfirmPressed,
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = confirmColor,
                    contentColor = confirmTextColor,
                ),
                elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
            ) {
                Text(confirmText, fontWeight = FontWeight.Bold)
            }
        }
    }
}
