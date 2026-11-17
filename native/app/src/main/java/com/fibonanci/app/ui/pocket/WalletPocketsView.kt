package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Savings
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.common.CardlessEmptyView
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.dashboard.BentoFolderCard
import com.fibonanci.app.ui.theme.PlusJakartaSans

// dart returns slivers; here it is a plain column the wallet screen places in its scroll body.
// the empty state fills the given space (pass a fill/weight modifier for SliverFillRemaining).
@Composable
fun WalletPocketsView(
    pockets: List<PocketEntry>,
    totalPocketsAmount: Double,
    transactions: List<TransactionEntry>,
    fmt: (Double) -> String,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    if (pockets.isEmpty()) {
        Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Box(modifier = Modifier.padding(start = 24.dp, end = 24.dp, bottom = 80.dp)) {
                CardlessEmptyView(
                    icon = Icons.Outlined.Savings,
                    title = "Belum Ada Kantong Tabungan",
                    description = "Pisahkan dana untuk Tabungan, Dana Darurat, atau Impianmu agar aman dari belanja harian.",
                    hint = "Ketuk tombol + di bawah untuk membuat",
                )
            }
        }
        return
    }

    Column(modifier = modifier.fillMaxWidth()) {
        Box(modifier = Modifier.padding(start = 20.dp, top = 16.dp, end = 20.dp)) {
            PocketStockChartCard(
                currentTotal = totalPocketsAmount,
                pocketsCount = pockets.size,
                transactions = transactions,
            )
        }
        Column(modifier = Modifier.padding(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 32.dp)) {
            pockets.chunked(2).forEachIndexed { rowIndex, rowPockets ->
                if (rowIndex > 0) Spacer(Modifier.height(14.dp))
                Row(modifier = Modifier.fillMaxWidth()) {
                    rowPockets.forEachIndexed { col, pocket ->
                        if (col > 0) Spacer(Modifier.width(14.dp))
                        val index = rowIndex * 2 + col
                        val config = PocketCardThemeConfig.resolve(pocket, index, allPockets = pockets)
                        val target = pocket.targetAmount
                        Box(modifier = Modifier.weight(1f).height(148.dp)) {
                            BentoFolderCard(
                                backgroundColor = config.backgroundColor,
                                gradient = null,
                                textColor = config.primaryTextColor,
                                subtitleColor = config.secondaryTextColor,
                                iconColor = config.iconColor,
                                iconBgColor = config.iconBgColor,
                                height = 148.dp,
                                iconData = getPocketIcon(pocket.type),
                                title = fmt(pocket.currentAmount),
                                subtitleWidget = {
                                    Column {
                                        Text(
                                            pocket.name,
                                            style = TextStyle(
                                                fontFamily = PlusJakartaSans,
                                                fontSize = 13.5.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = config.secondaryTextColor,
                                                letterSpacing = (-0.2).sp,
                                            ),
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis,
                                        )
                                        Spacer(Modifier.height(3.dp))
                                        Text(
                                            if (target != null && target > 0) "Target ${fmt(target)}" else "Tanpa target",
                                            style = TextStyle(
                                                fontFamily = PlusJakartaSans,
                                                fontSize = 10.5.sp,
                                                fontWeight = FontWeight.SemiBold,
                                                color = config.tertiaryTextColor,
                                            ),
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis,
                                        )
                                    }
                                },
                                onTap = { showPocketDetailModal(host, pocket = pocket) },
                            )
                        }
                    }
                    // keep the last odd card at half width like the grid
                    if (rowPockets.size == 1) {
                        Spacer(Modifier.width(14.dp))
                        Spacer(Modifier.weight(1f))
                    }
                }
            }
        }
    }
}
