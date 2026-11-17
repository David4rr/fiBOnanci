package com.fibonanci.app.ui.subscription

import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind

// full-screen route displaying subscription or installment details; the host draws the scrim and slide-up transition.
fun showSubscriptionDetail(
    host: ModalHost,
    subscription: SubscriptionEntry,
    wallet: WalletEntry,
    indexOverride: Int? = null,
    initialChildSize: Double = 1.0,
) {
    host.show(ModalKind.FullScreen) { dismiss ->
        SubscriptionDetailScreen(
            subscriptionId = subscription.id,
            initialWallet = wallet,
            indexOverride = indexOverride,
            initialChildSize = initialChildSize,
            onDismiss = dismiss,
        )
    }
}
