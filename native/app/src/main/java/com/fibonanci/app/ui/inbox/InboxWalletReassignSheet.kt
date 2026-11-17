package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccountBalanceWallet
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.FinanceRepository
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

fun showInboxWalletReassignSheet(
    host: ModalHost,
    repository: FinanceRepository,
    currentWalletId: String? = null,
    onResult: (WalletEntry) -> Unit,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        InboxWalletReassignSheet(
            repository = repository,
            currentWalletId = currentWalletId,
            onSelect = { w ->
                dismiss()
                onResult(w)
            },
        )
    }
}

object InboxWalletReassignSheet {
    // picks a new wallet, moves the auto-logged transaction there and returns the updated item + snack message
    fun reassignItem(
        host: ModalHost,
        repository: FinanceRepository,
        item: Map<String, Any?>,
        scope: CoroutineScope,
        onResult: (updatedItem: Map<String, Any?>, message: String) -> Unit,
    ) {
        val currentWalletId = item["walletId"] as? String
        showInboxWalletReassignSheet(host, repository, currentWalletId) { newWallet ->
            if (newWallet.id == currentWalletId) return@showInboxWalletReassignSheet
            scope.launch {
                val txId = item["transactionId"] as? String
                if (txId != null) {
                    val tx = repository.getTransactionById(txId)
                    if (tx != null) {
                        repository.updateTransaction(
                            transactionId = txId,
                            newWalletId = newWallet.id,
                            newAmount = tx.amount,
                            newType = tx.type,
                            newCategoryId = tx.categoryId,
                            newDestinationWalletId = tx.destinationWalletId,
                            newNotes = tx.notes,
                        )
                    }
                }
                val prof: ProfileEntry? = newWallet.profileId?.let { repository.getProfileById(it) }
                val updated = item + mapOf(
                    "walletId" to newWallet.id,
                    "walletName" to newWallet.name,
                    "profileId" to newWallet.profileId,
                    "profileName" to (prof?.fullName ?: prof?.username),
                )
                val pName = prof?.fullName ?: prof?.username ?: "Akun Utama"
                onResult(updated, "Dialihkan ke $pName • ${newWallet.name}")
            }
        }
    }
}

@Composable
fun InboxWalletReassignSheet(
    repository: FinanceRepository,
    currentWalletId: String? = null,
    onSelect: (WalletEntry) -> Unit,
    modifier: Modifier = Modifier,
) {
    var wallets by remember { mutableStateOf<List<WalletEntry>>(emptyList()) }
    var profiles by remember { mutableStateOf<List<ProfileEntry>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        wallets = repository.getAllActiveWallets()
        profiles = repository.getProfiles().filter { !it.isDeleted }
        isLoading = false
    }

    val maxListHeight = (LocalConfiguration.current.screenHeightDp * 0.48f).dp
    val topBorder = Color.White.copy(alpha = 0.08f)

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(Color(0xFF0C0D11), RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .drawBehind { drawLine(topBorder, Offset(0f, 0f), Offset(size.width, 0f), 1.dp.toPx()) }
            .padding(start = 20.dp, top = 14.dp, end = 20.dp, bottom = 28.dp),
    ) {
        ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
        Text(
            "Pilih Dompet / Workspace",
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                letterSpacing = (-0.3).sp,
            ),
        )
        Spacer(Modifier.height(4.dp))
        Text(
            "Alihkan transaksi auto-log ini ke rekening atau akun yang benar.",
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, color = AppColors.textMuted),
        )
        Spacer(Modifier.height(16.dp))
        if (isLoading) {
            Box(Modifier.fillMaxWidth().padding(24.dp), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        } else {
            LazyColumn(
                modifier = Modifier.heightIn(max = maxListHeight),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                items(wallets, key = { "reassign_wallet_${it.id}" }) { w ->
                    val isSelected = w.id == currentWalletId
                    val prof = profiles.firstOrNull { it.id == w.profileId }
                    val shape = RoundedCornerShape(14.dp)
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = null,
                            ) { onSelect(w) }
                            .background(if (isSelected) AppColors.neoChartreuse.copy(alpha = 0.08f) else Color(0xFF161822), shape)
                            .border(
                                1.2.dp,
                                if (isSelected) AppColors.neoChartreuse.copy(alpha = 0.4f) else Color.White.copy(alpha = 0.04f),
                                shape,
                            )
                            .padding(horizontal = 14.dp, vertical = 12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Box(
                            Modifier
                                .size(38.dp)
                                .background(
                                    if (isSelected) AppColors.neoChartreuse else Color(0xFF232738),
                                    RoundedCornerShape(10.dp),
                                ),
                            contentAlignment = Alignment.Center,
                        ) {
                            Icon(
                                Icons.Rounded.AccountBalanceWallet,
                                contentDescription = null,
                                modifier = Modifier.size(18.dp),
                                tint = if (isSelected) Color.Black else Color.White.copy(alpha = 0.70f),
                            )
                        }
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(
                                w.name,
                                style = TextStyle(
                                    fontFamily = PlusJakartaSans,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.White,
                                ),
                            )
                            Spacer(Modifier.height(2.dp))
                            val account = if (!w.accountNumber.isNullOrEmpty()) w.accountNumber else w.type.uppercase()
                            Text(
                                "${prof?.fullName ?: prof?.username ?: "Akun Utama"} • $account",
                                style = TextStyle(
                                    fontFamily = PlusJakartaSans,
                                    fontSize = 11.sp,
                                    color = if (isSelected) AppColors.neoChartreuse else AppColors.textMuted,
                                    fontWeight = FontWeight.Medium,
                                ),
                            )
                        }
                        if (isSelected) {
                            Icon(
                                Icons.Rounded.CheckCircle,
                                contentDescription = null,
                                tint = AppColors.neoChartreuse,
                                modifier = Modifier.size(20.dp),
                            )
                        }
                    }
                }
            }
        }
    }
}
