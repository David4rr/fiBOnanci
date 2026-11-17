package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader

// standard modal app bar with a tactile grab handle, modal typography and dismiss chevron.
// the header drag gesture is attached by the caller through [modifier].
@Composable
fun SubscriptionDetailAppBar(
    subscription: SubscriptionEntry,
    currencyFormatter: (Double) -> String,
    onDismiss: (() -> Unit)? = null,
    isEditing: Boolean = false,
    onReturnToDetails: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val isInstallment = subscription.isInstallment
    val title = if (isEditing) {
        if (isInstallment) "Edit Cicilan" else "Edit Tagihan Rutin"
    } else {
        if (isInstallment) "Detail Cicilan" else "Detail Tagihan"
    }
    val subtitle = if (isEditing) {
        if (isInstallment) "Rencana cicilan tenor & jatuh tempo" else "Langganan, tagihan rutin, atau tagihan berkala"
    } else {
        subscription.title
    }
    val closeIcon = if (isEditing) Icons.AutoMirrored.Rounded.KeyboardArrowLeft else Icons.Rounded.KeyboardArrowDown
    val onClose = if (isEditing) (onReturnToDetails ?: onDismiss) else onDismiss

    Column(modifier = modifier.fillMaxWidth()) {
        if (!isEditing) {
            Box(Modifier.fillMaxWidth().padding(top = 8.dp, bottom = 4.dp), contentAlignment = Alignment.Center) {
                ModalGrabHandle()
            }
        } else {
            Spacer(Modifier.height(16.dp))
        }
        Box(Modifier.padding(start = 20.dp, top = 10.dp, end = 20.dp, bottom = 10.dp)) {
            ModalHeader(
                title = title,
                subtitle = subtitle,
                closeIcon = closeIcon,
                onClose = onClose,
                padding = PaddingValues(0.dp),
            )
        }
    }
}
