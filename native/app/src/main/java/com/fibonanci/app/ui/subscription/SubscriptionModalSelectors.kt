package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ArrowDropDown
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun SubscriptionWalletDropdown(
    wallets: List<WalletEntry>,
    selectedWalletId: String?,
    onWalletChanged: (String?) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    val selected = wallets.firstOrNull { it.id == selectedWalletId }
    Column {
        Text("SUMBER DANA PEMBAYARAN", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
        Spacer(Modifier.height(6.dp))
        val shape = RoundedCornerShape(16.dp)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasInputSearch, shape)
                .border(1.dp, AppColors.canvasBorder, shape)
                .clickable { expanded = true }
                .padding(horizontal = 16.dp)
                .height(48.dp),
            contentAlignment = Alignment.CenterStart,
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    selected?.name ?: "",
                    modifier = Modifier.weight(1f),
                    style = AppTypography.listTitle,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Icon(Icons.Rounded.ArrowDropDown, contentDescription = null, tint = AppColors.textMuted)
            }
            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false },
                containerColor = AppColors.canvasCardSurface,
            ) {
                for (w in wallets) {
                    DropdownMenuItem(
                        text = { Text(w.name, style = AppTypography.listTitle) },
                        onClick = {
                            expanded = false
                            onWalletChanged(w.id)
                        },
                    )
                }
            }
        }
    }
}

@Composable
fun SubscriptionAutoDeductSwitch(
    autoDeduct: Boolean,
    onToggle: (Boolean) -> Unit,
) {
    val shape = RoundedCornerShape(16.dp)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColors.canvasInputSearch, shape)
            .border(1.dp, AppColors.canvasBorder, shape)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text("Auto-Deduct Saldo", style = AppTypography.listTitle)
            Spacer(Modifier.height(2.dp))
            Text(
                "Potong saldo otomatis saat tgl jatuh tempo",
                style = AppTypography.listSubtitle,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
        Spacer(Modifier.width(8.dp))
        Switch(
            checked = autoDeduct,
            onCheckedChange = onToggle,
            colors = SwitchDefaults.colors(checkedThumbColor = AppColors.neoChartreuse),
        )
    }
}

// deletes the subscription, closes the current route (or runs onDeleted) and shows the snackbar.
fun executeDeleteSubscription(
    vm: FinanceViewModel,
    host: ModalHost,
    subscriptionId: String,
    onDismiss: () -> Unit,
    onDeleted: (() -> Unit)? = null,
) {
    vm.deleteSubscription(subscriptionId)
    if (onDeleted != null) onDeleted() else onDismiss()
    host.showSnackBar(
        "Tagihan berhasil dihapus & pembayaran dikembalikan ke saldo rekening.",
        background = AppColors.neoCoral,
        contentColor = AppColors.textDarkPrimary,
    )
}

fun showSubscriptionDeleteDialog(vm: FinanceViewModel, host: ModalHost, subscriptionId: String, onDismiss: () -> Unit) {
    executeDeleteSubscription(vm, host, subscriptionId, onDismiss)
}
