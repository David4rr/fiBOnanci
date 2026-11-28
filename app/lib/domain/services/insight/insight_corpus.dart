import 'insight_corpus_en.dart';
import 'insight_models.dart';

class InsightCorpus {
  static const Map<SpendVelocity, List<String>> _generalPhrases = {
    SpendVelocity.zeroSpend: [
      'Alokasi harian utuh, kas tersimpan rapi tanpa kebocoran.',
      'Disiplin penuh hari ini, seluruh plafon belanja terselamatkan.',
      'Arus kas tenang, saldo harian siap mempertebal tabungan.',
      'Tanpa pengeluaran hari ini, ritme hemat terjaga sempurna.',
      'Pertahanan alokasi kokoh, saldo operasional tetap aman.',
    ],
    SpendVelocity.conservative: [
      'Belanja sangat terukur, mayoritas kuota harian terselamatkan.',
      'Hanya pengeluaran pokok yang keluar, ritme kas tetap di zona hijau.',
      'Pengeluaran proporsional, sisa alokasi menjadi bantalan esok hari.',
      'Pengendalian belanja rapi, tabungan harian tetap bertambah.',
      'Belanja bijak hari ini, sisa plafon menjaga stabilitas kas.',
    ],
    SpendVelocity.moderate: [
      'Belanja wajar sesuai rencana, kuota tersisa menjaga ritme.',
      'Arus kas harian stabil, pengeluaran masih dalam koridor aman.',
      'Ritme belanja terkendali, tahan godaan impulsif hingga malam.',
      'Pengeluaran terarah, sisa alokasi cukup untuk kebutuhan penting.',
      'Konsumsi seimbang, posisi kas harian masih solid.',
    ],
    SpendVelocity.nearLimit: [
      'Mendekati plafon harian, istirahatkan dompet hingga esok hari.',
      'Alokasi tersisa sedikit, tahan belanja non-esensial malam ini.',
      'Plafon harian hampir optimal terpakai, rem jajan untuk jaga ritme.',
      'Batas alokasi kian tipis, dahulukan kebutuhan utama.',
      'Dekati ambang harian, amankan sisa kas untuk esok.',
    ],
    SpendVelocity.overLimit: [
      'Alokasi hari ini terlampaui. Rehatkan belanja dan tebus lebih hemat esok.',
      'Pengeluaran melebihi plafon. Jaga ritme esok hari agar tren bulanan aman.',
      'Hari ini melampaui alokasi. Evaluasi mutasi dan perketat rem belanja esok.',
      'Melebihi alokasi harian. Tahan pengeluaran fleksibel di hari berikutnya.',
      'Plafon terlewati hari ini. Kunci dompet dan pulihkan ritme esok.',
    ],
    SpendVelocity.deficit: [
      'Kondisi anggaran defisit. Prioritaskan kebutuhan pokok dan tunda jajan.',
      'Arus kas sedang ketat. Tahan belanja non-esensial demi pemulihan kas.',
      'Amankan dana cadangan, kurangi mutasi keluar hingga kondisi pulih.',
      'Fokus pemulihan likuiditas, tahan seluruh pengeluaran diskresioner.',
    ],
  };

  static const Map<MonthPhase, List<String>> _phaseSpecificZeroSpend = {
    MonthPhase.early: [
      'Pondasi awal bulan kokoh, alokasi harian utuh menjaga ritme awal.',
      'Start bulan yang solid, belum ada rupiah yang keluar dari plafon.',
      'Awal bulan teratur, saldo harian tersimpan rapi tanpa kebocoran.',
    ],
    MonthPhase.mid: [
      'Konsistensi terjaga di pertengahan bulan, cadangan kas kian tebal.',
      'Pertengahan bulan yang tenang, alokasi harian tetap utuh terjaga.',
      'Arus kas stabil di pertengahan bulan, ritme hemat makin teruji.',
    ],
    MonthPhase.latePhase: [
      'Fase akhir bulan terkunci aman, surplus kas siap masuk tabungan.',
      'Menutup bulan dengan disiplin tinggi, sisa runway aman terjaga.',
      'Sisa hari kian ringkas, pertahanan alokasi sukses mengunci surplus.',
    ],
  };

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
    final phaseMap = isEn ? kEnPhaseZeroSpend : _phaseSpecificZeroSpend;
    final generalMap = isEn ? kEnInsightPhrases : _generalPhrases;

    List<String> pool;
    if (velocity == SpendVelocity.zeroSpend && phaseMap.containsKey(phase)) {
      pool = phaseMap[phase]!;
    } else {
      pool = generalMap[velocity] ?? generalMap[SpendVelocity.zeroSpend]!;
    }

    final int hash = (date.year * 372 + date.month * 31 + date.day * 7 + streak * 13).abs();
    final int index = hash % pool.length;
    return pool[index];
  }
}
