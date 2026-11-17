package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material.icons.rounded.SearchOff
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.CardlessEmptyView
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun SubscriptionScreen(onAddSubscription: (() -> Unit)? = null) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()

    var filter by remember { mutableStateOf("all") }
    var walletFilter by remember { mutableStateOf<String?>(null) }
    // raw text of the search field; the filter uses the trimmed lowercase form like the dart state
    var searchText by remember { mutableStateOf("") }
    val searchQuery = searchText.trim().lowercase()

    val subscriptions = state.subscriptions
    val wallets = state.wallets
    val filtered = subscriptions.filter { sub ->
        val isPaid = sub.isPaidThisMonth()
        if (filter == "unpaid" && isPaid) return@filter false
        if (filter == "paid" && !isPaid) return@filter false
        if (walletFilter != null && sub.walletId != walletFilter) return@filter false
        if (searchQuery.isNotEmpty()) {
            val matchTitle = sub.title.lowercase().contains(searchQuery)
            val wallet = wallets.firstOrNull { it.id == sub.walletId } ?: wallets.first()
            val matchWallet = wallet.name.lowercase().contains(searchQuery)
            return@filter matchTitle || matchWallet
        }
        true
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.canvasBg)
            .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal)),
    ) {
        Column(modifier = Modifier.padding(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 8.dp)) {
            Text("Tagihan & Langganan", style = AppTypography.modalTitle)
            Spacer(Modifier.height(4.dp))
            Text("${subscriptions.size} Kartu Terdaftar • Diurutkan jatuh tempo", style = AppTypography.modalSubtitle)
        }
        if (subscriptions.isEmpty()) {
            Box(modifier = Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
                Box(Modifier.padding(start = 24.dp, end = 24.dp, bottom = 80.dp)) {
                    CardlessEmptyView(
                        icon = Icons.AutoMirrored.Outlined.ReceiptLong,
                        title = "Belum Ada Tagihan Rutin",
                        description = "Daftarkan langganan Netflix, Spotify, atau cicilan agar jatuh tempo tercatat rapi.",
                        hint = "Ketuk tombol + di bawah untuk menambahkan",
                    )
                }
            }
        } else {
            SubscriptionSearchBar(
                searchQuery = searchText,
                filter = filter,
                walletFilter = walletFilter,
                wallets = wallets,
                onSearchChanged = { searchText = it },
                onClearSearch = { searchText = "" },
                onFilterApplied = { status, walletId ->
                    filter = status
                    walletFilter = walletId
                },
                onClearStatusFilter = { filter = "all" },
                onClearWalletFilter = { walletFilter = null },
            )
            Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
                if (filtered.isEmpty()) {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Box(Modifier.padding(start = 24.dp, end = 24.dp, bottom = 80.dp)) {
                            CardlessEmptyView(
                                icon = Icons.Rounded.SearchOff,
                                title = "Tagihan Tidak Ditemukan",
                                description = if (searchQuery.isNotEmpty()) {
                                    "Tidak ada tagihan yang cocok dengan \"$searchQuery\"."
                                } else {
                                    "Tidak ada tagihan dalam filter ini."
                                },
                            )
                        }
                    }
                } else {
                    SubscriptionStackedDeck(
                        subscriptions = filtered,
                        wallets = wallets,
                        onTapCard = { sub, wallet, index ->
                            showSubscriptionCardDetailSheet(host, sub, wallet, indexOverride = index)
                        },
                    )
                }
            }
        }
    }
}
