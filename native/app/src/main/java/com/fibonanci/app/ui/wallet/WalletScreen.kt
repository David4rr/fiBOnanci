package com.fibonanci.app.ui.wallet

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.pocket.WalletPocketsView
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.walletdetail.showWalletDetailScreen
import kotlinx.coroutines.launch

private val segmentFadeCurve = CubicBezierEasing(0.22f, 1.0f, 0.36f, 1.0f)

@Composable
fun WalletScreen(
    initialSegment: Int = 0,
    onSegmentChanged: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val host = LocalModalHost.current
    val scope = rememberCoroutineScope()
    val density = LocalDensity.current

    var selectedSegment by remember { mutableIntStateOf(initialSegment) }
    val segmentOpacity = remember { Animatable(1f) }
    var headerHeightPx by remember { mutableIntStateOf(0) }

    val currency = state.profile.currency
    val currencyFormatter: (Double) -> String = { AppCurrency.format(it, currency) }
    val wallets = state.wallets
    val pockets = state.pockets

    val totalRealBalance = wallets.sumOf { it.balance }
    val totalPocketsAmount = pockets.sumOf { it.currentAmount }

    val incomeSeries = CashflowAnalyticsService.compute30DaySeries(state.transactions, type = "income")
    val expenseSeries = CashflowAnalyticsService.compute30DaySeries(state.transactions, type = "expense")
    val dateLabels = CashflowAnalyticsService.compute30DayLabels()
    val monthlyCashflow = CashflowAnalyticsService.calculateMonthlyCashflow(state.transactions)

    BoxWithConstraints(
        modifier
            .fillMaxSize()
            .background(AppColors.canvasBg)
            .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal)),
    ) {
        val viewportHeight = maxHeight
        // SliverFillRemaining: the remaining space below the header slivers
        val remainingHeight = (viewportHeight - with(density) { headerHeightPx.toDp() }).coerceAtLeast(0.dp)

        Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
            Column(Modifier.onSizeChanged { headerHeightPx = it.height }) {
                Column(Modifier.padding(start = 20.dp, top = 20.dp, end = 20.dp)) {
                    Text("Rekening & Dompet", style = AppTypography.heroGreeting.copy(fontSize = 26.sp))
                    Spacer(Modifier.height(4.dp))
                    Text("${wallets.size} rekening terhubung", style = AppTypography.listSubtitle)
                }
                Box(Modifier.padding(start = 20.dp, top = 16.dp, end = 20.dp)) {
                    WalletSegmentedToggle(
                        selectedSegment = selectedSegment,
                        walletCount = wallets.size,
                        pocketCount = pockets.size,
                        onSegmentChanged = { idx ->
                            if (idx != selectedSegment) {
                                selectedSegment = idx
                                scope.launch {
                                    segmentOpacity.snapTo(0f)
                                    segmentOpacity.animateTo(1f, tween(260, easing = segmentFadeCurve))
                                }
                                onSegmentChanged?.invoke(idx)
                            }
                        },
                    )
                }
            }

            Column(Modifier.fillMaxWidth().graphicsLayer { alpha = segmentOpacity.value }) {
                if (selectedSegment == 0) {
                    if (wallets.isNotEmpty()) {
                        WalletTotalBalanceCard(
                            totalRealBalance = totalRealBalance,
                            monthlyIncome = monthlyCashflow.income,
                            monthlyExpense = monthlyCashflow.expense,
                            incomeSeries = incomeSeries,
                            expenseSeries = expenseSeries,
                            dateLabels = dateLabels,
                            showChart = totalRealBalance > 0 || state.transactions.isNotEmpty(),
                            currencyFormatter = currencyFormatter,
                        )
                        Box(Modifier.padding(start = 20.dp, top = 16.dp, end = 20.dp)) {
                            WalletCardDeck(
                                wallets = wallets,
                                fmt = currencyFormatter,
                                onSelectWallet = { wallet -> showWalletDetailScreen(host, wallet) },
                            )
                        }
                    } else {
                        Box(
                            Modifier.fillMaxWidth().heightIn(min = remainingHeight),
                            contentAlignment = Alignment.Center,
                        ) {
                            Box(Modifier.padding(start = 24.dp, end = 24.dp, bottom = 80.dp)) {
                                WalletCardDeck(
                                    wallets = wallets,
                                    fmt = currencyFormatter,
                                    onSelectWallet = { wallet -> showWalletDetailScreen(host, wallet) },
                                )
                            }
                        }
                    }
                } else {
                    WalletPocketsView(
                        pockets = pockets,
                        totalPocketsAmount = totalPocketsAmount,
                        transactions = state.transactions,
                        fmt = currencyFormatter,
                        modifier = if (pockets.isEmpty()) Modifier.fillMaxWidth().height(remainingHeight) else Modifier,
                    )
                }
                if ((selectedSegment == 0 && wallets.isNotEmpty()) || (selectedSegment == 1 && pockets.isNotEmpty())) {
                    Spacer(Modifier.height(140.dp))
                }
            }
        }
    }
}
