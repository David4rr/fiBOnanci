package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors

// legacy modal wrapper retained for backward compatibility.
fun showInboxEditTransactionSheet(
    host: ModalHost,
    initialAmount: Double,
    initialType: String,
    initialCounterparty: String,
    walletName: String? = null,
    onResult: (Map<String, Any?>) -> Unit,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        InboxEditTransactionSheet(
            initialAmount = initialAmount,
            initialType = initialType,
            initialCounterparty = initialCounterparty,
            walletName = walletName,
            onSave = { res ->
                dismiss()
                onResult(res)
            },
            onDismiss = dismiss,
        )
    }
}

@Composable
fun InboxEditTransactionSheet(
    initialAmount: Double,
    initialType: String,
    initialCounterparty: String,
    walletName: String? = null,
    onSave: (Map<String, Any?>) -> Unit,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
            .windowInsetsPadding(WindowInsets.ime)
            .padding(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 20.dp),
    ) {
        ModalGrabHandle()
        Spacer(Modifier.height(12.dp))
        InboxInlineEditForm(
            initialAmount = initialAmount,
            initialType = initialType,
            initialCounterparty = initialCounterparty,
            walletName = walletName,
            onSave = onSave,
            onCancel = onDismiss,
        )
    }
}
