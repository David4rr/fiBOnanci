package com.fibonanci.app.domain

import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry

// domain engine for personal finance health diagnostics
object FinancialHealthService {
    // evaluates financial health from liquid assets, pockets, recurring bills, cashflow and pacing
    @Suppress("UNUSED_PARAMETER")
    fun evaluate(
        wallets: List<WalletEntry>,
        pockets: List<PocketEntry>,
        subscriptions: List<SubscriptionEntry>,
        monthlyCashflow: MonthlyCashflow,
        safeToSpend: SafeToSpendMetrics,
        referenceDate: Long? = null,
        monthlyIncomeTarget: Double? = null,
    ): FinancialHealthReport {
        var totalLiquidAssets = 0.0
        for (w in wallets) totalLiquidAssets += w.balance

        var totalPocketsAmount = 0.0
        var emergencyAndRetirementPockets = 0.0
        for (p in pockets) {
            totalPocketsAmount += p.currentAmount
            if (p.type == "emergency" || p.type == "retirement" || p.type == "savings") {
                emergencyAndRetirementPockets += p.currentAmount
            }
        }

        var monthlyExpenseBenchmark = monthlyCashflow.expense
        if (monthlyExpenseBenchmark <= 0) {
            var subSum = 0.0
            for (s in subscriptions) subSum += s.cost
            monthlyExpenseBenchmark = if (subSum > 0) subSum else 1000000.0
        }

        var monthlyIncomeBenchmark = monthlyCashflow.income
        if (monthlyIncomeBenchmark <= 0) {
            monthlyIncomeBenchmark = if (monthlyIncomeTarget != null && monthlyIncomeTarget > 0) {
                monthlyIncomeTarget
            } else if (monthlyExpenseBenchmark > 0) {
                monthlyExpenseBenchmark
            } else {
                1000000.0
            }
        }

        // pilar 1: emergency runway (30%)
        val totalEmergencyBuffer = totalLiquidAssets + emergencyAndRetirementPockets
        val runwayMonths = if (monthlyExpenseBenchmark > 0) totalEmergencyBuffer / monthlyExpenseBenchmark else 0.0

        val emergencyScore = when {
            runwayMonths >= 6.0 -> 100.0
            runwayMonths >= 3.0 -> 70.0 + ((runwayMonths - 3.0) / 3.0) * 30.0
            runwayMonths >= 1.0 -> 40.0 + ((runwayMonths - 1.0) / 2.0) * 30.0
            else -> runwayMonths.coerceIn(0.0, 1.0) * 40.0
        }

        val emergencyPillar = HealthPillarMetric(
            title = "Dana Darurat (Runway)",
            description = "Kemampuan bertahan jika tanpa pemasukan",
            score = emergencyScore.coerceIn(0.0, 100.0),
            displayValue = "${runwayMonths.toFixed(1)} Bulan",
            benchmark = "Ideal: ≥ 3–6 Bulan",
            isHealthy = runwayMonths >= 3.0,
        )

        // pilar 2: fixed commitment ratio (25%)
        var totalRecurringBills = 0.0
        for (s in subscriptions) totalRecurringBills += s.cost

        val commitmentRatio = if (monthlyIncomeBenchmark > 0) (totalRecurringBills / monthlyIncomeBenchmark) * 100.0 else 0.0

        val commitmentScore = when {
            commitmentRatio <= 20.0 -> 100.0
            commitmentRatio <= 35.0 -> 80.0 + ((35.0 - commitmentRatio) / 15.0) * 20.0
            commitmentRatio <= 50.0 -> 50.0 + ((50.0 - commitmentRatio) / 15.0) * 30.0
            else -> (100.0 - commitmentRatio).coerceIn(10.0, 50.0)
        }

        val commitmentPillar = HealthPillarMetric(
            title = "Beban Tagihan Tetap",
            description = "Porsi langganan & cicilan dari pemasukan",
            score = commitmentScore.coerceIn(0.0, 100.0),
            displayValue = "${commitmentRatio.toFixed(0)}%",
            benchmark = "Ideal: ≤ 30%",
            isHealthy = commitmentRatio <= 35.0,
        )

        // pilar 3: net savings margin (25%)
        val netSavings = monthlyCashflow.income - monthlyCashflow.expense
        val savingsMarginPercent = if (monthlyIncomeBenchmark > 0) (netSavings / monthlyIncomeBenchmark) * 100.0 else 0.0

        val savingsScore = when {
            savingsMarginPercent >= 20.0 -> 100.0
            savingsMarginPercent >= 10.0 -> 70.0 + ((savingsMarginPercent - 10.0) / 10.0) * 30.0
            savingsMarginPercent >= 0.0 -> 40.0 + (savingsMarginPercent / 10.0) * 30.0
            else -> (40.0 + savingsMarginPercent).coerceIn(0.0, 40.0)
        }

        val savingsPillar = HealthPillarMetric(
            title = "Margin Tabungan Bersih",
            description = "Sisa arus kas yang berhasil disimpan",
            score = savingsScore.coerceIn(0.0, 100.0),
            displayValue = "${savingsMarginPercent.toFixed(0)}%",
            benchmark = "Ideal: ≥ 15–20%",
            isHealthy = savingsMarginPercent >= 10.0,
        )

        // pilar 4: spend pacing (20%)
        val pacingScore = when (safeToSpend.healthStatus) {
            FinancialHealthStatus.comfortable -> 100.0
            FinancialHealthStatus.caution -> 65.0
            FinancialHealthStatus.deficit -> 25.0
        }

        val pacingPillar = HealthPillarMetric(
            title = "Disiplin Belanja Harian",
            description = "Kepatuhan pengeluaran terhadap batas aman",
            score = pacingScore,
            displayValue = safeToSpend.statusLabel,
            benchmark = "Target: Sangat Aman",
            isHealthy = safeToSpend.healthStatus == FinancialHealthStatus.comfortable,
        )

        // weighted overall score
        val weightedScore = (0.30 * emergencyPillar.score) +
            (0.25 * commitmentPillar.score) +
            (0.25 * savingsPillar.score) +
            (0.20 * pacingPillar.score)

        val overallScore = weightedScore.dartRound().coerceIn(0L, 100L).toInt()

        val tier = when {
            overallScore >= 85 -> HealthTier.excellent
            overallScore >= 70 -> HealthTier.good
            overallScore >= 50 -> HealthTier.caution
            else -> HealthTier.deficit
        }

        val recs = FinancialHealthRecommendations.generate(
            runwayMonths = runwayMonths,
            commitmentRatio = commitmentRatio,
            savingsMarginPercent = savingsMarginPercent,
            safeToSpend = safeToSpend,
            pockets = pockets,
        )

        return FinancialHealthReport(
            overallScore = overallScore,
            tier = tier,
            emergencyRunway = emergencyPillar,
            fixedCommitment = commitmentPillar,
            savingsMargin = savingsPillar,
            spendPacing = pacingPillar,
            recommendations = recs,
            totalLiquidAssets = totalLiquidAssets,
            totalPocketsAmount = totalPocketsAmount,
        )
    }
}
