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
    double totalLiquidAssets = 0.0,
    double targetEmergency3Months = 0.0,
    double currentEmergencyBuffer = 0.0,
    double totalRecurringBills = 0.0,
    double maxIdealBills = 0.0,
    double netSavings = 0.0,
    double targetSavings = 0.0,
    bool hasEmergencyPocket = false,
  }) {
    final List<String> recs = [];

    if (runwayMonths < 3.0) {
      final gap = (targetEmergency3Months - currentEmergencyBuffer).clamp(0.0, double.infinity);
      final gapText = gap > 0 ? ' (kurang ${_fmt(gap)})' : '';
      if (hasEmergencyPocket) {
        recs.add(
          'Target dana darurat 3 bulanmu ${_fmt(targetEmergency3Months)}$gapText. Prioritaskan transfer berkala dari saldo rekening ke Kantong Darurat.',
        );
      } else {
        recs.add(
          'Target dana darurat 3 bulanmu ${_fmt(targetEmergency3Months)}$gapText. Buat Kantong khusus "Dana Darurat" dan sisihkan dari saldo rekening agar aman.',
        );
      }
    }
    if (commitmentRatio > 35.0) {
      recs.add(
        'Beban tagihan rutin mencapai ${_fmt(totalRecurringBills)}/bln (${commitmentRatio.toStringAsFixed(0)}% dari pemasukan). Batas aman ideal ${_fmt(maxIdealBills)}/bln (30%). Evaluasi tagihan yang kurang bernilai guna.',
      );
    }
    if (savingsMarginPercent < 10.0) {
      recs.add(
        'Margin tabungan bulan ini baru ${_fmt(netSavings)} (${savingsMarginPercent.toStringAsFixed(0)}%). Targetkan simpanan minimal ${_fmt(targetSavings)} (20%) dengan metode "Pay Yourself First" di awal gajian.',
      );
    }
    if (safeToSpend.healthStatus != FinancialHealthStatus.comfortable) {
      recs.add(
        'Pacing belanja harian mendekati batas aman (${_fmt(safeToSpend.safeToSpendDaily)}/hari). Rem pengeluaran variabel agar sisa alokasi bulanan tetap terjaga.',
      );
    }
    if (pockets.isEmpty) {
      recs.add(
        'Kamu belum memiliki Kantong Tabungan. Buat kantong alokasi (Masa Tua / Dana Darurat) untuk memisahkan dana jajan dari simpanan.',
      );
    }
    if (recs.isEmpty) {
      recs.add(
        'Kondisi keuanganmu luar biasa prima! Cadangan darurat dan rasio simpanan aman, lanjutkan alokasi investasi jangka panjang.',
      );
    }

    return recs;
  }

  static String _fmt(double amount) {
    final int val = amount.round();
    final String s = val.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp ${val < 0 ? '-' : ''}${buffer.toString()}';
  }
}
