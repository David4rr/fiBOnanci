package com.fibonanci.app.ui

import android.app.Application
import android.content.Context
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.fibonanci.app.FibonanciApp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.reminders.LocalNotificationService
import com.fibonanci.app.data.FinanceRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.json.JSONObject

val LocalFinance = staticCompositionLocalOf<FinanceViewModel> { error("FinanceViewModel not provided") }

// single source of ui state: mirrors the database through flows scoped to the active profile.
@OptIn(ExperimentalCoroutinesApi::class)
class FinanceViewModel(app: Application) : AndroidViewModel(app) {
    val repository: FinanceRepository = (app as FibonanciApp).repository

    private val prefs = app.getSharedPreferences("fibonanci_ui", Context.MODE_PRIVATE)
    private val _state = MutableStateFlow(
        FinanceState(uiStyle = UiStyle.valueOf(prefs.getString("ui_style", UiStyle.david4rr.name)!!))
    )
    val state: StateFlow<FinanceState> = _state.asStateFlow()

    // budget cycle day and safe-to-spend wallet selection are remembered per profile for the session
    private val profileCycleDays = mutableMapOf<String, Int>()
    private val profileStsWallets = mutableMapOf<String, Set<String>?>()
    private val activeProfileId = MutableStateFlow<String?>(null)
    private var watchers: Job? = null

    init {
        loadFinanceData()
    }

    private fun change(transform: (FinanceState) -> FinanceState) = _state.update { transform(it).withDerived() }

    // runs a mutation; the database flows push the result back into the state.
    private fun mutate(errorPrefix: String, block: suspend () -> Unit) {
        viewModelScope.launch {
            try {
                block()
            } catch (e: Exception) {
                _state.update { it.copy(errorMessage = "$errorPrefix: ${e.message}") }
            }
        }
    }

    fun loadFinanceData() {
        _state.update { it.copy(status = FinanceStatus.Loading) }
        viewModelScope.launch {
            try {
                val profiles = repository.getProfiles()
                val active = profiles.firstOrNull { it.isActive } ?: profiles.firstOrNull()
                val pId = active?.id
                val wallets = repository.getWallets(pId)
                val categories = repository.getCategories()
                val subscriptions = repository.getSubscriptions(pId)
                val transactions = repository.getTransactions(pId, 5000)
                val pockets = repository.getPockets(pId)
                change {
                    it.copy(
                        status = FinanceStatus.Success,
                        wallets = wallets,
                        categories = categories,
                        subscriptions = subscriptions,
                        transactions = transactions,
                        pockets = pockets,
                        profiles = profiles,
                        activeProfile = active,
                    )
                }
                activeProfileId.value = pId
                startWatchers()
            } catch (e: Exception) {
                _state.update { it.copy(status = FinanceStatus.Failure, errorMessage = e.toString()) }
            }
        }
    }

    private fun startWatchers() {
        if (watchers != null) return
        watchers = viewModelScope.launch {
            val profileId = activeProfileId.filterNotNull()
            launch {
                repository.watchProfiles().collect { profiles ->
                    val active = profiles.firstOrNull { it.isActive } ?: profiles.firstOrNull()
                    val switched = active != null && active.id != activeProfileId.value
                    change {
                        if (!switched) return@change it.copy(profiles = profiles, activeProfile = active)
                        val stsWallets = profileStsWallets[active!!.id]
                        it.copy(
                            profiles = profiles,
                            activeProfile = active,
                            budgetCycleDay = profileCycleDays[active.id] ?: 1,
                            safeToSpendWalletIds = stsWallets,
                        )
                    }
                    if (active != null) activeProfileId.value = active.id
                }
            }
            launch { repository.watchCategories().collect { categories -> change { it.copy(categories = categories) } } }
            launch {
                profileId.flatMapLatest { repository.watchWallets(it) }.collect { wallets ->
                    change {
                        // drop selected wallets that no longer exist
                        val ids = wallets.map { w -> w.id }.toSet()
                        it.copy(wallets = wallets, safeToSpendWalletIds = it.safeToSpendWalletIds?.intersect(ids))
                    }
                }
            }
            launch {
                profileId.flatMapLatest { repository.watchRecentTransactions(it, 5000) }
                    .collect { transactions -> change { it.copy(transactions = transactions) } }
            }
            launch {
                profileId.flatMapLatest { repository.watchActiveSubscriptions(it) }.collect { subscriptions ->
                    change { it.copy(subscriptions = subscriptions) }
                    LocalNotificationService.syncAllSubscriptionReminders(getApplication(), subscriptions)
                }
            }
            launch { profileId.flatMapLatest { repository.watchPockets(it) }.collect { pockets -> change { it.copy(pockets = pockets) } } }
        }
    }

    // ---------------------------------------------------------------- transactions

    fun addTransaction(
        walletId: String,
        categoryId: String,
        amount: Double,
        type: String,
        destinationWalletId: String? = null,
        notes: String? = null,
        transactionDate: Long? = null,
        source: String = "manual",
        externalRef: String? = null,
    ) = mutate("Gagal menambah transaksi") {
        repository.addTransaction(walletId, categoryId, amount, type, destinationWalletId, notes, transactionDate, source, externalRef, state.value.profile.id)
    }

    fun transferCrossProfile(
        sourceWalletId: String,
        destinationWalletId: String,
        amount: Double,
        notes: String? = null,
        transactionDate: Long? = null,
        source: String = "manual",
    ) = mutate("Gagal transfer lintas profil") {
        repository.transferCrossProfileFunds(sourceWalletId, destinationWalletId, amount, notes, transactionDate, source)
    }

    fun updateTransaction(
        transactionId: String,
        newWalletId: String,
        newAmount: Double,
        newType: String,
        newCategoryId: String,
        newDestinationWalletId: String? = null,
        newNotes: String? = null,
    ) = mutate("Gagal update transaksi") {
        repository.updateTransaction(transactionId, newWalletId, newAmount, newType, newCategoryId, newDestinationWalletId, newNotes)
    }

    fun deleteTransaction(transactionId: String) = mutate("Gagal hapus transaksi") { repository.deleteTransaction(transactionId) }

    // ---------------------------------------------------------------- subscriptions

    fun addSubscription(
        title: String,
        cost: Double,
        dueDay: Int,
        walletId: String,
        categoryId: String,
        autoDeduct: Boolean = false,
        billingCycle: String = "monthly",
        isInstallment: Boolean = false,
        totalCycles: Int? = null,
        deadlineDate: Long? = null,
    ) = mutate("Gagal menambah langganan") {
        repository.addSubscription(title, cost, dueDay, walletId, categoryId, autoDeduct, billingCycle, isInstallment, totalCycles, deadlineDate, state.value.profile.id)
    }

    fun updateSubscription(
        subscriptionId: String,
        title: String,
        cost: Double,
        dueDay: Int,
        walletId: String,
        categoryId: String,
        autoDeduct: Boolean = false,
        billingCycle: String = "monthly",
        status: String = "active",
        isInstallment: Boolean = false,
        totalCycles: Int? = null,
        paidCycles: Int = 0,
        deadlineDate: Long? = null,
    ) = mutate("Gagal update langganan") {
        repository.updateSubscription(subscriptionId, title, cost, dueDay, walletId, categoryId, autoDeduct, billingCycle, status, isInstallment, totalCycles, paidCycles, deadlineDate)
    }

    fun deleteSubscription(subscriptionId: String) = mutate("Gagal hapus langganan") {
        LocalNotificationService.cancelSubscriptionReminders(getApplication(), subscriptionId)
        repository.deleteSubscription(subscriptionId)
    }

    fun markSubscriptionPaid(subscriptionId: String, actualAmount: Double? = null) = mutate("Gagal menandai lunas") {
        repository.markSubscriptionAsPaid(subscriptionId, actualAmount)
    }

    // ---------------------------------------------------------------- wallets

    fun updateWalletBalance(walletId: String, newBalance: Double, accountNumber: String? = null) = mutate("Gagal update saldo") {
        repository.updateWalletBalance(walletId, newBalance, accountNumber)
    }

    fun addWallet(
        name: String,
        type: String,
        accountNumber: String? = null,
        initialBalance: Double,
        colorHex: String,
        iconName: String,
        boundPackageName: String? = null,
    ) = mutate("Gagal menambah rekening") {
        repository.addWallet(name, type, accountNumber, initialBalance, colorHex, iconName, boundPackageName, state.value.profile.id)
    }

    fun deleteWallet(walletId: String) = mutate("Gagal menghapus rekening") { repository.deleteWallet(walletId) }

    fun bindWalletToPackage(walletId: String, packageName: String, isEnabled: Boolean = true) = mutate("Gagal menghubungkan aplikasi") {
        repository.bindWalletToPackage(walletId, packageName, isEnabled, state.value.profile.id)
    }

    fun unbindPackage(packageName: String) = mutate("Gagal memutuskan aplikasi") { repository.unbindPackage(packageName) }

    fun setSafeToSpendWallets(walletIds: Set<String>?) {
        profileStsWallets[state.value.profile.id] = walletIds
        change { it.copy(safeToSpendWalletIds = walletIds) }
    }

    // ---------------------------------------------------------------- pockets

    fun addPocket(
        name: String,
        type: String,
        targetAmount: Double? = null,
        initialAmount: Double = 0.0,
        colorHex: String,
        iconName: String,
        targetDate: Long? = null,
        linkedWalletId: String? = null,
        notes: String? = null,
    ) = mutate("Gagal menambah kantong") {
        repository.addPocket(name, type, targetAmount, initialAmount, colorHex, iconName, targetDate, linkedWalletId, notes, state.value.profile.id)
    }

    fun updatePocket(
        pocketId: String,
        name: String,
        type: String,
        targetAmount: Double? = null,
        colorHex: String,
        iconName: String,
        targetDate: Long? = null,
        linkedWalletId: String? = null,
        notes: String? = null,
    ) = mutate("Gagal memperbarui kantong") {
        repository.updatePocket(pocketId, name, type, targetAmount, colorHex, iconName, targetDate, linkedWalletId, notes)
    }

    fun deletePocket(pocketId: String) = mutate("Gagal menghapus kantong") { repository.deletePocket(pocketId) }

    fun transferPocketFunds(pocketId: String, walletId: String, amount: Double, isDepositToPocket: Boolean, notes: String? = null) =
        mutate("Gagal memindahkan dana kantong") {
            repository.transferPocketFunds(pocketId, walletId, amount, isDepositToPocket, notes)
        }

    // ---------------------------------------------------------------- profiles

    fun addProfile(
        username: String,
        fullName: String,
        email: String? = null,
        phone: String? = null,
        avatarPath: String? = null,
        occupation: String? = null,
        bio: String? = null,
        currency: String = "IDR",
        monthlyIncomeTarget: Double? = null,
        setActive: Boolean = false,
    ) = mutate("Gagal menambah profil") {
        repository.addProfile(username, fullName, email, phone, avatarPath, occupation, bio, currency, monthlyIncomeTarget, setActive)
    }

    fun updateProfile(
        profileId: String,
        username: String,
        fullName: String,
        email: String? = null,
        phone: String? = null,
        avatarPath: String? = null,
        occupation: String? = null,
        bio: String? = null,
        currency: String = "IDR",
        monthlyIncomeTarget: Double? = null,
    ) = mutate("Gagal memperbarui profil") {
        repository.updateProfile(profileId, username, fullName, email, phone, avatarPath, occupation, bio, currency, monthlyIncomeTarget)
    }

    fun deleteProfile(profileId: String) = mutate("Gagal menghapus profil") {
        profileCycleDays.remove(profileId)
        profileStsWallets.remove(profileId)
        repository.deleteProfile(profileId)
    }

    fun setActiveProfile(profileId: String) = mutate("Gagal mengganti profil aktif") { repository.setActiveProfile(profileId) }

    fun completeOnboarding(
        fullName: String,
        username: String,
        occupation: String?,
        monthlyIncomeTarget: Double?,
        walletName: String,
        walletType: String,
        walletBalance: Double,
        style: UiStyle,
    ) = mutate("Gagal menyimpan profil") {
        setUiStyle(style)
        repository.completeOnboarding(fullName, username, occupation, monthlyIncomeTarget, walletName, walletType, walletBalance)
    }

    // ---------------------------------------------------------------- settings

    fun setBudgetCycleDay(cycleDay: Int) {
        val clamped = cycleDay.coerceIn(1, 31)
        profileCycleDays[state.value.profile.id] = clamped
        change { it.copy(budgetCycleDay = clamped) }
    }

    fun toggleBalanceVisibility(hidden: Boolean? = null) = _state.update { it.copy(isBalanceHidden = hidden ?: !it.isBalanceHidden) }

    fun setHighRefreshRate(enabled: Boolean) = _state.update { it.copy(isHighRefreshRate = enabled) }

    // called by the ui once it has shown the error to the user
    fun clearError() = _state.update { it.copy(errorMessage = null) }

    fun setUiStyle(style: UiStyle) {
        prefs.edit().putString("ui_style", style.name).apply()
        _state.update { it.copy(uiStyle = style) }
    }

    fun setExchangeRate(currencyCode: String, rateToIdr: Double) {
        if (rateToIdr <= 0) return
        AppCurrency.setRate(currencyCode, rateToIdr)
        _state.update { it.copy(exchangeRateVersion = it.exchangeRateVersion + 1) }
    }

    fun syncExchangeRates() {
        viewModelScope.launch {
            if (AppCurrency.syncLiveRates()) _state.update { it.copy(exchangeRateVersion = it.exchangeRateVersion + 1) }
        }
    }

    fun addCategory(name: String, type: String, iconName: String = "category", colorHex: String = "#D4F442") =
        mutate("Gagal menambah kategori") { repository.addCategory(name, type, iconName, colorHex) }

    fun deleteCategory(categoryId: String) = mutate("Gagal menghapus kategori") { repository.deleteCategory(categoryId) }

    fun clearProfileTransactions(profileId: String? = null) = mutate("Gagal membersihkan transaksi") {
        repository.clearProfileTransactions(profileId ?: state.value.profile.id)
    }

    fun importJsonBackup(data: JSONObject) = mutate("Gagal memulihkan cadangan JSON") {
        repository.restoreJsonBackup(data)
        loadFinanceData()
    }
}
