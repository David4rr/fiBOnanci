package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.common.CardlessEmptyView
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.wallet.showAddWalletModal

@Composable
fun ColumnScope.DashboardEmptyWalletView() {
    val host = LocalModalHost.current
    Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
        Box(Modifier.padding(start = 24.dp, end = 24.dp, bottom = 80.dp)) {
            CardlessEmptyView(
                icon = Icons.Outlined.AccountBalanceWallet,
                title = "Belum Ada Rekening Terhubung",
                description = "Tambahkan rekening atau dompet digital untuk mulai melacak keuangan dan alokasi safe-to-spend.",
                hint = "Ketuk tombol + di bawah untuk menambahkan",
                onTap = { showAddWalletModal(host) },
            )
        }
    }
}
