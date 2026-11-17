package com.fibonanci.app.ui.subscription

import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ModalHost

// backward-compatible wrapper delegating to the full-screen subscription detail.
fun showSubscriptionCardDetailSheet(
    host: ModalHost,
    sub: SubscriptionEntry,
    wallet: WalletEntry,
    indexOverride: Int? = null,
    initialChildSize: Double = 1.0,
) {
    showSubscriptionDetailScreen(
        host,
        subscription = sub,
        wallet = wallet,
        indexOverride = indexOverride,
        initialChildSize = initialChildSize,
    )
}
