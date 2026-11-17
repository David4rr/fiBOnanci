package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.smartinput.SmartInputSource
import com.fibonanci.app.core.smartinput.SmartTransactionDraft
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch
import kotlin.math.roundToLong

private const val TRANSFER_CATEGORY_ID = "11111111-1111-4111-8111-111111111111"

fun showTransactionModal(
    host: ModalHost,
    initialWalletId: String? = null,
    initialInputSource: SmartInputSource? = null,
    initialDraft: SmartTransactionDraft? = null,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        TransactionModal(
            initialWalletId = initialWalletId,
            initialInputSource = initialInputSource,
            initialDraft = initialDraft,
            onClose = dismiss,
            onSaved = dismiss,
        )
    }
}

// onClose / onSaved replace the dart Navigator.pop fallback; showTransactionModal wires both to dismiss
@Composable
fun TransactionModal(
    initialWalletId: String? = null,
    initialInputSource: SmartInputSource? = null,
    initialDraft: SmartTransactionDraft? = null,
    onClose: (() -> Unit)? = null,
    onSaved: (() -> Unit)? = null,
    isInline: Boolean = false,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val haptic = LocalHapticFeedback.current
    val scope = rememberCoroutineScope()
    val state by vm.state.collectAsStateWithLifecycle()

    var amount by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var type by remember { mutableStateOf("expense") }
    var selectedWalletId by remember { mutableStateOf<String?>(null) }
    var selectedDestinationWalletId by remember { mutableStateOf<String?>(null) }
    var selectedCategoryId by remember { mutableStateOf<String?>(null) }
    var selectedTargetProfileId by remember { mutableStateOf<String?>(null) }
    var targetProfileWallets by remember { mutableStateOf<List<WalletEntry>>(emptyList()) }

    fun applyDraft(draft: SmartTransactionDraft) {
        type = draft.type
        val a = draft.amount
        if (a != null && a > 0) amount = RupiahInputFormatter.format(a.roundToLong().toDouble())
        selectedWalletId = draft.walletId ?: selectedWalletId
        selectedDestinationWalletId = draft.destinationWalletId ?: selectedDestinationWalletId
        selectedCategoryId = draft.categoryId ?: selectedCategoryId
        if (!draft.notes.isNullOrEmpty()) notes = draft.notes
    }

    // init state (dart initState)
    remember {
        val s = vm.state.value
        selectedTargetProfileId = s.profile.id
        if (s.wallets.isNotEmpty()) {
            selectedWalletId = if (initialWalletId != null && s.wallets.any { it.id == initialWalletId }) initialWalletId else s.wallets.first().id
            val others = s.wallets.filter { it.id != selectedWalletId }
            selectedDestinationWalletId = if (others.isNotEmpty()) others.first().id else if (s.wallets.size > 1) s.wallets[1].id else null
        }
        val initialCats = s.categories.filter { it.type == type }
        if (initialCats.isNotEmpty()) selectedCategoryId = initialCats.first().id
        if (initialDraft != null) applyDraft(initialDraft)
        true
    }

    fun triggerSmartInput(source: SmartInputSource) {
        scope.launch {
            val s = vm.state.value
            val draft = executeSmartTransactionCapture(
                host, source = source, wallets = s.wallets, categories = s.categories, preferredWalletId = selectedWalletId,
            )
            if (draft == null || !draft.hasMeaningfulData) return@launch
            applyDraft(draft)
            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        }
    }

    LaunchedEffect(Unit) {
        if (initialInputSource != null) triggerSmartInput(initialInputSource)
    }

    fun handleTargetProfileChanged(profileId: String, currentProfileId: String) {
        selectedTargetProfileId = profileId
        if (profileId != currentProfileId) {
            scope.launch {
                val wallets = vm.repository.getWallets(profileId = profileId)
                if (selectedTargetProfileId == profileId) {
                    targetProfileWallets = wallets
                    selectedDestinationWalletId = wallets.firstOrNull()?.id
                }
            }
        } else {
            val others = vm.state.value.wallets.filter { it.id != selectedWalletId }
            selectedDestinationWalletId = others.firstOrNull()?.id
        }
    }

    fun onSave() {
        val s = vm.state.value
        val value = AppCurrency.parseInputToIdr(amount, s.profile.currency)
        val walletId = selectedWalletId
        if (value <= 0 || walletId == null || (type != "transfer" && selectedCategoryId == null)) return
        val isCross = type == "transfer" && selectedTargetProfileId != null && selectedTargetProfileId != s.profile.id
        if (isCross && selectedDestinationWalletId == null) {
            host.showSnackBar("Pilih rekening tujuan di profil tujuan!")
            return
        }
        if (!isCross && type == "transfer" && (selectedDestinationWalletId == null || selectedDestinationWalletId == walletId)) {
            host.showSnackBar("Pilih rekening tujuan yang berbeda dari rekening asal!")
            return
        }
        val note = notes.trim().ifEmpty { null }
        if (isCross) {
            vm.transferCrossProfile(
                sourceWalletId = walletId,
                destinationWalletId = selectedDestinationWalletId!!,
                amount = value,
                notes = note,
                transactionDate = nowMillis(),
            )
        } else {
            vm.addTransaction(
                walletId = walletId,
                amount = value,
                type = type,
                transactionDate = nowMillis(),
                categoryId = if (type == "transfer") TRANSFER_CATEGORY_ID else selectedCategoryId!!,
                destinationWalletId = if (type == "transfer") selectedDestinationWalletId else null,
                notes = note,
            )
        }
        onSaved?.invoke()
    }

    // per-build reconciliation (dart build)
    if (selectedWalletId == null || state.wallets.none { it.id == selectedWalletId }) {
        selectedWalletId = state.wallets.firstOrNull()?.id
    }
    val isCross = type == "transfer" && selectedTargetProfileId != null && selectedTargetProfileId != state.profile.id
    val destWallets = if (isCross) targetProfileWallets else state.wallets.filter { it.id != selectedWalletId }
    if (selectedDestinationWalletId == null || destWallets.none { it.id == selectedDestinationWalletId }) {
        selectedDestinationWalletId = destWallets.firstOrNull()?.id
    }
    val matchingCats = state.categories.filter { it.type == type }
    if (type != "transfer" && (selectedCategoryId == null || matchingCats.none { it.id == selectedCategoryId })) {
        selectedCategoryId = matchingCats.firstOrNull()?.id
    }

    Column(
        Modifier
            .fillMaxWidth()
            .clip(if (isInline) RectangleShape else RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .background(AppColors.canvasCardSurface)
            .then(if (isInline) Modifier else Modifier.windowInsetsPadding(WindowInsets.navigationBars))
            .verticalScroll(rememberScrollState())
            .padding(
                if (isInline) PaddingValues(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 48.dp)
                else PaddingValues(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 24.dp),
            ),
    ) {
        if (!isInline) TransactionModalHeaderView(type = type, onClose = { onClose?.invoke() })
        TransactionFormInputs(
            type = type,
            onTypeChanged = { t ->
                type = t
                selectedCategoryId = state.categories.firstOrNull { it.type == t }?.id
            },
            amount = amount,
            onAmountChange = { amount = it },
            selectedWalletId = selectedWalletId,
            wallets = state.wallets,
            onWalletChanged = { selectedWalletId = it },
            profiles = state.profiles,
            currentProfile = state.profile,
            selectedTargetProfileId = selectedTargetProfileId ?: state.profile.id,
            onTargetProfileChanged = { handleTargetProfileChanged(it, state.profile.id) },
            selectedDestinationWalletId = selectedDestinationWalletId,
            destWallets = destWallets,
            onDestinationWalletChanged = { selectedDestinationWalletId = it },
            selectedCategoryId = selectedCategoryId,
            matchingCats = matchingCats,
            onCategoryChanged = { selectedCategoryId = it },
            notes = notes,
            onNotesChange = { notes = it },
            onCancel = { onClose?.invoke() },
            onSave = { onSave() },
        )
    }
}
