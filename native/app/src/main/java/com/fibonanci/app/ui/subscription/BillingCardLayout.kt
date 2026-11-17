package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.PlusJakartaSans
import com.fibonanci.app.ui.wallet.ContactlessPainter

@Composable
fun BillingCardLayout(
    subscription: SubscriptionEntry,
    wallet: WalletEntry?,
    config: SubscriptionCardThemeConfig,
    currencyFormatter: (Double) -> String,
    isPaidThisMonth: Boolean,
) {
    val isMonthly = subscription.billingCycle == "monthly"
    val accent = config.textColor

    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 22.dp, vertical = 18.dp),
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        // top row: title on left & status badge on right
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                subscription.title,
                modifier = Modifier.weight(1f),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 19.sp,
                    fontWeight = FontWeight.W800,
                    color = accent,
                    letterSpacing = (-0.4).sp,
                ),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.width(10.dp))
            SubscriptionCardBadges.buildStatusBadge(isPaidThisMonth, subscription.dueDay, config, isInstallment = false)
        }

        // bottom row: recurring cost & contactless icon
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Bottom,
        ) {
            Column {
                Text(
                    currencyFormatter(subscription.cost),
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.W800,
                        color = accent,
                        letterSpacing = (-0.6).sp,
                        fontFeatureSettings = "tnum",
                    ),
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    if (isMonthly) "tagihan rutin /bulan" else "tagihan rutin /tahun",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.W600,
                        color = accent.copy(alpha = 0.65f),
                    ),
                )
            }
            Canvas(modifier = Modifier.padding(bottom = 4.dp).size(20.dp, 15.dp)) {
                with(ContactlessPainter(color = accent.copy(alpha = 0.85f))) { paint() }
            }
        }
    }
}
