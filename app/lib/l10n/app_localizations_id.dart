// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navDashboard => 'Home';

  @override
  String get navWallets => 'Wallets';

  @override
  String get navSubscriptions => 'Tagihan';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get historyButton => 'Riwayat';

  @override
  String get profileTitle => 'Profil Pengguna';

  @override
  String get profileSubtitle => 'Ringkasan identitas & performa finansial';

  @override
  String get financialReportTitle => 'Laporan Keuangan';

  @override
  String get financialReportSubtitle =>
      'Analisis arus kas, kategori, & distribusi rekening';

  @override
  String get financialHealthTitle => 'Audit Kesehatan Finansial';

  @override
  String get financialHealthSubtitle =>
      'Berdasarkan rasio arus kas, aset, & tagihan riil';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsSubtitle =>
      'Preferensi finansial, kategori, otomasi, & data lokal';

  @override
  String get settingsGlobalHeader => 'PENGATURAN GLOBAL • SEMUA PROFIL';

  @override
  String get settingsHideBalance => 'Samarkan Nominal Saldo';

  @override
  String get settingsHighRefreshRate => 'Mode Layar 120Hz (High FPS)';

  @override
  String get settingsBiometricLock => 'Kunci Biometrik / PIN Aplikasi';

  @override
  String get settingsPrivacyScreen => 'Pelindung Layar Privasi (Recent Apps)';

  @override
  String get settingsThemeLabel => 'Tema Tampilan';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsLanguageLabel => 'Bahasa Aplikasi';

  @override
  String get settingsLanguageName => 'Indonesia';

  @override
  String get settingsEncryptionLabel => 'Enkripsi Database (SQLCipher)';

  @override
  String get settingsEncryptionActive => 'AES-256 Aktif';

  @override
  String get settingsCategoriesLabel => 'Kategori Transaksi';

  @override
  String get settingsNotifListenerLabel => 'Listener Notifikasi Bank';

  @override
  String get settingsBankAppsLabel => 'Aplikasi Bank & E-Wallet';

  @override
  String get settingsAboutAppLabel => 'Tentang Aplikasi & Pembaruan';

  @override
  String settingsDataBackupHeader(String username) {
    return 'DATA & CADANGAN • @$username';
  }

  @override
  String settingsDangerZoneHeader(String username) {
    return 'ZONA BAHAYA • @$username';
  }

  @override
  String get settingsExportCsv => 'Ekspor Transaksi (CSV / Excel)';

  @override
  String get settingsExportJson => 'Simpan Cadangan (JSON)';

  @override
  String get settingsImportJson => 'Pulihkan Cadangan (Import JSON)';

  @override
  String get settingsClearTx => 'Bersihkan Riwayat Transaksi';

  @override
  String get settingsDeleteProfile => 'Hapus / Reset Profil Aktif';

  @override
  String get reportExpenses => 'Pengeluaran';

  @override
  String get reportIncome => 'Pemasukan';

  @override
  String get reportAllFlow => 'Semua Arus';

  @override
  String get reportWeek => 'Minggu';

  @override
  String get reportMonth => 'Bulan';

  @override
  String get reportQuarter => 'Kuartal';

  @override
  String reportTransactionsCount(int count) {
    return '$count Transaksi';
  }

  @override
  String get reportAssetsTitle => 'POSISI ASET & KEWAJIBAN';

  @override
  String get reportTotalNetWorth => 'Total Kekayaan Bersih';

  @override
  String get reportActiveWalletBalance => 'Saldo Rekening Aktif';

  @override
  String get reportPocketBalance => 'Dana Kantong Tabungan';

  @override
  String get reportCommittedBills => 'Komitmen Tagihan Bulanan';

  @override
  String get reportWalletActivityTitle => 'AKTIVITAS PER REKENING';

  @override
  String get reportEmptyWallets => 'Belum ada rekening aktif';

  @override
  String get reportEmptyTitle => 'Belum ada transaksi';

  @override
  String get reportEmptyDesc =>
      'Catat transaksi pada periode ini untuk melihat rincian kategori.';

  @override
  String dashboardSafeToSpendFiltered(int count) {
    return 'Safe to Spend ($count Akun)';
  }

  @override
  String dashboardRealAccounts(int count) {
    return '$count Akun Riil';
  }

  @override
  String dashboardBillsThisMonth(int count) {
    return '$count Tagihan Bln Ini';
  }

  @override
  String get dashboardHistoryTitle => 'Riwayat Transaksi';

  @override
  String dashboardSearchResults(int count) {
    return 'Hasil Pencarian ($count)';
  }

  @override
  String get dashboardViewAll => 'Lihat Semua';

  @override
  String walletsMainAccounts(int count) {
    return 'Rekening Utama ($count)';
  }

  @override
  String walletsSavingsPockets(int count) {
    return 'Kantong Tabungan ($count)';
  }

  @override
  String get walletsTotalRealBalance => 'TOTAL SALDO RIIL';

  @override
  String get walletsFlowIn => 'Masuk';

  @override
  String get walletsFlowOut => 'Keluar';

  @override
  String get subsTitle => 'Tagihan & Langganan';

  @override
  String subsRegisteredCount(int count) {
    return '$count Kartu Terdaftar • Diurutkan jatuh tempo';
  }

  @override
  String get subsEmptyTitle => 'Belum Ada Tagihan Rutin';

  @override
  String get subsEmptyDesc =>
      'Daftarkan langganan Netflix, Spotify, atau cicilan agar jatuh tempo tercatat rapi.';

  @override
  String get subsEmptyHint => 'Ketuk tombol + di bawah untuk menambahkan';

  @override
  String get subsSearchHint => 'Cari tagihan, langganan, rekening...';

  @override
  String get subsFilterTitle => 'Filter Tagihan';

  @override
  String get subsFilterStatusHeader => 'STATUS PEMBAYARAN';

  @override
  String get profileMenuTitle => 'Menu Profil';

  @override
  String get profileMenuNew => 'Tambah akun profil baru';

  @override
  String get profileMenuHealth => 'Audit komprehensif keuangan';

  @override
  String get profileMenuReport => 'Ringkasan arus kas & kategori';

  @override
  String get profileMenuSettings => 'Mata uang, kategori, & data lokal';

  @override
  String get profileMenuShare => 'Bagikan kartu profil finansial';

  @override
  String get profileDataHeader => 'DATA UMUM & DETAIL AKUN';

  @override
  String get profileOccupation => 'Profesi / Pekerjaan';

  @override
  String get profilePhone => 'No. Handphone';

  @override
  String get profileBio => 'Bio / Catatan';

  @override
  String get profilePrimaryCurrency => 'Mata Uang Utama';

  @override
  String get profileIncomeTarget => 'Target Pemasukan';

  @override
  String get profileConnectedWallets => 'Rekening Terhubung';

  @override
  String profileConnectedWalletsVal(int count) {
    return '$count Akun';
  }

  @override
  String get profileTotalTx => 'Total Transaksi';

  @override
  String profileTotalTxVal(int count) {
    return '$count Tercatat';
  }

  @override
  String get settingsAndroidOnly => 'Hanya Android';

  @override
  String get settingsActive => 'Aktif';

  @override
  String get settingsOff => 'Mati';

  @override
  String settingsCategoriesCount(int count) {
    return '$count Kategori';
  }

  @override
  String settingsSupportedCount(int count) {
    return '$count Didukung';
  }

  @override
  String settingsProfileHeader(String username) {
    return 'PENGATURAN PROFIL • @$username';
  }

  @override
  String get settingsIncomeTargetTitle => 'Target Pemasukan Bulanan';

  @override
  String get settingsSetAction => 'Atur';

  @override
  String get settingsCycleDayTitle => 'Tanggal Mulai Siklus';

  @override
  String settingsCycleDayValue(int day, int rem) {
    return 'Tgl $day ($rem hr)';
  }

  @override
  String get settingsStsWalletsTitle => 'Rekening Safe-to-Spend';

  @override
  String settingsAllCount(int count) {
    return 'Semua ($count)';
  }

  @override
  String settingsActiveCount(int count) {
    return '$count Aktif';
  }

  @override
  String get profileSafe => 'Aman';

  @override
  String get profileDaily => 'Harian';

  @override
  String get profileScore => 'SKOR';

  @override
  String get profileAccounts => 'Rekening';

  @override
  String get profileTransactions => 'Transaksi';

  @override
  String get profileRecurringBills => 'Tagihan Rutin';

  @override
  String get pocketsEmptyTitle => 'Belum Ada Kantong Tabungan';

  @override
  String get pocketsEmptyDesc =>
      'Pisahkan dana untuk Tabungan, Dana Darurat, atau Impianmu agar aman dari belanja harian.';

  @override
  String get pocketsEmptyHint => 'Ketuk tombol + di bawah untuk membuat';

  @override
  String get walletTrendHeadline => 'Tren Arus Kas (Semua Rekening)';

  @override
  String get walletTrendSubtitle => '30 Hari';

  @override
  String get stsTotalRealBalance => 'Total Saldo Riil';

  @override
  String get stsSelectedBalance => 'Saldo Rekening Terpilih';

  @override
  String get stsPendingBills => 'Sisa Tagihan Bulan Ini';

  @override
  String get stsSelectedBills => 'Tagihan Terkait Terpilih';

  @override
  String get stsMonthlySafe => 'Sisa Aman Bulan Ini';

  @override
  String stsDailyAllowance(int days) {
    return 'Alokasi Harian ($days hr)';
  }

  @override
  String get walletScreenTitle => 'Rekening & Dompet';

  @override
  String walletConnectedSubtitle(int count) {
    return '$count rekening terhubung';
  }

  @override
  String get searchTransactionsHint => 'Cari transaksi, rekening, merchant...';

  @override
  String get searchFilterTitle => 'Filter Transaksi';

  @override
  String get searchFilterTypeHeader => 'TIPE TRANSAKSI';

  @override
  String get dashboardEmptyWalletTitle => 'Belum Ada Rekening Terhubung';

  @override
  String get dashboardEmptyWalletDesc =>
      'Tambahkan rekening atau dompet digital untuk mulai melacak keuangan dan alokasi safe-to-spend.';

  @override
  String get dashboardEmptyWalletHint =>
      'Ketuk tombol + di bawah untuk menambahkan';

  @override
  String get dashboardNoMatchingTx => 'Tidak ada transaksi yang cocok';

  @override
  String get dashboardNoTxToday => 'Belum ada transaksi hari ini';

  @override
  String get walletCardAvailableBalance => 'SALDO TERSEDIA';

  @override
  String dashboardWelcome(String username) {
    return 'Hallo $username selamat datang kembali!';
  }

  @override
  String get hintCategoryName => 'Nama kategori baru...';

  @override
  String get hintPocketName => 'Nama Kantong (cth: Tabungan Pensiun, Liburan)';

  @override
  String get hintWalletName => 'Nama Rekening (cth: BCA, Kas Tunai, Jago)';

  @override
  String hintInitialBalance(String symbol) {
    return 'Saldo Awal ($symbol)';
  }

  @override
  String get hintAccountNumber => 'Nomor Rekening (Opsional, cth: 5410982341)';

  @override
  String get hintNotesOptional => 'Catatan (Opsional)';

  @override
  String get hintSubscriptionTitle =>
      'cth: Netflix, Spotify, Listrik PLN, Kosan';

  @override
  String get walletDetailTitle => 'Detail Rekening';

  @override
  String get walletDetailSubtitle => 'Informasi & Mutasi';

  @override
  String walletBalanceAdjustTitle(String name) {
    return 'Penyesuaian Saldo: $name';
  }

  @override
  String get walletBalanceAdjustSubtitle =>
      'Ubah saldo awal & preferensi rekening';

  @override
  String get walletActionEditBalance => 'Ubah Saldo';

  @override
  String get walletActionLogTx => 'Catat Transaksi';

  @override
  String cardCategoryTrend(String category) {
    return 'Tren $category (Sen–Min)';
  }

  @override
  String get subRecurringMonthly => 'tagihan rutin /bulan';

  @override
  String get subRecurringYearly => 'tagihan rutin /tahun';

  @override
  String get subBadgeCycleMonthly => 'BULANAN';

  @override
  String get subBadgeCycleYearly => 'TAHUNAN';

  @override
  String get subBadgePaid => 'LUNAS';

  @override
  String subBadgeMonthsLeft(int count) {
    return 'Sisa $count bln';
  }

  @override
  String subBadgeInstallmentCompleted(int paid, int total) {
    return 'CICILAN LUNAS ($paid/$total)';
  }

  @override
  String subBadgeInstallmentPaid(int paid, String total) {
    return 'CICILAN $paid/$total • LUNAS';
  }

  @override
  String get subBadgePaidThisMonth => 'LUNAS BULAN INI';

  @override
  String subBadgeInstallmentPrefix(int step, String total) {
    return 'CICILAN $step/$total • ';
  }

  @override
  String get subBadgeDuePrefix => 'JATUH TEMPO ';

  @override
  String get subBadgeToday => 'HARI INI';

  @override
  String subBadgeInDays(int days) {
    return 'H-$days';
  }

  @override
  String subBadgeOnDay(int day) {
    return 'TGL $day';
  }

  @override
  String get subSpecPaymentAccount => 'Rekening Pembayaran';

  @override
  String get subSpecCurrentBalance => 'Saldo Rekening Saat Ini';

  @override
  String get subSpecPaymentMethod => 'Metode Pembayaran';

  @override
  String get subSpecAutoDeduct => 'Auto-Deduct Aktif';

  @override
  String get subSpecPeriodStatus => 'Status Periode Ini';

  @override
  String get subSpecInstallmentDone => 'Cicilan Selesai';

  @override
  String get subSpecStatusPaid => 'Sudah Lunas';

  @override
  String get subSpecStatusUnpaid => 'Belum Dibayar';

  @override
  String get subSpecInstallmentPlan => 'Rencana Cicilan';

  @override
  String subSpecInstallmentProgress(int paid, int total) {
    return '$paid dari $total bulan lunas';
  }

  @override
  String get subSpecRemainingPrincipal => 'Sisa Tagihan Pokok';

  @override
  String get subSpecCompletionDate => 'Tenggat Selesai';

  @override
  String get subSpecBillingCycle => 'Siklus Tagihan';

  @override
  String get subSpecCycleMonthly => 'Bulanan';

  @override
  String get subSpecCycleYearly => 'Tahunan';

  @override
  String get subSpecDueDate => 'Jatuh Tempo';

  @override
  String subSpecDueEveryDay(int day) {
    return 'Setiap tanggal $day';
  }

  @override
  String get txModalTitle => 'Catat Transaksi';

  @override
  String get txModalSubExpense => 'Pengeluaran kas atau mutasi keluar';

  @override
  String get txModalSubIncome => 'Pemasukan gaji atau dana masuk';

  @override
  String get txModalSubTransfer => 'Transfer antar rekening & profil';

  @override
  String get txTypeExpense => 'Pengeluaran';

  @override
  String get txTypeIncome => 'Pemasukan';

  @override
  String get txTypeTransfer => 'Transfer';

  @override
  String get txSelectCategory => 'Pilih Kategori';

  @override
  String get txSelectSourceAccount => 'Pilih Rekening Asal';

  @override
  String get txSelectAccount => 'Pilih Rekening';

  @override
  String get txCancel => 'Batal';

  @override
  String get txSave => 'Simpan Transaksi';

  @override
  String get txErrDestEmptyTitle => 'Rekening Tujuan Kosong';

  @override
  String get txErrDestEmptyMsg => 'Pilih rekening tujuan di profil tujuan!';

  @override
  String get txErrSameAccountTitle => 'Rekening Sama';

  @override
  String get txErrSameAccountMsg =>
      'Pilih rekening tujuan yang berbeda dari rekening asal!';

  @override
  String get addWalletTitle => 'Tambah Rekening Baru';

  @override
  String get addWalletSubtitle => 'Bank, E-Wallet, atau Kas Tunai';

  @override
  String get pickAppTitle => 'Pilih Aplikasi';

  @override
  String get pickAppSubtitle => 'Cari bank atau e-wallet di HP Anda';

  @override
  String get addPocketTitle => 'Buat Kantong Alokasi Baru';

  @override
  String get addPocketSubtitle =>
      'Pisahkan dana tabungan agar tidak terpakai saat belanja harian.';

  @override
  String get addPocketTypeHeader => 'TIPE KANTONG';

  @override
  String get addPocketNameLabel => 'Nama Kantong';

  @override
  String get addPocketTargetLabel => 'Target Tabungan (Opsional)';

  @override
  String get addPocketInitialLabel => 'Setoran Awal (Opsional)';

  @override
  String get addPocketSourceAccount =>
      'Ambil Dari Rekening (Jika ada setoran awal)';

  @override
  String get subModalEditInstallment => 'Edit Cicilan';

  @override
  String get subModalEditBill => 'Edit Tagihan Rutin';

  @override
  String get subModalAddInstallment => 'Tambah Cicilan Baru';

  @override
  String get subModalAddBill => 'Tambah Tagihan Baru';

  @override
  String get subModalSubInstallment => 'Rencana cicilan tenor & jatuh tempo';

  @override
  String get subModalSubBill =>
      'Langganan, tagihan rutin, atau tagihan berkala';

  @override
  String get subModalSaveChanges => 'Simpan Perubahan';

  @override
  String get subModalSaveBill => 'Simpan Tagihan';

  @override
  String get onbWelcomeTagline =>
      'Kelola keuangan pribadi dengan kecerdasan Safe-to-Spend & privasi 100% on-device.';

  @override
  String get onbCreateAccountTitle => 'Buat Akun Baru';

  @override
  String get onbCreateAccountSub =>
      'Pengguna baru: Mulai dari awal dalam 1 menit';

  @override
  String get onbRestoreTitle => 'Pulihkan dari Cadangan';

  @override
  String get onbRestoreSub => 'Sudah pernah pakai? Pulihkan berkas .json Anda';

  @override
  String get onbNameQuestion => 'Halo! Siapa namamu?';

  @override
  String get onbNameHelper => 'Kami pakai untuk menyapamu di beranda aplikasi.';

  @override
  String get onbNameHint => 'Nama lengkap (contoh: Budi Santoso)';

  @override
  String onbUsernameQuestion(String name) {
    return 'Senang kenal, $name.';
  }

  @override
  String get onbUsernameHelper =>
      'Pilih username untuk profilmu. Pekerjaan boleh dikosongkan.';

  @override
  String get onbUsernameHint => 'nama_pengguna';

  @override
  String get onbUsernameRule => 'Huruf kecil a–z, angka 0–9, dan garis bawah _';

  @override
  String get onbOccupationHint =>
      'Pekerjaan (misalnya: Mahasiswa atau Desainer)';

  @override
  String get onbIncomeQuestion => 'Berapa pemasukanmu per bulan?';

  @override
  String get onbIncomeHelper =>
      'Gaji, uang saku, atau rata-rata penghasilan. Bisa diubah nanti di pengaturan.';

  @override
  String get onbIncomeLabel => 'Pemasukan bulanan';

  @override
  String onbCelebrationTitle(String name) {
    return 'Selamat datang, $name!';
  }

  @override
  String get onbCelebrationDesc =>
      'Brankas dan rekening pertamamu sudah aktif.\nSemua siap, ayo mulai atur keuanganmu!';

  @override
  String get onbSkip => 'Lewati';

  @override
  String get onbContinue => 'Lanjut';

  @override
  String get onbStartApp => 'Mulai Aplikasi';

  @override
  String get txEditTitle => 'Edit Transaksi';

  @override
  String get txEditSubtitle => 'Ubah kategori, rekening, atau nominal';

  @override
  String get txStorageAccount => 'REKENING PENYIMPANAN';

  @override
  String get txDestAccount => 'Rekening Tujuan';

  @override
  String get txCategoryLabel => 'Kategori';

  @override
  String get txDeleteLabel => 'Hapus Transaksi';

  @override
  String get txSaveChanges => 'Simpan Perubahan';

  @override
  String get txDeleteDialogTitle => 'Hapus Transaksi?';

  @override
  String get txDeleteDialogContent =>
      'Transaksi ini akan dihapus permanen dan saldo dompet akan dikembalikan.';

  @override
  String get txDeleteConfirm => 'Hapus';

  @override
  String get txDeletedSnackTitle => 'Transaksi Dihapus';

  @override
  String get txDeletedSnackMsg =>
      'Transaksi dihapus & saldo dompet dikembalikan semula!';

  @override
  String get walletEditBalanceSubtitle =>
      'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.';

  @override
  String get walletUpdateBalanceBtn => 'Perbarui Saldo';

  @override
  String get walletDeleteAccountBtn => 'Hapus Rekening';

  @override
  String get subDetailInstallmentTitle => 'Detail Cicilan';

  @override
  String get subDetailBillTitle => 'Detail Tagihan';

  @override
  String get subEditInstallmentBtn => 'Edit Cicilan';

  @override
  String get subEditBillBtn => 'Edit Tagihan';

  @override
  String get subDeleteBtn => 'Hapus';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterAllAccounts => 'Semua Rekening';

  @override
  String get filterApply => 'Terapkan Filter';

  @override
  String get filterAllStatus => 'Semua Status';

  @override
  String get filterUnpaid => 'Belum Bayar';

  @override
  String get filterPaid => 'Sudah Lunas';

  @override
  String get notifBannerTitle => 'Akses Notifikasi Belum Aktif';

  @override
  String get notifBannerSub => 'Ketuk untuk aktifkan pencatatan otomatis bank';

  @override
  String get notifBannerEnable => 'Aktifkan';

  @override
  String get smartInputSpeakHint => 'Ucapkan transaksi Anda...';

  @override
  String get smartInputTypeHint => 'Ketik kalimat transaksi...';

  @override
  String get smartInputContinue => 'Lanjutkan';

  @override
  String get pocketHistoryTitle => 'Riwayat Mutasi';

  @override
  String get pocketHistoryEmpty => 'Belum ada riwayat mutasi';

  @override
  String get pocketDepositTitle => 'Isi Dana ke Kantong';

  @override
  String get pocketWithdrawTitle => 'Tarik Dana ke Rekening';

  @override
  String pocketDepositSub(String name) {
    return 'Pilih rekening asal untuk memindahkan dana ke $name.';
  }

  @override
  String pocketWithdrawSub(String name) {
    return 'Pilih rekening tujuan penarikan dari $name.';
  }

  @override
  String get pocketSourceAccount => 'Rekening Sumber';

  @override
  String get pocketDestAccount => 'Rekening Tujuan';

  @override
  String get pocketNoActiveAccounts =>
      'Belum ada rekening aktif untuk transaksi.';

  @override
  String get pocketDepositAmount => 'Nominal Setoran';

  @override
  String get pocketWithdrawAmount => 'Nominal Penarikan';

  @override
  String pocketWithdrawAll(String amount) {
    return 'Tarik Semua ($amount)';
  }

  @override
  String get appPickerSearchHint => 'Cari nama app atau package...';

  @override
  String get appPickerNotFound => 'Aplikasi tidak ditemukan';

  @override
  String get subPayCompletedMsg =>
      'Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai.';

  @override
  String get subPayPeriodDoneMsg =>
      'Tagihan periode bulan ini telah lunas tercatat di buku kas.';

  @override
  String subPayInstallmentBtn(int next, String total) {
    return 'Bayar Cicilan Bulan Ini ($next/$total)';
  }

  @override
  String get subPayMarkPaidBtn => 'Tandai Sudah Lunas Bulan Ini';

  @override
  String subPayCustomBtn(String amount) {
    return 'Bayar $amount Bulan Ini';
  }

  @override
  String get subPaySuccessBtn => 'Berhasil Dibayar!';

  @override
  String subPaySnackTitle(String title) {
    return 'Tagihan $title Lunas';
  }

  @override
  String subPaySnackMsg(String wallet) {
    return 'Saldo $wallet terpotong otomatis.';
  }

  @override
  String get subTypeRoutine => 'Langganan Rutin';

  @override
  String get subTypeInstallment => 'Cicilan / Rencana';

  @override
  String get inboxTitle => 'Kotak Masuk Notifikasi';

  @override
  String get inboxTabTransactions => 'Transaksi';

  @override
  String get inboxTabReminders => 'Pengingat';

  @override
  String get inboxEmptyDesc =>
      'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!';

  @override
  String get inboxOpenNotifSettings => 'Buka Setelan Akses Notifikasi Android';

  @override
  String get editProfileTitle => 'Edit Profil';

  @override
  String get newProfileTitle => 'Tambah Profil Baru';

  @override
  String get editProfileFullName => 'Nama Lengkap';

  @override
  String get editProfilePhone => 'No. Handphone / WhatsApp';

  @override
  String get editProfileOccupation => 'Profesi / Pekerjaan';

  @override
  String get editProfileBio => 'Bio / Catatan Pribadi';

  @override
  String get editProfileEmailHint => 'e.g. nama@email.com';

  @override
  String get editProfileOccHint => 'e.g. Profesional, Wiraswasta';

  @override
  String get editProfileBioHint => 'e.g. Membangun kebebasan finansial';

  @override
  String get dailyPaceTitle => 'Alokasi Harian (Daily Pace)';

  @override
  String get dailyPaceSubtitle => 'Batas belanja harian & ritme anggaran';

  @override
  String get promoTitle => 'Diskon & Promo Tagihan';

  @override
  String promoSaved(String amount) {
    return 'Hemat $amount';
  }

  @override
  String get promoSubtitle => 'Punya voucher atau diskon bulan ini?';

  @override
  String get promoClose => 'Tutup';

  @override
  String get promoUse => 'Pakai Promo';

  @override
  String promoNormalPrice(String amount) {
    return 'Tarif Normal: $amount';
  }

  @override
  String promoPayAmount(String amount) {
    return 'Bayar: $amount';
  }

  @override
  String get promoInputLabel => 'Nominal Bayar Bulan Ini';

  @override
  String get inboxFilterWarning => 'Peringatan';

  @override
  String get inboxFilterSystem => 'Sistem';

  @override
  String get inboxMarkAllRead => 'Tandai Semua Dibaca';

  @override
  String get walletBindManual => 'Tidak Terhubung (Input Manual)';

  @override
  String get walletBindOther => 'Cari / Input Package Lain...';

  @override
  String walletBindConnected(String pkg) {
    return 'Notifikasi transaksi otomatis terhubung ($pkg)';
  }

  @override
  String get walletBindHint => 'Package Name (contoh: id.krom.bank)';

  @override
  String get walletBindTooltip => 'Pilih dari Aplikasi Terpasang';

  @override
  String get txTransferIn => 'Transfer Masuk';

  @override
  String get txTransferOut => 'Transfer Keluar';

  @override
  String get exportFormatHeader => 'PILIH FORMAT FILE LAPORAN';

  @override
  String get exportCsvTitle => 'Simpan File CSV (.csv)';

  @override
  String get exportCsvSub =>
      'Format koma terpisah (UTF-8 BOM), kompatibel semua spreadsheet';

  @override
  String get exportExcelTitle => 'Simpan File Excel (.xls)';

  @override
  String get exportExcelSub =>
      'Format tabel buku kerja Microsoft Excel / Google Sheets';

  @override
  String exportSavedTo(String path) {
    return 'Berhasil disimpan ke:\n$path';
  }

  @override
  String get walletBindHeader => 'Hubungkan Notifikasi Aplikasi';

  @override
  String get walletBindSearchApp => 'Cari App';

  @override
  String get inboxClearAll => 'Hapus Semua';

  @override
  String get inboxClearAllTitle => 'Hapus Semua Pengingat?';

  @override
  String get inboxClearAllContent =>
      'Semua riwayat pengingat akan dihapus secara permanen.';

  @override
  String get inboxRemindersEmpty =>
      'Belum ada pengingat atau tagihan tercatat.';

  @override
  String get pocketTypeSavings => 'Simpanan';

  @override
  String get pocketTypeRetirement => 'Masa Tua';

  @override
  String get pocketTypeEmergency => 'Dana Darurat';

  @override
  String get pocketTypeGoal => 'Target / Impian';

  @override
  String get pocketTotalSaved => 'Total Terkumpul di Kantong';

  @override
  String settingsDeleteProfileMultiDesc(String username) {
    return 'Profil @$username beserta seluruh rekening, transaksi, kantong dana, dan langganannya akan dihapus dari perangkat. Anda akan beralih ke profil lain yang tersimpan.';
  }

  @override
  String settingsDeleteProfileSingleDesc(String username) {
    return 'Profil @$username adalah satu-satunya profil. Menghapus profil ini akan meresetnya kembali ke pengaturan default.';
  }

  @override
  String settingsDeleteProfileConfirm(String username) {
    return 'Ya, Hapus Profil @$username';
  }

  @override
  String settingsResetProfileConfirm(String username) {
    return 'Ya, Reset Profil @$username';
  }

  @override
  String settingsClearTxDesc(String username) {
    return 'Semua riwayat transaksi pada profil @$username akan dihapus dan saldo rekening dikembalikan ke 0.';
  }

  @override
  String get settingsClearTxConfirm => 'Ya, Bersihkan Semua Transaksi';

  @override
  String get calNoSpendDay => 'No-Spend Day';

  @override
  String get calHematSafe => 'Hemat (Aman)';

  @override
  String get calOverPace => 'Melebihi Alokasi';

  @override
  String get calIncome => 'Pemasukan';

  @override
  String get calExpense => 'Pengeluaran';

  @override
  String get calDailyAllocation => 'Alokasi Harian';

  @override
  String calTxOnDate(int count) {
    return 'Transaksi Tanggal Ini ($count)';
  }

  @override
  String get calNoTxRecorded => 'Tidak ada aktivitas transaksi tercatat';

  @override
  String get settingsRouteCurrencyTitle => 'Mata Uang Utama';

  @override
  String get settingsRouteCurrencySub =>
      'Pilih mata uang tampilan & atur kurs patokan IDR';

  @override
  String get settingsRouteIncomeTargetTitle => 'Target Pemasukan Bulanan';

  @override
  String get settingsRouteIncomeTargetSub =>
      'Patokan rasio tagihan & tabungan di Audit Kesehatan';

  @override
  String get settingsRouteCycleDayTitle => 'Tanggal Mulai Siklus';

  @override
  String get settingsRouteCycleDaySub =>
      'Tanggal awal perhitungan siklus anggaran bulanan';

  @override
  String get settingsRouteStsWalletsTitle => 'Rekening Safe-to-Spend';

  @override
  String get settingsRouteStsWalletsSub =>
      'Pilih rekening yang dihitung dalam dana aman harian';

  @override
  String get settingsRouteCategoriesTitle => 'Kategori Transaksi';

  @override
  String get settingsRouteCategoriesSub =>
      'Kelola daftar kategori pengeluaran & pemasukan';

  @override
  String get settingsRouteBankAppsTitle => 'Aplikasi Bank & E-Wallet';

  @override
  String get settingsRouteBankAppsSub =>
      'Daftar aplikasi finansial yang didukung parser otomatis';

  @override
  String get settingsRouteExportDataTitle => 'Ekspor Data Transaksi';

  @override
  String get settingsRouteExportDataSub =>
      'Simpan laporan transaksi ke file CSV atau Excel (.xls)';

  @override
  String get settingsRouteClearTxTitle => 'Bersihkan Riwayat Transaksi';

  @override
  String get settingsRouteClearTxSub =>
      'Hapus seluruh mutasi & reset saldo profil aktif';

  @override
  String get settingsRouteDeleteProfileTitle => 'Hapus Profil';

  @override
  String get settingsRouteDeleteProfileSub =>
      'Hapus atau reset akun profil aktif dari perangkat';

  @override
  String get settingsRouteAboutAppTitle => 'Tentang Aplikasi';

  @override
  String get settingsRouteAboutAppSub =>
      'Informasi versi, lisensi, & status rilis';

  @override
  String get profileEditTitle => 'Edit Profil';

  @override
  String get profileEditSub => 'Perbarui informasi dan identitas profil';

  @override
  String get profileAddTitle => 'Tambah Profil Baru';

  @override
  String get profileAddSub => 'Tambah akun profil baru di perangkat';

  @override
  String get healthFourPillars => '4 Pilar Rasio Keuangan';

  @override
  String get healthIndexPrefix => 'INDEKS';

  @override
  String get healthLiquidAssets => 'Likuiditas Rekening';

  @override
  String get healthPocketReserves => 'Cadangan Kantong';

  @override
  String get healthNotesActions => 'CATATAN & TINDAKAN';

  @override
  String get healthTierExcellent => 'Prima';

  @override
  String get healthTierGood => 'Stabil';

  @override
  String get healthTierCaution => 'Waspada';

  @override
  String get healthTierDeficit => 'Kritis';

  @override
  String get healthHeadlineExcellent => 'Keuanganmu Berada di Kondisi Prima!';

  @override
  String get healthHeadlineGood => 'Keuangan Stabil, Siap Ditingkatkan.';

  @override
  String get healthHeadlineCaution => 'Perlu Penyesuaian Pengeluaran.';

  @override
  String get healthHeadlineDeficit => 'Arus Kas Memerlukan Evaluasi Segera.';

  @override
  String get healthPillar1Title => 'Dana Darurat (Runway)';

  @override
  String get healthPillar1DescPocket =>
      'Cadangan di Kantong Darurat & saldo kas';

  @override
  String get healthPillar1DescNoPocket =>
      'Kemampuan bertahan jika tanpa pemasukan';

  @override
  String healthPillar1Value(String months) {
    return '$months Bulan';
  }

  @override
  String get healthPillar1Bench => 'Ideal: ≥ 3–6 Bulan';

  @override
  String get healthPillar2Title => 'Beban Tagihan Tetap';

  @override
  String get healthPillar2Desc => 'Porsi langganan & cicilan dari pemasukan';

  @override
  String get healthPillar2Bench => 'Ideal: ≤ 30%';

  @override
  String get healthPillar3Title => 'Margin Tabungan Bersih';

  @override
  String get healthPillar3Desc => 'Sisa arus kas yang berhasil disimpan';

  @override
  String get healthPillar3Bench => 'Ideal: ≥ 15–20%';

  @override
  String get healthPillar4Title => 'Disiplin Belanja Harian';

  @override
  String get healthPillar4Desc => 'Kepatuhan pengeluaran terhadap batas aman';

  @override
  String get healthPillar4Bench => 'Target: Sangat Aman';

  @override
  String healthRecPillar1PocketLow(String current, String gap, String target) {
    return 'Di Kantong: $current • Rekomendasi isi $gap menuju 3 bln ($target)';
  }

  @override
  String healthRecPillar1PocketMid(String current, String gap, String target) {
    return 'Kantong Darurat ($current) aman 3 bln! • Tambah $gap menuju 6 bln ($target)';
  }

  @override
  String healthRecPillar1PocketFull(String current, String target) {
    return 'Kantong Darurat prima ($current)! • Target 6 bln ($target) terpenuhi penuh';
  }

  @override
  String healthRecPillar1NoPocketLow(String target, String gap) {
    return 'Target 3 bln: $target • Rekomendasi buat Kantong Darurat & isi $gap';
  }

  @override
  String healthRecPillar1NoPocketOk(String liquid, String target) {
    return 'Saldo rekening $liquid cukup 3 bln ($target) • Rekomendasi kunci ke Kantong Darurat agar aman';
  }

  @override
  String healthRecPillar2Ok(String bills, String maxBills) {
    return 'Tagihan $bills/bln • Batas ideal 30%: Maks $maxBills/bln (Sangat Aman)';
  }

  @override
  String healthRecPillar2High(String bills, String maxBills, String excess) {
    return 'Tagihan $bills/bln lewat 30% ($maxBills/bln) • Pangkas $excess';
  }

  @override
  String healthRecPillar3Ok(String saved, String target) {
    return 'Tabungan $saved/bln • Target 20% ($target/bln) tercapai prima!';
  }

  @override
  String healthRecPillar3Mid(String saved, String gap) {
    return 'Tabungan $saved/bln • Rekomendasi tambah $gap/bln menuju 20%';
  }

  @override
  String healthRecPillar3Deficit(String target) {
    return 'Arus kas defisit • Rem belanja agar bisa menabung target 20% ($target/bln)';
  }

  @override
  String healthRecPillar4Ok(String daily, String monthly) {
    return 'Batas belanja aman $daily/hari • Sisa Safe-to-Spend: $monthly';
  }

  @override
  String healthRecPillar4Caution(String daily) {
    return 'Pacing waspada • Jaga belanja maksimal $daily/hari agar saldo tidak tergerus';
  }

  @override
  String get healthRecPillar4Deficit =>
      'Anggaran defisit • Tunda pengeluaran variabel dan dahulukan kebutuhan esensial';

  @override
  String healthRecEmergency(String target) {
    return 'Target dana darurat 3 bulanmu $target. Prioritaskan transfer berkala ke Kantong Darurat.';
  }

  @override
  String healthRecBills(String bills, String maxBills) {
    return 'Beban tagihan rutin mencapai $bills/bln (batas aman $maxBills/bln). Evaluasi tagihan yang kurang bernilai guna.';
  }

  @override
  String healthRecSavings(String saved, String target) {
    return 'Margin tabungan bulan ini baru $saved. Targetkan simpanan minimal $target (20%) di awal gajian.';
  }

  @override
  String healthRecPacing(String daily) {
    return 'Pacing belanja harian mendekati batas aman ($daily/hari). Rem pengeluaran variabel agar alokasi tetap terjaga.';
  }

  @override
  String get healthRecNoPockets =>
      'Kamu belum memiliki Kantong Tabungan. Buat kantong alokasi untuk memisahkan dana jajan dari simpanan.';

  @override
  String get healthRecAllGood =>
      'Kondisi keuanganmu luar biasa prima! Cadangan darurat dan rasio simpanan aman, lanjutkan alokasi jangka panjang.';

  @override
  String get inboxJustNow => 'Baru saja';

  @override
  String inboxMinutesAgo(int minutes) {
    return '$minutes mnt lalu';
  }

  @override
  String get inboxPickWallet => 'Pilih Dompet';

  @override
  String get inboxSwipeHint => 'Geser kanan untuk terima, kiri untuk tolak';

  @override
  String get inboxEditTitle => 'Sesuaikan Transaksi';

  @override
  String inboxEditSubWallet(String walletName) {
    return 'Rekening: $walletName';
  }

  @override
  String get inboxEditSubDefault => 'Ubah nominal & tipe transaksi';

  @override
  String get inboxEditAmountLabel => 'NOMINAL TRANSAKSI';

  @override
  String get inboxEditMerchantLabel => 'MERCHANT / PENERIMA / CATATAN';

  @override
  String get inboxEditMerchantHint => 'Contoh: Kopi Kenangan, Transfer Budi';

  @override
  String get inboxEditSaveBtn => 'Simpan Perubahan';

  @override
  String get inboxReassignTitle => 'Pilih Dompet / Workspace';

  @override
  String get inboxReassignSub =>
      'Alihkan transaksi auto-log ini ke rekening atau akun yang benar.';

  @override
  String get inboxReassignMainAccount => 'Akun Utama';

  @override
  String inboxReassignSuccess(String profileName, String walletName) {
    return 'Dialihkan ke $profileName • $walletName';
  }

  @override
  String get inboxSnackConfirmed => 'Transaksi terkonfirmasi benar';

  @override
  String get inboxSnackRejected => 'Transaksi dibatalkan & saldo dipulihkan';

  @override
  String get inboxSnackEdited => 'Transaksi berhasil disesuaikan';

  @override
  String get catAddBtn => '+ Tambah';

  @override
  String get catCancelBtn => 'Batal';

  @override
  String get catSaveBtn => 'Simpan';

  @override
  String get catDefaultFood => 'Makanan & Minuman';

  @override
  String get catDefaultTransport => 'Transportasi';

  @override
  String get catDefaultShopping => 'Belanja & Kebutuhan';

  @override
  String get catDefaultBills => 'Tagihan & Utilitas';

  @override
  String get catDefaultEntertainment => 'Hiburan & Langganan';

  @override
  String get catDefaultHealth => 'Kesehatan';

  @override
  String get catDefaultEducation => 'Pendidikan & Kursus';

  @override
  String get healthStatusComfortable => 'Sangat Aman';

  @override
  String get healthStatusCaution => 'Perlu Hati-Hati';

  @override
  String get healthStatusDeficit => 'Defisit Tagihan';

  @override
  String get swipeConfirmCorrect => 'Benar';

  @override
  String get swipeRejectWrong => 'Salah';

  @override
  String get notifStreakExceededTitle => 'Batas Belanja Harian Terlampaui';

  @override
  String notifStreakExceededWithStreak(int streak) {
    return 'Pengeluaran hari ini telah melampaui kuota harian. Pertahankan kendali agar streak hemat $streak hari tidak terhenti.';
  }

  @override
  String get notifStreakExceededBody =>
      'Pengeluaran hari ini telah melampaui kuota harian Safe-to-Spend. Tahan pengeluaran sebelum siklus berganti.';

  @override
  String get notifStreakNearTitle => 'Mendekati Batas Belanja Harian';

  @override
  String notifStreakNearWithStreak(int percent, int streak) {
    return 'Pengeluaran hari ini mencapai $percent% dari kuota. Batasi belanja agar streak hemat $streak hari tetap terjaga.';
  }

  @override
  String notifStreakNearBody(int percent) {
    return 'Pengeluaran hari ini telah mencapai $percent% dari alokasi harian Safe-to-Spend.';
  }

  @override
  String notifBillH3Title(String title) {
    return 'Tagihan $title (H-3)';
  }

  @override
  String notifBillH3Body(String amount, int day) {
    return '$amount jatuh tempo 3 hari lagi (Tgl $day).';
  }

  @override
  String notifBillH1Title(String title) {
    return 'Tagihan $title Besok';
  }

  @override
  String notifBillH1Body(String amount) {
    return '$amount jatuh tempo besok. Pastikan saldo cukup.';
  }

  @override
  String notifBillH0Title(String title) {
    return 'Tagihan $title Hari Ini';
  }

  @override
  String notifBillH0Body(String amount) {
    return '$amount jatuh tempo hari ini. Buka untuk tandai lunas.';
  }

  @override
  String notifAutoDeductTitle(String title) {
    return 'Tagihan Berhasil Didebet: $title';
  }

  @override
  String notifAutoDeductBody(String amount) {
    return 'Pembayaran $amount telah otomatis dipotong dari dompet.';
  }

  @override
  String get dailyPaceRemainingDays => 'Sisa Hari Bulan Ini';

  @override
  String dailyPaceDaysCount(int days) {
    return '$days Hari';
  }

  @override
  String get dailyPaceSafeLimit => 'Batas Aman Belanja / Hari';

  @override
  String get dailyPaceTodayExpense => 'Pengeluaran Hari Ini';

  @override
  String get dailyPaceRemainingQuota => 'Sisa Kuota Hari Ini';

  @override
  String get dailyPaceOverQuota => 'Melebihi Kuota';

  @override
  String get dailyPaceFooter =>
      'Menjaga belanja rata-rata harian Anda di bawah angka ini akan menjamin keuangan tetap surplus hingga akhir bulan.';

  @override
  String stsStatusPrefix(String status) {
    return 'Status: $status';
  }

  @override
  String stsTotalAssetsCount(int count) {
    return 'Total Aset ($count Akun)';
  }

  @override
  String get stsPerDaySuffix => '/ hr';

  @override
  String get stsAllWalletsDesc =>
      'Dihitung dari seluruh rekening Anda. Uang ini aman dibelanjakan tanpa khawatir tagihan bulanan gagal bayar.';

  @override
  String stsSelectedWalletsDesc(int count) {
    return 'Dihitung hanya dari rekening operasional ($count rekening). Tagihan dan saldo rekening tabungan lain tidak dicampur.';
  }

  @override
  String get stsSettingsHint =>
      'Pilihan rekening operasional dapat diatur di Pengaturan > Siklus Anggaran & Safe-to-Spend.';

  @override
  String get chartLegendIn => 'Masuk';

  @override
  String get chartLegendOut => 'Keluar';

  @override
  String get walletDeckEmptyTitle => 'Belum Ada Rekening';

  @override
  String get walletDeckEmptyDesc =>
      'Belum ada rekening atau dompet digital yang terhubung.';

  @override
  String get walletDeckEmptyHint => 'Ketuk tombol + di bawah untuk menambahkan';

  @override
  String get manageLabel => 'Kelola';

  @override
  String get searchTxHint => 'Cari transaksi, rekening, merchant...';

  @override
  String get filterTxTitle => 'Filter Transaksi';

  @override
  String get filterTxTypeHeader => 'TIPE TRANSAKSI';

  @override
  String filterChipTypePrefix(String label) {
    return 'Tipe: $label';
  }

  @override
  String filterChipStatusPrefix(String label) {
    return 'Status: $label';
  }

  @override
  String get walletAvailableBalance => 'Saldo Tersedia';

  @override
  String pocketTxFrom(String wallet, String date) {
    return 'Dari $wallet • $date';
  }

  @override
  String pocketTxTo(String wallet, String date) {
    return 'Ke $wallet • $date';
  }

  @override
  String get pocketTxDepositDefault => 'Setoran Kantong';

  @override
  String get pocketTxWithdrawDefault => 'Penarikan Kantong';

  @override
  String walletDetailSearchResults(int count) {
    return 'Hasil Pencarian ($count)';
  }

  @override
  String get walletDetailHistoryTitle => 'Riwayat Transaksi';

  @override
  String walletDetailTxCount(int count) {
    return '$count transaksi';
  }

  @override
  String get walletDetailNoMatch => 'Tidak ada transaksi yang cocok';

  @override
  String get walletDetailNoMutations => 'Belum ada mutasi transaksi';

  @override
  String get walletDetailOfflineBadge => 'Offline & Terenkripsi';

  @override
  String get walletDetailPickAppTitle => 'Pilih Aplikasi';

  @override
  String get walletDetailPickAppSub => 'Cari bank atau e-wallet di HP Anda';

  @override
  String walletDetailAdjustTitle(String name) {
    return 'Penyesuaian Saldo: $name';
  }

  @override
  String get walletDetailAdjustSub => 'Ubah saldo awal & preferensi rekening';

  @override
  String get walletDetailTxTitle => 'Catat Transaksi';

  @override
  String walletDetailTxSub(String name) {
    return 'Rekening: $name';
  }

  @override
  String historySearchCount(int count) {
    return 'Hasil Pencarian: $count Transaksi';
  }

  @override
  String historyFilterCount(int count) {
    return 'Hasil Filter: $count Transaksi';
  }

  @override
  String historyDayTxCount(int count) {
    return '//  $count TRANSAKSI';
  }

  @override
  String get historyEmptyDate => 'Tidak Ada Transaksi di Tanggal Ini';

  @override
  String get historyTitleCalendar => 'Aktivitas\nKeuangan';

  @override
  String get historyTitleDefault => 'Riwayat\nTransaksi';

  @override
  String get historySubCalendar => 'Kalender Aktivitas & Arus Kas';

  @override
  String historySubFiltered(String amount) {
    return 'Total Terfilter: $amount';
  }

  @override
  String get historyTooltipCard => 'Tampilan Kartu';

  @override
  String get historyTooltipCalendar => 'Kalender Aktivitas';

  @override
  String get txEditSubDefault => 'Ubah rincian mutasi transaksi';

  @override
  String get txWalletDefault => 'Rekening';

  @override
  String pocketMutationsCount(int count) {
    return '$count mutasi';
  }

  @override
  String get pocketDeleteLabel => 'Hapus Kantong';

  @override
  String get pocketDepositBtn => 'Isi Dana';

  @override
  String get pocketWithdrawBtn => 'Tarik Dana';

  @override
  String get pocketDepositSheetTitle => 'Isi Dana ke Kantong';

  @override
  String get pocketWithdrawSheetTitle => 'Tarik Dana ke Rekening';

  @override
  String pocketDepositSheetSub(String name) {
    return 'Pilih rekening asal untuk memindahkan dana ke $name.';
  }

  @override
  String pocketWithdrawSheetSub(String name) {
    return 'Pilih rekening tujuan penarikan dari $name.';
  }

  @override
  String get pocketNameRequired => 'Nama kantong wajib diisi';

  @override
  String pocketInsufficientBalance(String max) {
    return 'Saldo tidak cukup (Maks $max)';
  }

  @override
  String get pocketCreateNow => 'Buat Kantong Sekarang';

  @override
  String get subsNotFoundTitle => 'Tagihan Tidak Ditemukan';

  @override
  String subsNotFoundQuery(String query) {
    return 'Tidak ada tagihan yang cocok dengan \"$query\".';
  }

  @override
  String get subsNotFoundFilter => 'Tidak ada tagihan dalam filter ini.';

  @override
  String get subsHintExample => 'cth: Netflix, Spotify, Listrik PLN, Kosan';

  @override
  String get subsDeleteInstallment => 'Hapus Cicilan Ini';

  @override
  String get subsDeleteSub => 'Hapus Langganan Ini';

  @override
  String get walletDeletedTitle => 'Rekening Dihapus';

  @override
  String get walletSaveBtn => 'Simpan Rekening';

  @override
  String get pocketDeletedTitle => 'Kantong Dihapus';

  @override
  String get profileMenuNewTitle => 'Profil Baru';

  @override
  String get profileMenuHealthTitle => 'Detail Kesehatan Keuangan';

  @override
  String get profileMenuHealthSub =>
      'Audit komprehensif 4 pilar kesehatan keuangan';

  @override
  String get profileMenuShareTitle => 'Bagikan Profil';

  @override
  String get profileMenuShareSub => 'Bagikan kartu profil finansial';

  @override
  String get profileCopiedTitle => 'Profil Disalin';

  @override
  String get profileCopiedMsg => 'Kartu profil berhasil disalin ke clipboard!';

  @override
  String get profileUpdatedTitle => 'Profil Diperbarui';

  @override
  String profileUpdatedMsg(String username) {
    return 'Profil \"$username\" berhasil diperbarui!';
  }

  @override
  String get profileCreatedTitle => 'Profil Dibuat';

  @override
  String profileCreatedMsg(String username) {
    return 'Profil \"$username\" berhasil dibuat!';
  }

  @override
  String get profileCreateBtn => 'Buat Profil Baru';

  @override
  String get profileDeleteTitle => 'Hapus Profil?';

  @override
  String get profileResetTitle => 'Reset Profil?';

  @override
  String profileDeleteMsg(String username) {
    return 'Profil \"$username\" akan dihapus. Anda dapat beralih ke profil lain yang masih tersimpan.';
  }

  @override
  String profileResetMsg(String username) {
    return 'Profil \"$username\" adalah satu-satunya profil. Profil akan direset ke pengaturan default.';
  }

  @override
  String get profileDeletedTitle => 'Profil Dihapus';

  @override
  String get profileResetDoneTitle => 'Profil Direset';

  @override
  String profileDeletedMsg(String username) {
    return 'Profil \"$username\" berhasil dihapus.';
  }

  @override
  String get profileResetDoneMsg => 'Profil berhasil direset.';

  @override
  String get profileCardRealBalance => 'SALDO RIIL';

  @override
  String get profileCardBills => 'TAGIHAN';

  @override
  String get profileCardSafe => 'SISA AMAN';

  @override
  String get avatarTitle => 'Foto Profil';

  @override
  String get avatarActiveSub => 'Foto kustom aktif • Ketuk untuk ganti';

  @override
  String get avatarEmptySub => 'Ketuk untuk pilih dari galeri atau kamera';

  @override
  String get avatarErrorTitle => 'Gagal Mengambil Foto';

  @override
  String get avatarPickerTitle => 'Pilih Sumber Foto';

  @override
  String get avatarPickerSub => 'Galeri perangkat atau kamera';

  @override
  String get avatarGalleryTitle => 'Galeri Foto';

  @override
  String get avatarGallerySub => 'Pilih gambar dari galeri perangkat';

  @override
  String get avatarCameraTitle => 'Kamera';

  @override
  String get avatarCameraSub => 'Ambil foto baru langsung dari kamera';

  @override
  String get avatarRemoveTitle => 'Hapus Foto Profil';

  @override
  String get avatarRemoveSub => 'Gunakan inisial nama sebagai avatar';

  @override
  String settingsMonthlyTargetHeader(String currency) {
    return 'NOMINAL TARGET BULANAN ($currency)';
  }

  @override
  String get settingsCyclePresetHeader => 'PRESET TANGGAL SIKLUS';

  @override
  String settingsCycleDayEveryMonth(int day) {
    return 'Tanggal $day setiap bulan';
  }

  @override
  String get settingsCycleCustomHeader => 'TANGGAL KUSTOM (1–31)';

  @override
  String get settingsCycleDatePrefix => 'Tanggal ';

  @override
  String get settingsCycleApplyBtn => 'Terapkan';

  @override
  String settingsCycleDaysRemaining(int days) {
    return '$days hari tersisa pada siklus berjalan saat ini.';
  }

  @override
  String get settingsStsOperationalHeader => 'REKENING DANA OPERASIONAL';

  @override
  String settingsStsAllWallets(int count) {
    return 'Semua Rekening ($count)';
  }

  @override
  String get onboardingWalletQuestion => 'Di mana uangmu sekarang?';

  @override
  String get onboardingWalletHelper =>
      'Tambahkan rekening pertamamu. Rekening lainnya bisa ditambahkan nanti.';

  @override
  String get onboardingWalletHint => 'Misal: BCA, Jago, atau Kas Dompet';

  @override
  String get onboardingWalletTypeLabel => 'Jenis rekening';

  @override
  String get onboardingWalletTypeCash => 'Tunai';

  @override
  String get onboardingWalletBalanceLabel => 'Saldo saat ini';

  @override
  String walletDeletedMsg(String name) {
    return 'Rekening \"$name\" berhasil dihapus.';
  }

  @override
  String get catTimelineTapHint => 'Ketuk kapsul untuk detail';

  @override
  String catTimelineTxCount(int count) {
    return '$count transaksi';
  }

  @override
  String get catTimelineDelete => 'Hapus Kategori';

  @override
  String get catEditAction => 'Ubah';

  @override
  String get catDeleteConfirmTitle => 'Hapus Kategori?';

  @override
  String catDeleteConfirmBody(String name) {
    return 'Kategori \"$name\" akan dihapus dari daftar pilihan.';
  }

  @override
  String get onboardingWalletBalanceHelper =>
      'Opsional. Biarkan 0 jika ingin mulai dari nol.';

  @override
  String get onbTopBarReady => 'Siap!';

  @override
  String onbTopBarStep(int step, int total) {
    return 'Langkah $step dari $total';
  }

  @override
  String get onbUsernameTakenTitle => 'Username sudah dipakai';

  @override
  String get onbUsernameTakenMsg =>
      'Pilih username lain untuk profil baru ini.';

  @override
  String onbIncomePerDay(String amount) {
    return '≈ $amount per hari';
  }

  @override
  String get kofiPromptTitle => 'Suka pakai fiBOnanci?';

  @override
  String get kofiPromptBody =>
      'fiBOnanci 100% gratis, offline, dan tanpa iklan. Kalau aplikasi ini membantu mengatur keuanganmu, traktir kopi untuk developer di Ko-fi yuk.';

  @override
  String get kofiPromptSupportBtn => 'Dukung di Ko-fi';

  @override
  String get kofiPromptLaterBtn => 'Nanti saja';

  @override
  String get kofiPromptNeverBtn => 'Jangan tampilkan lagi';

  @override
  String get kofiAboutRowTitle => 'Dukung Developer (Ko-fi)';

  @override
  String get aboutSectionUpdates => 'STATUS & PEMBARUAN APLIKASI';

  @override
  String get aboutSectionSpecs => 'TENTANG & ARSITEKTUR APLIKASI';

  @override
  String get aboutAutoUpdate => 'Pembaruan Otomatis';

  @override
  String get aboutConnectingGithub => 'Menghubungkan ke GitHub Releases...';

  @override
  String aboutVersionReady(String version) {
    return 'Versi v$version Siap Diunduh!';
  }

  @override
  String get aboutDownloadInstallBtn => 'Unduh & Pasang Pembaruan';

  @override
  String get aboutReleaseNotesTitle => 'Catatan Rilis:';

  @override
  String aboutUpToDate(String version) {
    return 'Aplikasi Sudah Versi Terbaru (v$version)';
  }

  @override
  String get aboutNotChecked => 'Belum diperiksa ke repositori rilis';

  @override
  String get aboutCheckNowBtn => 'Periksa Pembaruan Sekarang';

  @override
  String get aboutPrivacyDesc =>
      'Data keuangan Anda disimpan 100% offline di perangkat tanpa cloud atau tracking. Koneksi internet hanya digunakan secara opsional saat memeriksa pembaruan atau membuka halaman dukungan Ko-fi.';

  @override
  String get aboutLicenseTitle => 'Lisensi Perangkat Lunak';

  @override
  String get aboutStorageTitle => 'Penyimpanan Database';

  @override
  String get aboutParserTitle => 'Parser Notifikasi Bank';

  @override
  String get aboutGithubTitle => 'Repositori GitHub';

  @override
  String get aboutReleasesTitle => 'Catatan Rilis Lengkap';

  @override
  String get aboutOpenBrowser => 'Buka di Aplikasi';

  @override
  String get webViewErrorTitle => 'Halaman tidak dapat dimuat';

  @override
  String get webViewErrorBody =>
      'Pastikan perangkat terhubung ke internet lalu coba lagi.';

  @override
  String get webViewRetryBtn => 'Coba Lagi';

  @override
  String get onbLangTitle => 'Pilih Bahasa';

  @override
  String get onbLangSubtitle =>
      'Pilih bahasa yang ingin digunakan. Kamu bisa mengubahnya kapan saja di Pengaturan.';

  @override
  String get onbLangIdTitle => 'Bahasa Indonesia';

  @override
  String get onbLangIdSub => 'Antarmuka bahasa Indonesia';

  @override
  String get onbLangEnTitle => 'English';

  @override
  String get onbLangEnSub => 'Antarmuka bahasa Inggris';

  @override
  String get onlineRequiredBadge =>
      'Memeriksa rilis terbaru via GitHub saat dibuka';

  @override
  String get aboutCheckOfflineError =>
      'Gagal memeriksa pembaruan. Coba lagi nanti.';

  @override
  String get kofiRequiresInternetHint =>
      'Membuka halaman Ko-fi membutuhkan koneksi internet';

  @override
  String get subModalPaymentSource => 'SUMBER DANA PEMBAYARAN';

  @override
  String get subModalAutoDeductTitle => 'Auto-Deduct Saldo';

  @override
  String get subModalAutoDeductSubtitle =>
      'Potong saldo otomatis saat tgl jatuh tempo';

  @override
  String get subDeletedSnackTitle => 'Tagihan Dihapus';

  @override
  String get subDeletedSnackMsg =>
      'Tagihan berhasil dihapus & saldo rekening dikembalikan.';

  @override
  String get subDeletedSnackTag => 'HAPUS';

  @override
  String get subDeleteThisBtn => 'Hapus Langganan Ini';

  @override
  String get subDueDateHeader => 'TANGGAL JATUH TEMPO';

  @override
  String subDueDayEveryMonth(int day) {
    return 'Tgl $day setiap bulan';
  }

  @override
  String get subInstallmentDeadlineHeader => 'TENGGAT WAKTU CICILAN (WAJIB)';

  @override
  String subInstallmentFinishDate(String date) {
    return 'Selesai $date';
  }

  @override
  String get subInstallmentCustomBtn => 'Custom';

  @override
  String get subTenorDurationLabel => 'Durasi Tenor';

  @override
  String get subTenorMonthsShort => 'Bln';

  @override
  String subInstallmentCardSubtitle(int cycles) {
    return 'cicilan /bulan (tenor $cycles bln)';
  }

  @override
  String get subSpecPaymentProgress => 'Progress Pembayaran';
}
