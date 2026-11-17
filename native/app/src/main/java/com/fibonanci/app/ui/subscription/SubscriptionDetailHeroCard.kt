package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry

// destination card for the full-screen subscription/installment detail view.
@Composable
fun SubscriptionDetailHeroCard(
    subscription: SubscriptionEntry,
    wallet: WalletEntry? = null,
    indexOverride: Int? = null,
) {
    Box(Modifier.padding(horizontal = 20.dp)) {
        SubscriptionCard(
            subscription = subscription,
            wallet = wallet,
            indexOverride = indexOverride,
            isFocused = true,
        )
    }
}
