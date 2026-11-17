package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry

// primary detail view content displaying hero card, specs, and action buttons.
@Composable
fun SubscriptionDetailContent(
    subscription: SubscriptionEntry,
    wallet: WalletEntry,
    indexOverride: Int? = null,
    currencyFormatter: (Double) -> String,
    onEdit: () -> Unit,
    onDismiss: () -> Unit,
) {
    Column(Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState()),
        ) {
            Spacer(Modifier.height(8.dp))
            SubscriptionDetailHeroCard(subscription = subscription, wallet = wallet, indexOverride = indexOverride)
            Spacer(Modifier.height(18.dp))
            SubscriptionDetailSpecsCard(subscription = subscription, wallet = wallet, currencyFormatter = currencyFormatter)
            Spacer(Modifier.height(16.dp))
        }
        Box(Modifier.navigationBarsPadding().padding(top = 8.dp, bottom = 12.dp)) {
            SubscriptionDetailActions(subscription = subscription, wallet = wallet, onEdit = onEdit, onDismiss = onDismiss)
        }
    }
}
