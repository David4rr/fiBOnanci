package com.fibonanci.app.ui.inbox

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.EaseInCubic
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch

@Composable
fun PendingInboxSheet(
    initialPending: List<Map<String, Any?>>,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val scope = rememberCoroutineScope()
    val focusManager = LocalFocusManager.current

    val pending = remember { mutableStateListOf<Map<String, Any?>>().apply { addAll(initialPending) } }
    var isEditing by remember { mutableStateOf(false) }
    var editingItem by remember { mutableStateOf<Map<String, Any?>?>(null) }

    fun showSnack(msg: String, color: Color) {
        host.showSnackBar(msg, background = AppColors.canvasCardSurface, contentColor = color)
    }

    fun confirmItem(item: Map<String, Any?>) {
        NotificationBridge.confirmNotification(item)
        pending.remove(item)
        showSnack("Transaksi terkonfirmasi benar", AppColors.neoMint)
    }

    fun rejectItem(item: Map<String, Any?>) {
        scope.launch {
            NotificationBridge.rejectNotification(item, vm.repository)
            pending.remove(item)
            showSnack("Transaksi dibatalkan & saldo dipulihkan", AppColors.neoCoral)
        }
    }

    fun reassignWallet(item: Map<String, Any?>) {
        InboxWalletReassignSheet.reassignItem(host, vm.repository, item, scope) { updated, msg ->
            val index = pending.indexOf(item)
            if (index >= 0) pending[index] = updated
            showSnack(msg, AppColors.neoChartreuse)
        }
    }

    fun editItem(item: Map<String, Any?>) {
        focusManager.clearFocus()
        editingItem = item
        isEditing = true
    }

    fun cancelEdit() {
        focusManager.clearFocus()
        editingItem = null
        isEditing = false
    }

    fun saveEdit(res: Map<String, Any?>) {
        val item = editingItem ?: return
        val newAmt = (res["amount"] as Number).toDouble()
        val newType = res["type"] as String
        val newNotes = res["counterparty"] as String
        scope.launch {
            val txId = item["transactionId"] as? String
            if (txId != null) {
                val tx = vm.repository.getTransactionById(txId)
                if (tx != null) {
                    vm.repository.updateTransaction(
                        transactionId = txId,
                        newWalletId = tx.walletId,
                        newAmount = newAmt,
                        newType = newType,
                        newCategoryId = tx.categoryId,
                        newDestinationWalletId = tx.destinationWalletId,
                        newNotes = newNotes,
                    )
                }
            }
            val index = pending.indexOf(item)
            if (index >= 0) {
                pending[index] = item + mapOf("amount" to newAmt, "type" to newType, "counterparty" to newNotes)
            }
            editingItem = null
            isEditing = false
            showSnack("Transaksi berhasil disesuaikan", AppColors.neoMint)
        }
    }

    val topBorder = Color.White.copy(alpha = 0.08f)
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(Color(0xFF0C0D11), RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .drawBehind { drawLine(topBorder, Offset(0f, 0f), Offset(size.width, 0f), 1.dp.toPx()) }
            .windowInsetsPadding(WindowInsets.ime)
            .padding(start = 20.dp, top = 14.dp, end = 20.dp, bottom = 28.dp),
    ) {
        ModalGrabHandle(padding = PaddingValues(bottom = 18.dp))
        AnimatedContent(
            targetState = isEditing,
            transitionSpec = {
                fadeIn(tween(260, easing = EaseOutCubic)) togetherWith
                    fadeOut(tween(260, easing = EaseInCubic)) using
                    SizeTransform(clip = false) { _, _ -> tween(260, easing = EaseOutCubic) }
            },
            label = "inboxCrossFade",
        ) { editing ->
            if (!editing) {
                InboxReviewDeckView(
                    pending = pending,
                    onConfirm = ::confirmItem,
                    onReject = ::rejectItem,
                    onReassign = ::reassignWallet,
                    onEdit = ::editItem,
                    onDismiss = onDismiss,
                )
            } else {
                val item = editingItem
                if (item != null) {
                    InboxInlineEditForm(
                        initialAmount = (item["amount"] as? Number)?.toDouble() ?: 0.0,
                        initialType = (item["type"] as? String) ?: "expense",
                        initialCounterparty = (item["counterparty"] as? String) ?: "",
                        walletName = item["walletName"] as? String,
                        onSave = ::saveEdit,
                        onCancel = ::cancelEdit,
                    )
                }
            }
        }
    }
}
