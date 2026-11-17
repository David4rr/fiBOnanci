package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.PieChartOutline
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material.icons.outlined.Shield
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.domain.SafeToSpendMetrics
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors

// 2x2 bento folder grid: safe-to-spend, total real balance, committed bills and daily pace.
@Composable
fun DashboardBentoGrid(
    metrics: SafeToSpendMetrics,
    wallets: List<WalletEntry>,
    subscriptions: List<SubscriptionEntry>,
    currencyFormatter: (Double) -> String,
    onNavigateToWallets: () -> Unit,
    onNavigateToSubscriptions: () -> Unit,
    isBalanceHidden: Boolean = false,
) {
    val host = LocalModalHost.current
    val infoIcon: @Composable () -> Unit = {
        Icon(Icons.Outlined.Info, null, tint = AppColors.textDarkSecondary, modifier = Modifier.size(13.dp))
    }
    val chevronIcon: @Composable () -> Unit = {
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = AppColors.textDarkSecondary, modifier = Modifier.size(14.dp))
    }

    Column(Modifier.padding(start = 20.dp, top = 8.dp, end = 20.dp, bottom = 10.dp)) {
        Row {
            // card 1: safe-to-spend (opens formula breakdown)
            BentoFolderCard(
                backgroundColor = AppColors.neoChartreuse,
                iconData = Icons.Outlined.Shield,
                title = currencyFormatter(metrics.safeToSpendMonthly),
                isBalanceHidden = isBalanceHidden,
                subtitle = if (metrics.isAllWallets) "Safe to Spend" else "Safe to Spend (${metrics.selectedWalletsCount} Akun)",
                trailingIcon = infoIcon,
                onTap = { showSafeToSpendModal(host, wallets) },
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(14.dp))
            // card 2: total real balance (switches to wallets tab)
            BentoFolderCard(
                backgroundColor = AppColors.neoMint,
                iconData = Icons.Outlined.AccountBalanceWallet,
                title = currencyFormatter(metrics.totalRealBalance),
                isBalanceHidden = isBalanceHidden,
                subtitle = "${wallets.size} Akun Riil",
                trailingIcon = chevronIcon,
                onTap = onNavigateToWallets,
                modifier = Modifier.weight(1f),
            )
        }
        Spacer(Modifier.height(14.dp))
        Row {
            // card 3: pending bills (navigates to subscriptions tab)
            BentoFolderCard(
                backgroundColor = AppColors.neoCoral,
                iconData = Icons.AutoMirrored.Outlined.ReceiptLong,
                title = currencyFormatter(metrics.pendingBills),
                isBalanceHidden = isBalanceHidden,
                subtitle = "${subscriptions.size} Tagihan Bln Ini",
                trailingIcon = chevronIcon,
                onTap = onNavigateToSubscriptions,
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(14.dp))
            // card 4: daily allowance (opens daily pace calculator)
            BentoFolderCard(
                backgroundColor = AppColors.neoCyan,
                iconData = Icons.Outlined.PieChartOutline,
                title = currencyFormatter(metrics.safeToSpendDaily),
                isBalanceHidden = isBalanceHidden,
                subtitle = "Alokasi/Hari (${metrics.daysRemainingInMonth}hr)",
                trailingIcon = infoIcon,
                onTap = { showDailyPaceModal(host, metrics) },
                modifier = Modifier.weight(1f),
            )
        }
    }
}
