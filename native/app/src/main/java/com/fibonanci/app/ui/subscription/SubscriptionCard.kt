package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.wallet.ModernistCardPainter
import java.time.LocalDate
import kotlin.math.abs

// true when the last payment falls in the current calendar month
internal fun SubscriptionEntry.isPaidThisMonth(): Boolean {
    val paid = lastPaidDate?.toLocalDate() ?: return false
    val now = LocalDate.now()
    return paid.year == now.year && paid.month == now.month
}

// tactile atm-style card representing either a fixed installment plan or recurring subscription.
@Composable
fun SubscriptionCard(
    subscription: SubscriptionEntry,
    wallet: WalletEntry? = null,
    onTap: (() -> Unit)? = null,
    indexOverride: Int? = null,
    isFocused: Boolean = true,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val isPaidThisMonth = subscription.isPaidThisMonth()

    val effectiveIdx = abs(indexOverride ?: (abs(subscription.title.hashCode()) % SubscriptionCardResolver.kCardThemes.size))
    val theme = SubscriptionCardResolver.resolve(subscription.title, effectiveIdx, index = effectiveIdx)
    val config = SubscriptionCardResolver.resolveConfig(subscription = subscription, index = effectiveIdx, wallet = wallet)
    val currencyFormatter: (Double) -> String = { AppCurrency.format(it, currency) }
    val shape = RoundedCornerShape(26.dp)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(215.dp)
            .shadow(18.dp, shape, ambientColor = Color.Black.copy(alpha = 0.45f), spotColor = Color.Black.copy(alpha = 0.45f))
            .clip(shape)
            .background(config.backgroundColor)
            .then(
                if (onTap != null) Modifier.clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onTap,
                ) else Modifier,
            ),
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            with(
                ModernistCardPainter(
                    theme = theme,
                    primaryColor = config.primaryGraphicColor,
                    secondaryColor = config.secondaryGraphicColor,
                ),
            ) { paint() }
        }
        if (subscription.isInstallment) {
            InstallmentCardLayout(subscription, wallet, config, currencyFormatter, isPaidThisMonth)
        } else {
            BillingCardLayout(subscription, wallet, config, currencyFormatter, isPaidThisMonth)
        }
    }
}
