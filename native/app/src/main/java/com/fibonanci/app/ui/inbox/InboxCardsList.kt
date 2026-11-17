package com.fibonanci.app.ui.inbox

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun InboxCardsList(
    items: List<Map<String, Any?>>,
    onConfirm: (Map<String, Any?>) -> Unit,
    onReject: (Map<String, Any?>) -> Unit,
    onReassign: ((Map<String, Any?>) -> Unit)? = null,
    onEdit: ((Map<String, Any?>) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    InboxStackedDeck(
        items = items,
        onConfirm = onConfirm,
        onReject = onReject,
        onReassign = onReassign,
        onEdit = onEdit,
        modifier = modifier,
    )
}
