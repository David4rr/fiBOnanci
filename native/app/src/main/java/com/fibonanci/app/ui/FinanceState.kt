package com.fibonanci.app.ui

import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.domain.FinancialHealthReport
import com.fibonanci.app.domain.FinancialHealthService
import com.fibonanci.app.domain.MonthlyCashflow
import com.fibonanci.app.domain.SafeToSpendMetrics
import com.fibonanci.app.domain.SafeToSpendService

enum class FinanceStatus { Initial, Loading, Success, Failure }

// the two looks of the app: the full tactile card ui, or the plain list-first one
enum class UiStyle { david4rr, iblameraihan }

data class FinanceState(
    val status: FinanceStatus = FinanceStatus.Initial,
    val wallets: List<WalletEntry> = emptyList(),
    val categories: List<CategoryEntry> = emptyList(),
    val transactions: List<TransactionEntry> = emptyList(),
    val subscriptions: List<SubscriptionEntry> = emptyList(),
    val pockets: List<PocketEntry> = emptyList(),
    val profiles: List<ProfileEntry> = emptyList(),
    val activeProfile: ProfileEntry? = null,
    val safeToSpendWalletIds: Set<String>? = null, // null = all wallets
    val budgetCycleDay: Int = 1,
    val isBalanceHidden: Boolean = false,
    val isHighRefreshRate: Boolean = true,
    val exchangeRateVersion: Int = 0,
    val errorMessage: String? = null,
    val uiStyle: UiStyle = UiStyle.david4rr,
    val metrics: SafeToSpendMetrics = SafeToSpendService.calculate(
        wallets = wallets,
        subscriptions = subscriptions,
        selectedWalletIds = safeToSpendWalletIds,
        cycleDay = budgetCycleDay,
    ),
    val monthlyCashflow: MonthlyCashflow = CashflowAnalyticsService.calculateMonthlyCashflow(transactions),
    val healthReport: FinancialHealthReport = FinancialHealthService.evaluate(
        wallets = wallets,
        pockets = pockets,
        subscriptions = subscriptions,
        monthlyCashflow = monthlyCashflow,
        safeToSpend = metrics,
        monthlyIncomeTarget = (activeProfile ?: profiles.firstOrNull { it.isActive })?.monthlyIncomeTarget,
    ),
) {
    val profile: ProfileEntry
        get() = activeProfile ?: profiles.firstOrNull { it.isActive } ?: profiles.firstOrNull() ?: defaultFallback

    // a loaded database without any profile means the user has not introduced themselves yet
    val needsOnboarding: Boolean
        get() = status == FinanceStatus.Success && profiles.isEmpty()

    // rebuilds the derived metrics after any of their inputs changed
    fun withDerived(): FinanceState {
        val nextMetrics = SafeToSpendService.calculate(
            wallets = wallets,
            subscriptions = subscriptions,
            selectedWalletIds = safeToSpendWalletIds,
            cycleDay = budgetCycleDay,
        )
        val nextCashflow = CashflowAnalyticsService.calculateMonthlyCashflow(transactions)
        return copy(
            metrics = nextMetrics,
            monthlyCashflow = nextCashflow,
            healthReport = FinancialHealthService.evaluate(
                wallets = wallets,
                pockets = pockets,
                subscriptions = subscriptions,
                monthlyCashflow = nextCashflow,
                safeToSpend = nextMetrics,
                monthlyIncomeTarget = (activeProfile ?: profiles.firstOrNull { it.isActive })?.monthlyIncomeTarget,
            ),
        )
    }

    companion object {
        // blank stand-in for the instant before the profile row is loaded
        private val defaultFallback = ProfileEntry(id = "loading", username = "", fullName = "", createdAt = 0, updatedAt = 0)
    }
}
