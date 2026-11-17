package com.fibonanci.app.ui.walletdetail

import androidx.compose.runtime.remember
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind

// port of WalletDetailModalRoute.show; the host's full screen route provides the slide-up + scrim.
// the currency is captured once at open, like the dart formatter built before pushing.
fun showWalletDetail(host: ModalHost, wallet: WalletEntry, initialChildSize: Double = 1.0) {
    host.show(kind = ModalKind.FullScreen, dismissOnScrim = true) { dismiss ->
        val vm = LocalFinance.current
        val currency = remember { vm.state.value.profile.currency }
        val fmt = remember(currency) { { amount: Double -> AppCurrency.format(amount, currency) } }
        WalletDetailScreen(
            walletId = wallet.id,
            fmt = fmt,
            initialChildSize = initialChildSize,
            onDismiss = dismiss,
        )
    }
}
