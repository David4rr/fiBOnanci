package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun InboxReviewDeckView(
    pending: List<Map<String, Any?>>,
    onConfirm: (Map<String, Any?>) -> Unit,
    onReject: (Map<String, Any?>) -> Unit,
    onReassign: (Map<String, Any?>) -> Unit,
    onEdit: (Map<String, Any?>) -> Unit,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier) {
        InboxHeaderRibbon(pendingCount = pending.size, onDismiss = onDismiss)
        if (pending.isEmpty()) {
            InboxEmptyView()
        } else {
            InboxCardsList(
                items = pending,
                onConfirm = onConfirm,
                onReject = onReject,
                onReassign = onReassign,
                onEdit = onEdit,
            )
        }
    }
}
