import 'package:intl/intl.dart';

import 'safe_to_spend_service.dart';

/// Pure domain service that generates psychologically persuasive, natural copywriting
/// for daily allowance and pacing, encouraging mindful spending and capital preservation.
class DailyPacingNudgeService {
  /// Generates short, natural, and psychologically motivating financial nudges for the Bento card.
  /// Designed to trigger mindfulness, saving discipline, and emotional pride without emojis.
  static String getCompactSubtitle({
    required SafeToSpendMetrics metrics,
    required double todayExpense,
    NumberFormat? currencyFormatter,
    bool isBalanceHidden = false,
  }) {
    final dailyQuota = metrics.safeToSpendDaily;
    final health = metrics.healthStatus;
    final daysRemaining = metrics.daysRemainingInMonth;

    // 1. DEFICIT STATUS: Urgent loss-prevention & emergency pause
    if (health == FinancialHealthStatus.deficit || dailyQuota <= 0) {
      return 'Tahan jajan, utamakan kebutuhan';
    }

    // 2. ZERO EXPENSES TODAY: Positive reinforcement & saving pride
    if (todayExpense <= 0) {
      if (health == FinancialHealthStatus.caution) {
        return 'Pertahankan, amankan dana cadangan';
      }
      if (daysRemaining <= 5) {
        return 'Kian dekat gajian, jaga ritme hemat';
      }
      return 'Disiplin hari ini, tenang esok hari';
    }

    // 3. WITH EXPENSES TODAY
    final remaining = dailyQuota - todayExpense;

    if (remaining > 0) {
      final spendRatio = todayExpense / dailyQuota;
      if (spendRatio <= 0.4) {
        return 'Belanja bijak, tabungan tetap aman';
      } else if (spendRatio <= 0.8) {
        return 'Ritme terjaga, kendalikan godaan';
      } else {
        return 'Cukup hari ini, istirahatkan dompet';
      }
    } else {
      if (health == FinancialHealthStatus.caution) {
        return 'Rem belanja, tebus lebih hemat esok';
      }
      return 'Tetap tenang, lebih hemat esok hari';
    }
  }

  /// Generates in-depth psychological coaching for the Daily Pace modal.
  static String getDetailedNudge({
    required SafeToSpendMetrics metrics,
    required double todayExpense,
  }) {
    final dailyQuota = metrics.safeToSpendDaily;
    final health = metrics.healthStatus;
    final remaining = dailyQuota - todayExpense;

    if (health == FinancialHealthStatus.deficit || dailyQuota <= 0) {
      return 'Kondisi anggaran saat ini sedang defisit. Tahan belanja non-esensial dan dahulukan kebutuhan utama agar kondisi keuanganmu segera pulih.';
    }

    if (todayExpense <= 0) {
      if (health == FinancialHealthStatus.caution) {
        return 'Alokasi hari ini masih utuh. Terus tahan godaan belanja untuk memperkuat dana darurat dan cadangan keuanganmu.';
      }
      return 'Belum ada pengeluaran hari ini. Setiap rupiah yang kamu jaga membawa langkahmu lebih dekat menuju kebebasan finansial.';
    }

    if (remaining > 0) {
      final spendRatio = todayExpense / dailyQuota;
      if (spendRatio <= 0.5) {
        return 'Pilihan belanjamu sangat bijak dan rapi hari ini. Sisa kuota otomatis dialihkan menjadi tabungan yang mempertebal asetmu.';
      }
      return 'Sebagian besar kuota belanja sudah terpakai. Istirahatkan dompetmu hari ini agar ritme keuangan bulan ini tetap aman terjaga.';
    }

    return 'Pengeluaran hari ini telah melampaui alokasi harian. Jangan berkecil hati, jadikan evaluasi dan tebus dengan lebih hemat esok hari.';
  }
}
