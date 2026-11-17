package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.dropShadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.shadow.Shadow
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.dashboard.TrendSplineChart
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import com.fibonanci.app.ui.transaction.showTransactionModal
import com.fibonanci.app.ui.wallet.showEditBalanceModal

@Composable
fun WalletDetailActionsAndChart(
    wallet: WalletEntry,
    cardColor: Color,
    transactions: List<TransactionEntry>,
    onEditBalance: (() -> Unit)? = null,
    onAddTransaction: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    val hasActivity = wallet.balance > 0 ||
        transactions.any { it.walletId == wallet.id || it.destinationWalletId == wallet.id }

    Column(modifier = modifier) {
        Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp)) {
            PressableScale(
                onTap = onEditBalance ?: { showEditBalanceModal(host, wallet) },
                modifier = Modifier.weight(1f),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp)
                        .background(AppColors.canvasCardSurface, RoundedCornerShape(14.dp))
                        .border(0.8.dp, AppColors.canvasBorder, RoundedCornerShape(14.dp)),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Rounded.Tune, contentDescription = null, tint = AppColors.textWhite, modifier = Modifier.size(15.dp))
                    Spacer(Modifier.width(8.dp))
                    Text(
                        "Ubah Saldo",
                        style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite),
                    )
                }
            }
            Spacer(Modifier.width(12.dp))
            PressableScale(
                onTap = onAddTransaction ?: { showTransactionModal(host, initialWalletId = wallet.id) },
                modifier = Modifier.weight(1f),
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp)
                        .dropShadow(
                            RoundedCornerShape(14.dp),
                            Shadow(radius = 16.dp, color = AppColors.neoMint.copy(alpha = 0.28f), offset = DpOffset(0.dp, 4.dp)),
                        )
                        .background(AppColors.neoMint, RoundedCornerShape(14.dp)),
                    contentAlignment = Alignment.Center,
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(
                            "Catat Transaksi",
                            style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textDarkPrimary, fontWeight = FontWeight.W800, fontSize = 13.sp),
                            maxLines = 1,
                            overflow = TextOverflow.Clip,
                            softWrap = false,
                        )
                        Spacer(Modifier.width(8.dp))
                        Box(
                            modifier = Modifier
                                .size(22.dp)
                                .background(AppColors.textDarkPrimary.copy(alpha = 0.15f), CircleShape),
                            contentAlignment = Alignment.Center,
                        ) {
                            Icon(Icons.Rounded.Add, contentDescription = null, tint = AppColors.textDarkPrimary, modifier = Modifier.size(14.dp))
                        }
                    }
                }
            }
        }
        if (hasActivity) {
            val incomeValues = remember(transactions, wallet.id) {
                CashflowAnalyticsService.compute30DaySeries(transactions, type = "income", walletId = wallet.id)
            }
            val expenseValues = remember(transactions, wallet.id) {
                CashflowAnalyticsService.compute30DaySeries(transactions, type = "expense", walletId = wallet.id)
            }
            Spacer(Modifier.height(16.dp))
            Box(modifier = Modifier.padding(horizontal = 20.dp)) {
                TrendSplineChart(
                    incomeValues = incomeValues,
                    expenseValues = expenseValues,
                    labels = CashflowAnalyticsService.compute30DayLabels(),
                    lineColor = cardColor,
                    headline = "Tren Mutasi ${wallet.name}",
                    subtitle = "30 Hari Terakhir",
                    height = 100.dp,
                )
            }
        }
    }
}
