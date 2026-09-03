import '../../data/database/app_database.dart';
import 'safe_to_spend_service.dart';

/// Helper class generating qualitative recommendations based on financial pillars.
class FinancialHealthRecommendations {
  static List<String> generate({
    required double runwayMonths,
    required double commitmentRatio,
    required double savingsMarginPercent,
    required SafeToSpendMetrics safeToSpend,
    required List<PocketEntry> pockets,
  }) {
    final List<String> recs = [];

    if (runwayMonths < 3.0) {
      recs.add(
        'Dana daruratmu (${runwayMonths.toStringAsFixed(1)} bulan) masih di bawah rekomendasi 3 bulan. Prioritaskan isi Kantong Darurat secara berkala.',
      );
    }
    if (commitmentRatio > 35.0) {
      recs.add(
        'Beban tagihan rutin mencapai ${commitmentRatio.toStringAsFixed(0)}% dari pemasukan. Evaluasi langganan atau tagihan yang kurang bernilai guna.',
      );
    }
    if (savingsMarginPercent < 10.0) {
      recs.add(
        'Margin tabungan bulan ini ${savingsMarginPercent.toStringAsFixed(0)}%. Terapkan sistem "Pay Yourself First" di awal tanggal gajian ke Kantong Impian.',
      );
    }
    if (safeToSpend.healthStatus != FinancialHealthStatus.comfortable) {
      recs.add(
        'Pacing belanja harian mendekati batas aman. Rem pengeluaran variabel agar tidak defisit di akhir bulan.',
      );
    }
    if (pockets.isEmpty) {
      recs.add(
        'Kamu belum memiliki Kantong Tabungan. Buat kantong alokasi (Masa Tua / Dana Darurat) untuk memisahkan dana jajan dari simpanan.',
      );
    }
    if (recs.isEmpty) {
      recs.add(
        'Kondisi keuanganmu luar biasa prima! Pertahankan rasio simpanan dan lanjutkan alokasi jangka panjang.',
      );
    }

    return recs;
  }
}
