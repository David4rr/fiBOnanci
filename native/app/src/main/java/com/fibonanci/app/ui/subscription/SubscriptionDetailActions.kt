package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.SlideToDeleteButton
import com.fibonanci.app.ui.theme.AppColors

// interactive action buttons for subscription detail: mark as paid, edit and slide-to-delete.
@Composable
fun SubscriptionDetailActions(
    subscription: SubscriptionEntry,
    wallet: WalletEntry,
    onEdit: (() -> Unit)? = null,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val isInstallment = subscription.isInstallment

    Column(modifier = Modifier.padding(horizontal = 20.dp)) {
        SubscriptionDetailPayButton(subscription = subscription, wallet = wallet, onDismiss = onDismiss)
        Spacer(Modifier.height(10.dp))
        OutlinedButton(
            onClick = {
                if (onEdit != null) {
                    onEdit()
                } else {
                    onDismiss()
                    showAddSubscriptionModal(host, subscription = subscription)
                }
            },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            border = BorderStroke(1.dp, AppColors.canvasBorder),
            contentPadding = PaddingValues(vertical = 14.dp),
        ) {
            Icon(Icons.Outlined.Edit, contentDescription = null, modifier = Modifier.size(18.dp), tint = AppColors.textWhite)
            Spacer(Modifier.width(8.dp))
            Text(
                if (isInstallment) "Edit Cicilan" else "Edit Tagihan",
                style = TextStyle(color = AppColors.textWhite, fontWeight = FontWeight.Bold),
            )
        }
        Spacer(Modifier.height(10.dp))
        SlideToDeleteButton(
            label = "Hapus",
            onSlideComplete = { executeDeleteSubscription(vm, host, subscription.id, onDismiss) },
        )
    }
}
