import 'insight_compact_corpus_en.dart';
import 'insight_models.dart';

class InsightCompactCorpus {
  static const Map<SpendVelocity, List<String>> _compactPhrases = {
    SpendVelocity.zeroSpend: [
      'Alokasi utuh, ritme kas aman',
      'Disiplin penuh, plafon utuh',
      'Arus kas tenang, saldo aman',
      'Nol belanja, ritme terjaga',
      'Pertahanan kokoh, bebas bocor',
    ],
    SpendVelocity.conservative: [
      'Belanja terukur, sisa aman',
      'Hanya pokok, ritme terjaga',
      'Pengeluaran hemat, kas aman',
      'Belanja bijak, tabungan aman',
      'Konsumsi rapi, sisa berlimpah',
    ],
    SpendVelocity.moderate: [
      'Belanja wajar sesuai rencana',
      'Ritme stabil, kendalikan jajan',
      'Arus kas harian terkendali',
      'Pengeluaran seimbang & aman',
      'Konsumsi proporsional terjaga',
    ],
    SpendVelocity.nearLimit: [
      'Dekati plafon, rem belanja',
      'Alokasi tipis, tahan jajan',
      'Istirahatkan dompet malam ini',
      'Amankan sisa kas untuk esok',
      'Hampir batas, dahulukan pokok',
    ],
    SpendVelocity.overLimit: [
      'Melebihi alokasi, rem esok',
      'Plafon lewat, pulihkan ritme',
      'Tahan belanja fleksibel esok',
      'Evaluasi jajan, tebus esok',
      'Kunci dompet, amankan tren',
    ],
    SpendVelocity.deficit: [
      'Anggaran defisit, tunda jajan',
      'Fokus pokok, amankan kas',
      'Arus kas ketat, tahan mutasi',
      'Pulihkan likuiditas utama',
    ],
  };

  static const Map<MonthPhase, List<String>> _phaseSpecificZeroSpendCompact = {
    MonthPhase.early: [
      'Start awal bulan rapi, kas utuh',
      'Pondasi kokoh, alokasi utuh',
      'Awal bulan tenang, tanpa bocor',
      'Plafon awal bulan aman utuh',
    ],
    MonthPhase.mid: [
      'Pertengahan bulan rapi terjaga',
      'Konsistensi teruji, kas aman',
      'Ritme hemat stabil terjaga',
      'Pertahanan utuh, cadangan tebal',
    ],
    MonthPhase.latePhase: [
      'Kunci surplus akhir bulan',
      'Disiplin tinggi, runway aman',
      'Sisa hari ringkas, kas solid',
      'Kawal akhir bulan hemat rapi',
    ],
  };

  static const List<String> _weekendZeroSpend = [
    'Weekend santai, dompet aman',
    'Akhir pekan hemat & terkendali',
    'Weekend disiplin, plafon utuh',
  ];

  static String selectPhrase({
    required SpendVelocity velocity,
    required MonthPhase phase,
    required StreakTier streakTier,
    required DayContext dayContext,
    required DateTime date,
    required int streak,
    String localeCode = 'id',
  }) {
    final isEn = localeCode == 'en';
    final phrases = isEn ? InsightCompactCorpusEn.compactPhrases : _compactPhrases;
    final phaseZero = isEn ? InsightCompactCorpusEn.phaseSpecificZeroSpend : _phaseSpecificZeroSpendCompact;
    final weekendZero = isEn ? InsightCompactCorpusEn.weekendZeroSpend : _weekendZeroSpend;

    List<String> pool;
    if (velocity == SpendVelocity.zeroSpend) {
      if (dayContext == DayContext.weekend && (date.day + streak) % 2 == 0) {
        pool = weekendZero;
      } else if (phaseZero.containsKey(phase)) {
        pool = phaseZero[phase]!;
      } else {
        pool = phrases[SpendVelocity.zeroSpend]!;
      }
    } else {
      pool = phrases[velocity] ?? phrases[SpendVelocity.zeroSpend]!;
    }

    final int hash = (date.year * 372 + date.month * 31 + date.day * 7 + streak * 13).abs();
    final int index = hash % pool.length;
    return pool[index];
  }
}
