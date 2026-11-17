package com.fibonanci.app.domain

import com.fibonanci.app.data.db.PocketEntry

// generates qualitative recommendations based on financial pillars
object FinancialHealthRecommendations {
    fun generate(
        runwayMonths: Double,
        commitmentRatio: Double,
        savingsMarginPercent: Double,
        safeToSpend: SafeToSpendMetrics,
        pockets: List<PocketEntry>,
    ): List<String> {
        val recs = mutableListOf<String>()

        if (runwayMonths < 3.0) {
            recs.add(
                "Dana daruratmu (${runwayMonths.toFixed(1)} bulan) masih di bawah rekomendasi 3 bulan. Prioritaskan isi Kantong Darurat secara berkala.",
            )
        }
        if (commitmentRatio > 35.0) {
            recs.add(
                "Beban tagihan rutin mencapai ${commitmentRatio.toFixed(0)}% dari pemasukan. Evaluasi langganan atau tagihan yang kurang bernilai guna.",
            )
        }
        if (savingsMarginPercent < 10.0) {
            recs.add(
                "Margin tabungan bulan ini ${savingsMarginPercent.toFixed(0)}%. Terapkan sistem \"Pay Yourself First\" di awal tanggal gajian ke Kantong Impian.",
            )
        }
        if (safeToSpend.healthStatus != FinancialHealthStatus.comfortable) {
            recs.add(
                "Pacing belanja harian mendekati batas aman. Rem pengeluaran variabel agar tidak defisit di akhir bulan.",
            )
        }
        if (pockets.isEmpty()) {
            recs.add(
                "Kamu belum memiliki Kantong Tabungan. Buat kantong alokasi (Masa Tua / Dana Darurat) untuk memisahkan dana jajan dari simpanan.",
            )
        }
        if (recs.isEmpty()) {
            recs.add(
                "Kondisi keuanganmu luar biasa prima! Pertahankan rasio simpanan dan lanjutkan alokasi jangka panjang.",
            )
        }

        return recs
    }
}
