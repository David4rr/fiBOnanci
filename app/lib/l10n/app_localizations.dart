import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @navDashboard.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navDashboard;

  /// No description provided for @navWallets.
  ///
  /// In id, this message translates to:
  /// **'Wallets'**
  String get navWallets;

  /// No description provided for @navSubscriptions.
  ///
  /// In id, this message translates to:
  /// **'Tagihan'**
  String get navSubscriptions;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get navHistory;

  /// No description provided for @historyButton.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get historyButton;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Pengguna'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan identitas & performa finansial'**
  String get profileSubtitle;

  /// No description provided for @financialReportTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan Keuangan'**
  String get financialReportTitle;

  /// No description provided for @financialReportSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Analisis arus kas, kategori, & distribusi rekening'**
  String get financialReportSubtitle;

  /// No description provided for @financialHealthTitle.
  ///
  /// In id, this message translates to:
  /// **'Audit Kesehatan Finansial'**
  String get financialHealthTitle;

  /// No description provided for @financialHealthSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan rasio arus kas, aset, & tagihan riil'**
  String get financialHealthSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Preferensi finansial, kategori, otomasi, & data lokal'**
  String get settingsSubtitle;

  /// No description provided for @settingsGlobalHeader.
  ///
  /// In id, this message translates to:
  /// **'PENGATURAN GLOBAL • SEMUA PROFIL'**
  String get settingsGlobalHeader;

  /// No description provided for @settingsHideBalance.
  ///
  /// In id, this message translates to:
  /// **'Samarkan Nominal Saldo'**
  String get settingsHideBalance;

  /// No description provided for @settingsHighRefreshRate.
  ///
  /// In id, this message translates to:
  /// **'Mode Layar 120Hz (High FPS)'**
  String get settingsHighRefreshRate;

  /// No description provided for @settingsBiometricLock.
  ///
  /// In id, this message translates to:
  /// **'Kunci Biometrik / PIN Aplikasi'**
  String get settingsBiometricLock;

  /// No description provided for @settingsPrivacyScreen.
  ///
  /// In id, this message translates to:
  /// **'Pelindung Layar Privasi (Recent Apps)'**
  String get settingsPrivacyScreen;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tema Tampilan'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Aplikasi'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageName.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get settingsLanguageName;

  /// No description provided for @settingsEncryptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Enkripsi Database (SQLCipher)'**
  String get settingsEncryptionLabel;

  /// No description provided for @settingsEncryptionActive.
  ///
  /// In id, this message translates to:
  /// **'AES-256 Aktif'**
  String get settingsEncryptionActive;

  /// No description provided for @settingsCategoriesLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori Transaksi'**
  String get settingsCategoriesLabel;

  /// No description provided for @settingsNotifListenerLabel.
  ///
  /// In id, this message translates to:
  /// **'Listener Notifikasi Bank'**
  String get settingsNotifListenerLabel;

  /// No description provided for @settingsBankAppsLabel.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi Bank & E-Wallet'**
  String get settingsBankAppsLabel;

  /// No description provided for @settingsAboutAppLabel.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi & Pembaruan'**
  String get settingsAboutAppLabel;

  /// No description provided for @settingsDataBackupHeader.
  ///
  /// In id, this message translates to:
  /// **'DATA & CADANGAN • @{username}'**
  String settingsDataBackupHeader(String username);

  /// No description provided for @settingsDangerZoneHeader.
  ///
  /// In id, this message translates to:
  /// **'ZONA BAHAYA • @{username}'**
  String settingsDangerZoneHeader(String username);

  /// No description provided for @settingsExportCsv.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Transaksi (CSV / Excel)'**
  String get settingsExportCsv;

  /// No description provided for @settingsExportJson.
  ///
  /// In id, this message translates to:
  /// **'Simpan Cadangan (JSON)'**
  String get settingsExportJson;

  /// No description provided for @settingsImportJson.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan Cadangan (Import JSON)'**
  String get settingsImportJson;

  /// No description provided for @settingsClearTx.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan Riwayat Transaksi'**
  String get settingsClearTx;

  /// No description provided for @settingsDeleteProfile.
  ///
  /// In id, this message translates to:
  /// **'Hapus / Reset Profil Aktif'**
  String get settingsDeleteProfile;

  /// No description provided for @reportExpenses.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get reportExpenses;

  /// No description provided for @reportIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get reportIncome;

  /// No description provided for @reportAllFlow.
  ///
  /// In id, this message translates to:
  /// **'Semua Arus'**
  String get reportAllFlow;

  /// No description provided for @reportWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get reportWeek;

  /// No description provided for @reportMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get reportMonth;

  /// No description provided for @reportQuarter.
  ///
  /// In id, this message translates to:
  /// **'Kuartal'**
  String get reportQuarter;

  /// No description provided for @reportTransactionsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Transaksi'**
  String reportTransactionsCount(int count);

  /// No description provided for @reportAssetsTitle.
  ///
  /// In id, this message translates to:
  /// **'POSISI ASET & KEWAJIBAN'**
  String get reportAssetsTitle;

  /// No description provided for @reportTotalNetWorth.
  ///
  /// In id, this message translates to:
  /// **'Total Kekayaan Bersih'**
  String get reportTotalNetWorth;

  /// No description provided for @reportActiveWalletBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Rekening Aktif'**
  String get reportActiveWalletBalance;

  /// No description provided for @reportPocketBalance.
  ///
  /// In id, this message translates to:
  /// **'Dana Kantong Tabungan'**
  String get reportPocketBalance;

  /// No description provided for @reportCommittedBills.
  ///
  /// In id, this message translates to:
  /// **'Komitmen Tagihan Bulanan'**
  String get reportCommittedBills;

  /// No description provided for @reportWalletActivityTitle.
  ///
  /// In id, this message translates to:
  /// **'AKTIVITAS PER REKENING'**
  String get reportWalletActivityTitle;

  /// No description provided for @reportEmptyWallets.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rekening aktif'**
  String get reportEmptyWallets;

  /// No description provided for @reportEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get reportEmptyTitle;

  /// No description provided for @reportEmptyDesc.
  ///
  /// In id, this message translates to:
  /// **'Catat transaksi pada periode ini untuk melihat rincian kategori.'**
  String get reportEmptyDesc;

  /// No description provided for @dashboardSafeToSpendFiltered.
  ///
  /// In id, this message translates to:
  /// **'Safe to Spend ({count} Akun)'**
  String dashboardSafeToSpendFiltered(int count);

  /// No description provided for @dashboardRealAccounts.
  ///
  /// In id, this message translates to:
  /// **'{count} Akun Riil'**
  String dashboardRealAccounts(int count);

  /// No description provided for @dashboardBillsThisMonth.
  ///
  /// In id, this message translates to:
  /// **'{count} Tagihan Bln Ini'**
  String dashboardBillsThisMonth(int count);

  /// No description provided for @dashboardHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get dashboardHistoryTitle;

  /// No description provided for @dashboardSearchResults.
  ///
  /// In id, this message translates to:
  /// **'Hasil Pencarian ({count})'**
  String dashboardSearchResults(int count);

  /// No description provided for @dashboardViewAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get dashboardViewAll;

  /// No description provided for @walletsMainAccounts.
  ///
  /// In id, this message translates to:
  /// **'Rekening Utama ({count})'**
  String walletsMainAccounts(int count);

  /// No description provided for @walletsSavingsPockets.
  ///
  /// In id, this message translates to:
  /// **'Kantong Tabungan ({count})'**
  String walletsSavingsPockets(int count);

  /// No description provided for @walletsTotalRealBalance.
  ///
  /// In id, this message translates to:
  /// **'TOTAL SALDO RIIL'**
  String get walletsTotalRealBalance;

  /// No description provided for @walletsFlowIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get walletsFlowIn;

  /// No description provided for @walletsFlowOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get walletsFlowOut;

  /// No description provided for @subsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tagihan & Langganan'**
  String get subsTitle;

  /// No description provided for @subsRegisteredCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Kartu Terdaftar • Diurutkan jatuh tempo'**
  String subsRegisteredCount(int count);

  /// No description provided for @subsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Tagihan Rutin'**
  String get subsEmptyTitle;

  /// No description provided for @subsEmptyDesc.
  ///
  /// In id, this message translates to:
  /// **'Daftarkan langganan Netflix, Spotify, atau cicilan agar jatuh tempo tercatat rapi.'**
  String get subsEmptyDesc;

  /// No description provided for @subsEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk tombol + di bawah untuk menambahkan'**
  String get subsEmptyHint;

  /// No description provided for @subsSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari tagihan, langganan, rekening...'**
  String get subsSearchHint;

  /// No description provided for @subsFilterTitle.
  ///
  /// In id, this message translates to:
  /// **'Filter Tagihan'**
  String get subsFilterTitle;

  /// No description provided for @subsFilterStatusHeader.
  ///
  /// In id, this message translates to:
  /// **'STATUS PEMBAYARAN'**
  String get subsFilterStatusHeader;

  /// No description provided for @profileMenuTitle.
  ///
  /// In id, this message translates to:
  /// **'Menu Profil'**
  String get profileMenuTitle;

  /// No description provided for @profileMenuNew.
  ///
  /// In id, this message translates to:
  /// **'Tambah akun profil baru'**
  String get profileMenuNew;

  /// No description provided for @profileMenuHealth.
  ///
  /// In id, this message translates to:
  /// **'Audit komprehensif keuangan'**
  String get profileMenuHealth;

  /// No description provided for @profileMenuReport.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan arus kas & kategori'**
  String get profileMenuReport;

  /// No description provided for @profileMenuSettings.
  ///
  /// In id, this message translates to:
  /// **'Mata uang, kategori, & data lokal'**
  String get profileMenuSettings;

  /// No description provided for @profileMenuShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan kartu profil finansial'**
  String get profileMenuShare;

  /// No description provided for @profileDataHeader.
  ///
  /// In id, this message translates to:
  /// **'DATA UMUM & DETAIL AKUN'**
  String get profileDataHeader;

  /// No description provided for @profileOccupation.
  ///
  /// In id, this message translates to:
  /// **'Profesi / Pekerjaan'**
  String get profileOccupation;

  /// No description provided for @profilePhone.
  ///
  /// In id, this message translates to:
  /// **'No. Handphone'**
  String get profilePhone;

  /// No description provided for @profileBio.
  ///
  /// In id, this message translates to:
  /// **'Bio / Catatan'**
  String get profileBio;

  /// No description provided for @profilePrimaryCurrency.
  ///
  /// In id, this message translates to:
  /// **'Mata Uang Utama'**
  String get profilePrimaryCurrency;

  /// No description provided for @profileIncomeTarget.
  ///
  /// In id, this message translates to:
  /// **'Target Pemasukan'**
  String get profileIncomeTarget;

  /// No description provided for @profileConnectedWallets.
  ///
  /// In id, this message translates to:
  /// **'Rekening Terhubung'**
  String get profileConnectedWallets;

  /// No description provided for @profileConnectedWalletsVal.
  ///
  /// In id, this message translates to:
  /// **'{count} Akun'**
  String profileConnectedWalletsVal(int count);

  /// No description provided for @profileTotalTx.
  ///
  /// In id, this message translates to:
  /// **'Total Transaksi'**
  String get profileTotalTx;

  /// No description provided for @profileTotalTxVal.
  ///
  /// In id, this message translates to:
  /// **'{count} Tercatat'**
  String profileTotalTxVal(int count);

  /// No description provided for @settingsAndroidOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya Android'**
  String get settingsAndroidOnly;

  /// No description provided for @settingsActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get settingsActive;

  /// No description provided for @settingsOff.
  ///
  /// In id, this message translates to:
  /// **'Mati'**
  String get settingsOff;

  /// No description provided for @settingsCategoriesCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Kategori'**
  String settingsCategoriesCount(int count);

  /// No description provided for @settingsSupportedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Didukung'**
  String settingsSupportedCount(int count);

  /// No description provided for @settingsProfileHeader.
  ///
  /// In id, this message translates to:
  /// **'PENGATURAN PROFIL • @{username}'**
  String settingsProfileHeader(String username);

  /// No description provided for @settingsIncomeTargetTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Pemasukan Bulanan'**
  String get settingsIncomeTargetTitle;

  /// No description provided for @settingsSetAction.
  ///
  /// In id, this message translates to:
  /// **'Atur'**
  String get settingsSetAction;

  /// No description provided for @settingsCycleDayTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Mulai Siklus'**
  String get settingsCycleDayTitle;

  /// No description provided for @settingsCycleDayValue.
  ///
  /// In id, this message translates to:
  /// **'Tgl {day} ({rem} hr)'**
  String settingsCycleDayValue(int day, int rem);

  /// No description provided for @settingsStsWalletsTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekening Safe-to-Spend'**
  String get settingsStsWalletsTitle;

  /// No description provided for @settingsAllCount.
  ///
  /// In id, this message translates to:
  /// **'Semua ({count})'**
  String settingsAllCount(int count);

  /// No description provided for @settingsActiveCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Aktif'**
  String settingsActiveCount(int count);

  /// No description provided for @profileSafe.
  ///
  /// In id, this message translates to:
  /// **'Aman'**
  String get profileSafe;

  /// No description provided for @profileDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get profileDaily;

  /// No description provided for @profileScore.
  ///
  /// In id, this message translates to:
  /// **'SKOR'**
  String get profileScore;

  /// No description provided for @profileAccounts.
  ///
  /// In id, this message translates to:
  /// **'Rekening'**
  String get profileAccounts;

  /// No description provided for @profileTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get profileTransactions;

  /// No description provided for @profileRecurringBills.
  ///
  /// In id, this message translates to:
  /// **'Tagihan Rutin'**
  String get profileRecurringBills;

  /// No description provided for @pocketsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Kantong Tabungan'**
  String get pocketsEmptyTitle;

  /// No description provided for @pocketsEmptyDesc.
  ///
  /// In id, this message translates to:
  /// **'Pisahkan dana untuk Tabungan, Dana Darurat, atau Impianmu agar aman dari belanja harian.'**
  String get pocketsEmptyDesc;

  /// No description provided for @pocketsEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk tombol + di bawah untuk membuat'**
  String get pocketsEmptyHint;

  /// No description provided for @walletTrendHeadline.
  ///
  /// In id, this message translates to:
  /// **'Tren Arus Kas (Semua Rekening)'**
  String get walletTrendHeadline;

  /// No description provided for @walletTrendSubtitle.
  ///
  /// In id, this message translates to:
  /// **'30 Hari'**
  String get walletTrendSubtitle;

  /// No description provided for @stsTotalRealBalance.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo Riil'**
  String get stsTotalRealBalance;

  /// No description provided for @stsSelectedBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Rekening Terpilih'**
  String get stsSelectedBalance;

  /// No description provided for @stsPendingBills.
  ///
  /// In id, this message translates to:
  /// **'Sisa Tagihan Bulan Ini'**
  String get stsPendingBills;

  /// No description provided for @stsSelectedBills.
  ///
  /// In id, this message translates to:
  /// **'Tagihan Terkait Terpilih'**
  String get stsSelectedBills;

  /// No description provided for @stsMonthlySafe.
  ///
  /// In id, this message translates to:
  /// **'Sisa Aman Bulan Ini'**
  String get stsMonthlySafe;

  /// No description provided for @stsDailyAllowance.
  ///
  /// In id, this message translates to:
  /// **'Alokasi Harian ({days} hr)'**
  String stsDailyAllowance(int days);

  /// No description provided for @walletScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekening & Dompet'**
  String get walletScreenTitle;

  /// No description provided for @walletConnectedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{count} rekening terhubung'**
  String walletConnectedSubtitle(int count);

  /// No description provided for @searchTransactionsHint.
  ///
  /// In id, this message translates to:
  /// **'Cari transaksi, rekening, merchant...'**
  String get searchTransactionsHint;

  /// No description provided for @searchFilterTitle.
  ///
  /// In id, this message translates to:
  /// **'Filter Transaksi'**
  String get searchFilterTitle;

  /// No description provided for @searchFilterTypeHeader.
  ///
  /// In id, this message translates to:
  /// **'TIPE TRANSAKSI'**
  String get searchFilterTypeHeader;

  /// No description provided for @dashboardEmptyWalletTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Rekening Terhubung'**
  String get dashboardEmptyWalletTitle;

  /// No description provided for @dashboardEmptyWalletDesc.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan rekening atau dompet digital untuk mulai melacak keuangan dan alokasi safe-to-spend.'**
  String get dashboardEmptyWalletDesc;

  /// No description provided for @dashboardEmptyWalletHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk tombol + di bawah untuk menambahkan'**
  String get dashboardEmptyWalletHint;

  /// No description provided for @dashboardNoMatchingTx.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi yang cocok'**
  String get dashboardNoMatchingTx;

  /// No description provided for @dashboardNoTxToday.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi hari ini'**
  String get dashboardNoTxToday;

  /// No description provided for @walletCardAvailableBalance.
  ///
  /// In id, this message translates to:
  /// **'SALDO TERSEDIA'**
  String get walletCardAvailableBalance;

  /// No description provided for @dashboardWelcome.
  ///
  /// In id, this message translates to:
  /// **'Hallo {username} selamat datang kembali!'**
  String dashboardWelcome(String username);

  /// No description provided for @hintCategoryName.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori baru...'**
  String get hintCategoryName;

  /// No description provided for @hintPocketName.
  ///
  /// In id, this message translates to:
  /// **'Nama Kantong (cth: Tabungan Pensiun, Liburan)'**
  String get hintPocketName;

  /// No description provided for @hintWalletName.
  ///
  /// In id, this message translates to:
  /// **'Nama Rekening (cth: BCA, Kas Tunai, Jago)'**
  String get hintWalletName;

  /// No description provided for @hintInitialBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Awal ({symbol})'**
  String hintInitialBalance(String symbol);

  /// No description provided for @hintAccountNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor Rekening (Opsional, cth: 5410982341)'**
  String get hintAccountNumber;

  /// No description provided for @hintNotesOptional.
  ///
  /// In id, this message translates to:
  /// **'Catatan (Opsional)'**
  String get hintNotesOptional;

  /// No description provided for @hintSubscriptionTitle.
  ///
  /// In id, this message translates to:
  /// **'cth: Netflix, Spotify, Listrik PLN, Kosan'**
  String get hintSubscriptionTitle;

  /// No description provided for @walletDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Rekening'**
  String get walletDetailTitle;

  /// No description provided for @walletDetailSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Informasi & Mutasi'**
  String get walletDetailSubtitle;

  /// No description provided for @walletBalanceAdjustTitle.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian Saldo: {name}'**
  String walletBalanceAdjustTitle(String name);

  /// No description provided for @walletBalanceAdjustSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah saldo awal & preferensi rekening'**
  String get walletBalanceAdjustSubtitle;

  /// No description provided for @walletActionEditBalance.
  ///
  /// In id, this message translates to:
  /// **'Ubah Saldo'**
  String get walletActionEditBalance;

  /// No description provided for @walletActionLogTx.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get walletActionLogTx;

  /// No description provided for @cardCategoryTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren {category} (Sen–Min)'**
  String cardCategoryTrend(String category);

  /// No description provided for @subRecurringMonthly.
  ///
  /// In id, this message translates to:
  /// **'tagihan rutin /bulan'**
  String get subRecurringMonthly;

  /// No description provided for @subRecurringYearly.
  ///
  /// In id, this message translates to:
  /// **'tagihan rutin /tahun'**
  String get subRecurringYearly;

  /// No description provided for @subBadgeCycleMonthly.
  ///
  /// In id, this message translates to:
  /// **'BULANAN'**
  String get subBadgeCycleMonthly;

  /// No description provided for @subBadgeCycleYearly.
  ///
  /// In id, this message translates to:
  /// **'TAHUNAN'**
  String get subBadgeCycleYearly;

  /// No description provided for @subBadgePaid.
  ///
  /// In id, this message translates to:
  /// **'LUNAS'**
  String get subBadgePaid;

  /// No description provided for @subBadgeMonthsLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa {count} bln'**
  String subBadgeMonthsLeft(int count);

  /// No description provided for @subBadgeInstallmentCompleted.
  ///
  /// In id, this message translates to:
  /// **'CICILAN LUNAS ({paid}/{total})'**
  String subBadgeInstallmentCompleted(int paid, int total);

  /// No description provided for @subBadgeInstallmentPaid.
  ///
  /// In id, this message translates to:
  /// **'CICILAN {paid}/{total} • LUNAS'**
  String subBadgeInstallmentPaid(int paid, String total);

  /// No description provided for @subBadgePaidThisMonth.
  ///
  /// In id, this message translates to:
  /// **'LUNAS BULAN INI'**
  String get subBadgePaidThisMonth;

  /// No description provided for @subBadgeInstallmentPrefix.
  ///
  /// In id, this message translates to:
  /// **'CICILAN {step}/{total} • '**
  String subBadgeInstallmentPrefix(int step, String total);

  /// No description provided for @subBadgeDuePrefix.
  ///
  /// In id, this message translates to:
  /// **'JATUH TEMPO '**
  String get subBadgeDuePrefix;

  /// No description provided for @subBadgeToday.
  ///
  /// In id, this message translates to:
  /// **'HARI INI'**
  String get subBadgeToday;

  /// No description provided for @subBadgeInDays.
  ///
  /// In id, this message translates to:
  /// **'H-{days}'**
  String subBadgeInDays(int days);

  /// No description provided for @subBadgeOnDay.
  ///
  /// In id, this message translates to:
  /// **'TGL {day}'**
  String subBadgeOnDay(int day);

  /// No description provided for @subSpecPaymentAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening Pembayaran'**
  String get subSpecPaymentAccount;

  /// No description provided for @subSpecCurrentBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Rekening Saat Ini'**
  String get subSpecCurrentBalance;

  /// No description provided for @subSpecPaymentMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode Pembayaran'**
  String get subSpecPaymentMethod;

  /// No description provided for @subSpecAutoDeduct.
  ///
  /// In id, this message translates to:
  /// **'Auto-Deduct Aktif'**
  String get subSpecAutoDeduct;

  /// No description provided for @subSpecPeriodStatus.
  ///
  /// In id, this message translates to:
  /// **'Status Periode Ini'**
  String get subSpecPeriodStatus;

  /// No description provided for @subSpecInstallmentDone.
  ///
  /// In id, this message translates to:
  /// **'Cicilan Selesai'**
  String get subSpecInstallmentDone;

  /// No description provided for @subSpecStatusPaid.
  ///
  /// In id, this message translates to:
  /// **'Sudah Lunas'**
  String get subSpecStatusPaid;

  /// No description provided for @subSpecStatusUnpaid.
  ///
  /// In id, this message translates to:
  /// **'Belum Dibayar'**
  String get subSpecStatusUnpaid;

  /// No description provided for @subSpecInstallmentPlan.
  ///
  /// In id, this message translates to:
  /// **'Rencana Cicilan'**
  String get subSpecInstallmentPlan;

  /// No description provided for @subSpecInstallmentProgress.
  ///
  /// In id, this message translates to:
  /// **'{paid} dari {total} bulan lunas'**
  String subSpecInstallmentProgress(int paid, int total);

  /// No description provided for @subSpecRemainingPrincipal.
  ///
  /// In id, this message translates to:
  /// **'Sisa Tagihan Pokok'**
  String get subSpecRemainingPrincipal;

  /// No description provided for @subSpecCompletionDate.
  ///
  /// In id, this message translates to:
  /// **'Tenggat Selesai'**
  String get subSpecCompletionDate;

  /// No description provided for @subSpecBillingCycle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Tagihan'**
  String get subSpecBillingCycle;

  /// No description provided for @subSpecCycleMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get subSpecCycleMonthly;

  /// No description provided for @subSpecCycleYearly.
  ///
  /// In id, this message translates to:
  /// **'Tahunan'**
  String get subSpecCycleYearly;

  /// No description provided for @subSpecDueDate.
  ///
  /// In id, this message translates to:
  /// **'Jatuh Tempo'**
  String get subSpecDueDate;

  /// No description provided for @subSpecDueEveryDay.
  ///
  /// In id, this message translates to:
  /// **'Setiap tanggal {day}'**
  String subSpecDueEveryDay(int day);

  /// No description provided for @txModalTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get txModalTitle;

  /// No description provided for @txModalSubExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran kas atau mutasi keluar'**
  String get txModalSubExpense;

  /// No description provided for @txModalSubIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan gaji atau dana masuk'**
  String get txModalSubIncome;

  /// No description provided for @txModalSubTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer antar rekening & profil'**
  String get txModalSubTransfer;

  /// No description provided for @txTypeExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get txTypeExpense;

  /// No description provided for @txTypeIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get txTypeIncome;

  /// No description provided for @txTypeTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get txTypeTransfer;

  /// No description provided for @txSelectCategory.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kategori'**
  String get txSelectCategory;

  /// No description provided for @txSelectSourceAccount.
  ///
  /// In id, this message translates to:
  /// **'Pilih Rekening Asal'**
  String get txSelectSourceAccount;

  /// No description provided for @txSelectAccount.
  ///
  /// In id, this message translates to:
  /// **'Pilih Rekening'**
  String get txSelectAccount;

  /// No description provided for @txCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get txCancel;

  /// No description provided for @txSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan Transaksi'**
  String get txSave;

  /// No description provided for @txErrDestEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekening Tujuan Kosong'**
  String get txErrDestEmptyTitle;

  /// No description provided for @txErrDestEmptyMsg.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening tujuan di profil tujuan!'**
  String get txErrDestEmptyMsg;

  /// No description provided for @txErrSameAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekening Sama'**
  String get txErrSameAccountTitle;

  /// No description provided for @txErrSameAccountMsg.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening tujuan yang berbeda dari rekening asal!'**
  String get txErrSameAccountMsg;

  /// No description provided for @addWalletTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Rekening Baru'**
  String get addWalletTitle;

  /// No description provided for @addWalletSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bank, E-Wallet, atau Kas Tunai'**
  String get addWalletSubtitle;

  /// No description provided for @pickAppTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Aplikasi'**
  String get pickAppTitle;

  /// No description provided for @pickAppSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Cari bank atau e-wallet di HP Anda'**
  String get pickAppSubtitle;

  /// No description provided for @addPocketTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Kantong Alokasi Baru'**
  String get addPocketTitle;

  /// No description provided for @addPocketSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pisahkan dana tabungan agar tidak terpakai saat belanja harian.'**
  String get addPocketSubtitle;

  /// No description provided for @addPocketTypeHeader.
  ///
  /// In id, this message translates to:
  /// **'TIPE KANTONG'**
  String get addPocketTypeHeader;

  /// No description provided for @addPocketNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Kantong'**
  String get addPocketNameLabel;

  /// No description provided for @addPocketTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan (Opsional)'**
  String get addPocketTargetLabel;

  /// No description provided for @addPocketInitialLabel.
  ///
  /// In id, this message translates to:
  /// **'Setoran Awal (Opsional)'**
  String get addPocketInitialLabel;

  /// No description provided for @addPocketSourceAccount.
  ///
  /// In id, this message translates to:
  /// **'Ambil Dari Rekening (Jika ada setoran awal)'**
  String get addPocketSourceAccount;

  /// No description provided for @subModalEditInstallment.
  ///
  /// In id, this message translates to:
  /// **'Edit Cicilan'**
  String get subModalEditInstallment;

  /// No description provided for @subModalEditBill.
  ///
  /// In id, this message translates to:
  /// **'Edit Tagihan Rutin'**
  String get subModalEditBill;

  /// No description provided for @subModalAddInstallment.
  ///
  /// In id, this message translates to:
  /// **'Tambah Cicilan Baru'**
  String get subModalAddInstallment;

  /// No description provided for @subModalAddBill.
  ///
  /// In id, this message translates to:
  /// **'Tambah Tagihan Baru'**
  String get subModalAddBill;

  /// No description provided for @subModalSubInstallment.
  ///
  /// In id, this message translates to:
  /// **'Rencana cicilan tenor & jatuh tempo'**
  String get subModalSubInstallment;

  /// No description provided for @subModalSubBill.
  ///
  /// In id, this message translates to:
  /// **'Langganan, tagihan rutin, atau tagihan berkala'**
  String get subModalSubBill;

  /// No description provided for @subModalSaveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get subModalSaveChanges;

  /// No description provided for @subModalSaveBill.
  ///
  /// In id, this message translates to:
  /// **'Simpan Tagihan'**
  String get subModalSaveBill;

  /// No description provided for @onbWelcomeTagline.
  ///
  /// In id, this message translates to:
  /// **'Kelola keuangan pribadi dengan kecerdasan Safe-to-Spend & privasi 100% on-device.'**
  String get onbWelcomeTagline;

  /// No description provided for @onbCreateAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Baru'**
  String get onbCreateAccountTitle;

  /// No description provided for @onbCreateAccountSub.
  ///
  /// In id, this message translates to:
  /// **'Pengguna baru: Mulai dari awal dalam 1 menit'**
  String get onbCreateAccountSub;

  /// No description provided for @onbRestoreTitle.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari Cadangan'**
  String get onbRestoreTitle;

  /// No description provided for @onbRestoreSub.
  ///
  /// In id, this message translates to:
  /// **'Sudah pernah pakai? Pulihkan berkas .json Anda'**
  String get onbRestoreSub;

  /// No description provided for @onbNameQuestion.
  ///
  /// In id, this message translates to:
  /// **'Halo! Siapa namamu?'**
  String get onbNameQuestion;

  /// No description provided for @onbNameHelper.
  ///
  /// In id, this message translates to:
  /// **'Kami pakai untuk menyapamu di beranda aplikasi.'**
  String get onbNameHelper;

  /// No description provided for @onbNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap (contoh: Budi Santoso)'**
  String get onbNameHint;

  /// No description provided for @onbUsernameQuestion.
  ///
  /// In id, this message translates to:
  /// **'Senang kenal, {name}.'**
  String onbUsernameQuestion(String name);

  /// No description provided for @onbUsernameHelper.
  ///
  /// In id, this message translates to:
  /// **'Pilih username untuk profilmu. Pekerjaan boleh dikosongkan.'**
  String get onbUsernameHelper;

  /// No description provided for @onbUsernameHint.
  ///
  /// In id, this message translates to:
  /// **'nama_pengguna'**
  String get onbUsernameHint;

  /// No description provided for @onbUsernameRule.
  ///
  /// In id, this message translates to:
  /// **'Huruf kecil a–z, angka 0–9, dan garis bawah _'**
  String get onbUsernameRule;

  /// No description provided for @onbOccupationHint.
  ///
  /// In id, this message translates to:
  /// **'Pekerjaan (misalnya: Mahasiswa atau Desainer)'**
  String get onbOccupationHint;

  /// No description provided for @onbIncomeQuestion.
  ///
  /// In id, this message translates to:
  /// **'Berapa pemasukanmu per bulan?'**
  String get onbIncomeQuestion;

  /// No description provided for @onbIncomeHelper.
  ///
  /// In id, this message translates to:
  /// **'Gaji, uang saku, atau rata-rata penghasilan. Bisa diubah nanti di pengaturan.'**
  String get onbIncomeHelper;

  /// No description provided for @onbIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan bulanan'**
  String get onbIncomeLabel;

  /// No description provided for @onbCelebrationTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang, {name}!'**
  String onbCelebrationTitle(String name);

  /// No description provided for @onbCelebrationDesc.
  ///
  /// In id, this message translates to:
  /// **'Brankas dan rekening pertamamu sudah aktif.\nSemua siap, ayo mulai atur keuanganmu!'**
  String get onbCelebrationDesc;

  /// No description provided for @onbSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onbSkip;

  /// No description provided for @onbContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onbContinue;

  /// No description provided for @onbStartApp.
  ///
  /// In id, this message translates to:
  /// **'Mulai Aplikasi'**
  String get onbStartApp;

  /// No description provided for @txEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Transaksi'**
  String get txEditTitle;

  /// No description provided for @txEditSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah kategori, rekening, atau nominal'**
  String get txEditSubtitle;

  /// No description provided for @txStorageAccount.
  ///
  /// In id, this message translates to:
  /// **'REKENING PENYIMPANAN'**
  String get txStorageAccount;

  /// No description provided for @txDestAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening Tujuan'**
  String get txDestAccount;

  /// No description provided for @txCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get txCategoryLabel;

  /// No description provided for @txDeleteLabel.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi'**
  String get txDeleteLabel;

  /// No description provided for @txSaveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get txSaveChanges;

  /// No description provided for @txDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi?'**
  String get txDeleteDialogTitle;

  /// No description provided for @txDeleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Transaksi ini akan dihapus permanen dan saldo dompet akan dikembalikan.'**
  String get txDeleteDialogContent;

  /// No description provided for @txDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get txDeleteConfirm;

  /// No description provided for @txDeletedSnackTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Dihapus'**
  String get txDeletedSnackTitle;

  /// No description provided for @txDeletedSnackMsg.
  ///
  /// In id, this message translates to:
  /// **'Transaksi dihapus & saldo dompet dikembalikan semula!'**
  String get txDeletedSnackMsg;

  /// No description provided for @walletEditBalanceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.'**
  String get walletEditBalanceSubtitle;

  /// No description provided for @walletUpdateBalanceBtn.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Saldo'**
  String get walletUpdateBalanceBtn;

  /// No description provided for @walletDeleteAccountBtn.
  ///
  /// In id, this message translates to:
  /// **'Hapus Rekening'**
  String get walletDeleteAccountBtn;

  /// No description provided for @subDetailInstallmentTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Cicilan'**
  String get subDetailInstallmentTitle;

  /// No description provided for @subDetailBillTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Tagihan'**
  String get subDetailBillTitle;

  /// No description provided for @subEditInstallmentBtn.
  ///
  /// In id, this message translates to:
  /// **'Edit Cicilan'**
  String get subEditInstallmentBtn;

  /// No description provided for @subEditBillBtn.
  ///
  /// In id, this message translates to:
  /// **'Edit Tagihan'**
  String get subEditBillBtn;

  /// No description provided for @subDeleteBtn.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get subDeleteBtn;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAll;

  /// No description provided for @filterAllAccounts.
  ///
  /// In id, this message translates to:
  /// **'Semua Rekening'**
  String get filterAllAccounts;

  /// No description provided for @filterApply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan Filter'**
  String get filterApply;

  /// No description provided for @filterAllStatus.
  ///
  /// In id, this message translates to:
  /// **'Semua Status'**
  String get filterAllStatus;

  /// No description provided for @filterUnpaid.
  ///
  /// In id, this message translates to:
  /// **'Belum Bayar'**
  String get filterUnpaid;

  /// No description provided for @filterPaid.
  ///
  /// In id, this message translates to:
  /// **'Sudah Lunas'**
  String get filterPaid;

  /// No description provided for @notifBannerTitle.
  ///
  /// In id, this message translates to:
  /// **'Akses Notifikasi Belum Aktif'**
  String get notifBannerTitle;

  /// No description provided for @notifBannerSub.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk aktifkan pencatatan otomatis bank'**
  String get notifBannerSub;

  /// No description provided for @notifBannerEnable.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan'**
  String get notifBannerEnable;

  /// No description provided for @smartInputSpeakHint.
  ///
  /// In id, this message translates to:
  /// **'Ucapkan transaksi Anda...'**
  String get smartInputSpeakHint;

  /// No description provided for @smartInputTypeHint.
  ///
  /// In id, this message translates to:
  /// **'Ketik kalimat transaksi...'**
  String get smartInputTypeHint;

  /// No description provided for @smartInputContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get smartInputContinue;

  /// No description provided for @pocketHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Mutasi'**
  String get pocketHistoryTitle;

  /// No description provided for @pocketHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat mutasi'**
  String get pocketHistoryEmpty;

  /// No description provided for @pocketDepositTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi Dana ke Kantong'**
  String get pocketDepositTitle;

  /// No description provided for @pocketWithdrawTitle.
  ///
  /// In id, this message translates to:
  /// **'Tarik Dana ke Rekening'**
  String get pocketWithdrawTitle;

  /// No description provided for @pocketDepositSub.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening asal untuk memindahkan dana ke {name}.'**
  String pocketDepositSub(String name);

  /// No description provided for @pocketWithdrawSub.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening tujuan penarikan dari {name}.'**
  String pocketWithdrawSub(String name);

  /// No description provided for @pocketSourceAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening Sumber'**
  String get pocketSourceAccount;

  /// No description provided for @pocketDestAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening Tujuan'**
  String get pocketDestAccount;

  /// No description provided for @pocketNoActiveAccounts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rekening aktif untuk transaksi.'**
  String get pocketNoActiveAccounts;

  /// No description provided for @pocketDepositAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal Setoran'**
  String get pocketDepositAmount;

  /// No description provided for @pocketWithdrawAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal Penarikan'**
  String get pocketWithdrawAmount;

  /// No description provided for @pocketWithdrawAll.
  ///
  /// In id, this message translates to:
  /// **'Tarik Semua ({amount})'**
  String pocketWithdrawAll(String amount);

  /// No description provided for @appPickerSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nama app atau package...'**
  String get appPickerSearchHint;

  /// No description provided for @appPickerNotFound.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi tidak ditemukan'**
  String get appPickerNotFound;

  /// No description provided for @subPayCompletedMsg.
  ///
  /// In id, this message translates to:
  /// **'Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai.'**
  String get subPayCompletedMsg;

  /// No description provided for @subPayPeriodDoneMsg.
  ///
  /// In id, this message translates to:
  /// **'Tagihan periode bulan ini telah lunas tercatat di buku kas.'**
  String get subPayPeriodDoneMsg;

  /// No description provided for @subPayInstallmentBtn.
  ///
  /// In id, this message translates to:
  /// **'Bayar Cicilan Bulan Ini ({next}/{total})'**
  String subPayInstallmentBtn(int next, String total);

  /// No description provided for @subPayMarkPaidBtn.
  ///
  /// In id, this message translates to:
  /// **'Tandai Sudah Lunas Bulan Ini'**
  String get subPayMarkPaidBtn;

  /// No description provided for @subPayCustomBtn.
  ///
  /// In id, this message translates to:
  /// **'Bayar {amount} Bulan Ini'**
  String subPayCustomBtn(String amount);

  /// No description provided for @subPaySuccessBtn.
  ///
  /// In id, this message translates to:
  /// **'Berhasil Dibayar!'**
  String get subPaySuccessBtn;

  /// No description provided for @subPaySnackTitle.
  ///
  /// In id, this message translates to:
  /// **'Tagihan {title} Lunas'**
  String subPaySnackTitle(String title);

  /// No description provided for @subPaySnackMsg.
  ///
  /// In id, this message translates to:
  /// **'Saldo {wallet} terpotong otomatis.'**
  String subPaySnackMsg(String wallet);

  /// No description provided for @subTypeRoutine.
  ///
  /// In id, this message translates to:
  /// **'Langganan Rutin'**
  String get subTypeRoutine;

  /// No description provided for @subTypeInstallment.
  ///
  /// In id, this message translates to:
  /// **'Cicilan / Rencana'**
  String get subTypeInstallment;

  /// No description provided for @inboxTitle.
  ///
  /// In id, this message translates to:
  /// **'Kotak Masuk Notifikasi'**
  String get inboxTitle;

  /// No description provided for @inboxTabTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get inboxTabTransactions;

  /// No description provided for @inboxTabReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get inboxTabReminders;

  /// No description provided for @inboxEmptyDesc.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'**
  String get inboxEmptyDesc;

  /// No description provided for @inboxOpenNotifSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Setelan Akses Notifikasi Android'**
  String get inboxOpenNotifSettings;

  /// No description provided for @editProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get editProfileTitle;

  /// No description provided for @newProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Profil Baru'**
  String get newProfileTitle;

  /// No description provided for @editProfileFullName.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get editProfileFullName;

  /// No description provided for @editProfilePhone.
  ///
  /// In id, this message translates to:
  /// **'No. Handphone / WhatsApp'**
  String get editProfilePhone;

  /// No description provided for @editProfileOccupation.
  ///
  /// In id, this message translates to:
  /// **'Profesi / Pekerjaan'**
  String get editProfileOccupation;

  /// No description provided for @editProfileBio.
  ///
  /// In id, this message translates to:
  /// **'Bio / Catatan Pribadi'**
  String get editProfileBio;

  /// No description provided for @editProfileEmailHint.
  ///
  /// In id, this message translates to:
  /// **'e.g. nama@email.com'**
  String get editProfileEmailHint;

  /// No description provided for @editProfileOccHint.
  ///
  /// In id, this message translates to:
  /// **'e.g. Profesional, Wiraswasta'**
  String get editProfileOccHint;

  /// No description provided for @editProfileBioHint.
  ///
  /// In id, this message translates to:
  /// **'e.g. Membangun kebebasan finansial'**
  String get editProfileBioHint;

  /// No description provided for @dailyPaceTitle.
  ///
  /// In id, this message translates to:
  /// **'Alokasi Harian (Daily Pace)'**
  String get dailyPaceTitle;

  /// No description provided for @dailyPaceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Batas belanja harian & ritme anggaran'**
  String get dailyPaceSubtitle;

  /// No description provided for @promoTitle.
  ///
  /// In id, this message translates to:
  /// **'Diskon & Promo Tagihan'**
  String get promoTitle;

  /// No description provided for @promoSaved.
  ///
  /// In id, this message translates to:
  /// **'Hemat {amount}'**
  String promoSaved(String amount);

  /// No description provided for @promoSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Punya voucher atau diskon bulan ini?'**
  String get promoSubtitle;

  /// No description provided for @promoClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get promoClose;

  /// No description provided for @promoUse.
  ///
  /// In id, this message translates to:
  /// **'Pakai Promo'**
  String get promoUse;

  /// No description provided for @promoNormalPrice.
  ///
  /// In id, this message translates to:
  /// **'Tarif Normal: {amount}'**
  String promoNormalPrice(String amount);

  /// No description provided for @promoPayAmount.
  ///
  /// In id, this message translates to:
  /// **'Bayar: {amount}'**
  String promoPayAmount(String amount);

  /// No description provided for @promoInputLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal Bayar Bulan Ini'**
  String get promoInputLabel;

  /// No description provided for @inboxFilterWarning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get inboxFilterWarning;

  /// No description provided for @inboxFilterSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get inboxFilterSystem;

  /// No description provided for @inboxMarkAllRead.
  ///
  /// In id, this message translates to:
  /// **'Tandai Semua Dibaca'**
  String get inboxMarkAllRead;

  /// No description provided for @walletBindManual.
  ///
  /// In id, this message translates to:
  /// **'Tidak Terhubung (Input Manual)'**
  String get walletBindManual;

  /// No description provided for @walletBindOther.
  ///
  /// In id, this message translates to:
  /// **'Cari / Input Package Lain...'**
  String get walletBindOther;

  /// No description provided for @walletBindConnected.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi transaksi otomatis terhubung ({pkg})'**
  String walletBindConnected(String pkg);

  /// No description provided for @walletBindHint.
  ///
  /// In id, this message translates to:
  /// **'Package Name (contoh: id.krom.bank)'**
  String get walletBindHint;

  /// No description provided for @walletBindTooltip.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari Aplikasi Terpasang'**
  String get walletBindTooltip;

  /// No description provided for @txTransferIn.
  ///
  /// In id, this message translates to:
  /// **'Transfer Masuk'**
  String get txTransferIn;

  /// No description provided for @txTransferOut.
  ///
  /// In id, this message translates to:
  /// **'Transfer Keluar'**
  String get txTransferOut;

  /// No description provided for @exportFormatHeader.
  ///
  /// In id, this message translates to:
  /// **'PILIH FORMAT FILE LAPORAN'**
  String get exportFormatHeader;

  /// No description provided for @exportCsvTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan File CSV (.csv)'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvSub.
  ///
  /// In id, this message translates to:
  /// **'Format koma terpisah (UTF-8 BOM), kompatibel semua spreadsheet'**
  String get exportCsvSub;

  /// No description provided for @exportExcelTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan File Excel (.xls)'**
  String get exportExcelTitle;

  /// No description provided for @exportExcelSub.
  ///
  /// In id, this message translates to:
  /// **'Format tabel buku kerja Microsoft Excel / Google Sheets'**
  String get exportExcelSub;

  /// No description provided for @exportSavedTo.
  ///
  /// In id, this message translates to:
  /// **'Berhasil disimpan ke:\n{path}'**
  String exportSavedTo(String path);

  /// No description provided for @walletBindHeader.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan Notifikasi Aplikasi'**
  String get walletBindHeader;

  /// No description provided for @walletBindSearchApp.
  ///
  /// In id, this message translates to:
  /// **'Cari App'**
  String get walletBindSearchApp;

  /// No description provided for @inboxClearAll.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get inboxClearAll;

  /// No description provided for @inboxClearAllTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua Pengingat?'**
  String get inboxClearAllTitle;

  /// No description provided for @inboxClearAllContent.
  ///
  /// In id, this message translates to:
  /// **'Semua riwayat pengingat akan dihapus secara permanen.'**
  String get inboxClearAllContent;

  /// No description provided for @inboxRemindersEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengingat atau tagihan tercatat.'**
  String get inboxRemindersEmpty;

  /// No description provided for @pocketTypeSavings.
  ///
  /// In id, this message translates to:
  /// **'Simpanan'**
  String get pocketTypeSavings;

  /// No description provided for @pocketTypeRetirement.
  ///
  /// In id, this message translates to:
  /// **'Masa Tua'**
  String get pocketTypeRetirement;

  /// No description provided for @pocketTypeEmergency.
  ///
  /// In id, this message translates to:
  /// **'Dana Darurat'**
  String get pocketTypeEmergency;

  /// No description provided for @pocketTypeGoal.
  ///
  /// In id, this message translates to:
  /// **'Target / Impian'**
  String get pocketTypeGoal;

  /// No description provided for @pocketTotalSaved.
  ///
  /// In id, this message translates to:
  /// **'Total Terkumpul di Kantong'**
  String get pocketTotalSaved;

  /// No description provided for @settingsDeleteProfileMultiDesc.
  ///
  /// In id, this message translates to:
  /// **'Profil @{username} beserta seluruh rekening, transaksi, kantong dana, dan langganannya akan dihapus dari perangkat. Anda akan beralih ke profil lain yang tersimpan.'**
  String settingsDeleteProfileMultiDesc(String username);

  /// No description provided for @settingsDeleteProfileSingleDesc.
  ///
  /// In id, this message translates to:
  /// **'Profil @{username} adalah satu-satunya profil. Menghapus profil ini akan meresetnya kembali ke pengaturan default.'**
  String settingsDeleteProfileSingleDesc(String username);

  /// No description provided for @settingsDeleteProfileConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, Hapus Profil @{username}'**
  String settingsDeleteProfileConfirm(String username);

  /// No description provided for @settingsResetProfileConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, Reset Profil @{username}'**
  String settingsResetProfileConfirm(String username);

  /// No description provided for @settingsClearTxDesc.
  ///
  /// In id, this message translates to:
  /// **'Semua riwayat transaksi pada profil @{username} akan dihapus dan saldo rekening dikembalikan ke 0.'**
  String settingsClearTxDesc(String username);

  /// No description provided for @settingsClearTxConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, Bersihkan Semua Transaksi'**
  String get settingsClearTxConfirm;

  /// No description provided for @calNoSpendDay.
  ///
  /// In id, this message translates to:
  /// **'No-Spend Day'**
  String get calNoSpendDay;

  /// No description provided for @calHematSafe.
  ///
  /// In id, this message translates to:
  /// **'Hemat (Aman)'**
  String get calHematSafe;

  /// No description provided for @calOverPace.
  ///
  /// In id, this message translates to:
  /// **'Melebihi Alokasi'**
  String get calOverPace;

  /// No description provided for @calIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get calIncome;

  /// No description provided for @calExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get calExpense;

  /// No description provided for @calDailyAllocation.
  ///
  /// In id, this message translates to:
  /// **'Alokasi Harian'**
  String get calDailyAllocation;

  /// No description provided for @calTxOnDate.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Tanggal Ini ({count})'**
  String calTxOnDate(int count);

  /// No description provided for @calNoTxRecorded.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada aktivitas transaksi tercatat'**
  String get calNoTxRecorded;

  /// No description provided for @settingsRouteCurrencyTitle.
  ///
  /// In id, this message translates to:
  /// **'Mata Uang Utama'**
  String get settingsRouteCurrencyTitle;

  /// No description provided for @settingsRouteCurrencySub.
  ///
  /// In id, this message translates to:
  /// **'Pilih mata uang tampilan & atur kurs patokan IDR'**
  String get settingsRouteCurrencySub;

  /// No description provided for @settingsRouteIncomeTargetTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Pemasukan Bulanan'**
  String get settingsRouteIncomeTargetTitle;

  /// No description provided for @settingsRouteIncomeTargetSub.
  ///
  /// In id, this message translates to:
  /// **'Patokan rasio tagihan & tabungan di Audit Kesehatan'**
  String get settingsRouteIncomeTargetSub;

  /// No description provided for @settingsRouteCycleDayTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Mulai Siklus'**
  String get settingsRouteCycleDayTitle;

  /// No description provided for @settingsRouteCycleDaySub.
  ///
  /// In id, this message translates to:
  /// **'Tanggal awal perhitungan siklus anggaran bulanan'**
  String get settingsRouteCycleDaySub;

  /// No description provided for @settingsRouteStsWalletsTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekening Safe-to-Spend'**
  String get settingsRouteStsWalletsTitle;

  /// No description provided for @settingsRouteStsWalletsSub.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening yang dihitung dalam dana aman harian'**
  String get settingsRouteStsWalletsSub;

  /// No description provided for @settingsRouteCategoriesTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori Transaksi'**
  String get settingsRouteCategoriesTitle;

  /// No description provided for @settingsRouteCategoriesSub.
  ///
  /// In id, this message translates to:
  /// **'Kelola daftar kategori pengeluaran & pemasukan'**
  String get settingsRouteCategoriesSub;

  /// No description provided for @settingsRouteBankAppsTitle.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi Bank & E-Wallet'**
  String get settingsRouteBankAppsTitle;

  /// No description provided for @settingsRouteBankAppsSub.
  ///
  /// In id, this message translates to:
  /// **'Daftar aplikasi finansial yang didukung parser otomatis'**
  String get settingsRouteBankAppsSub;

  /// No description provided for @settingsRouteExportDataTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Data Transaksi'**
  String get settingsRouteExportDataTitle;

  /// No description provided for @settingsRouteExportDataSub.
  ///
  /// In id, this message translates to:
  /// **'Simpan laporan transaksi ke file CSV atau Excel (.xls)'**
  String get settingsRouteExportDataSub;

  /// No description provided for @settingsRouteClearTxTitle.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan Riwayat Transaksi'**
  String get settingsRouteClearTxTitle;

  /// No description provided for @settingsRouteClearTxSub.
  ///
  /// In id, this message translates to:
  /// **'Hapus seluruh mutasi & reset saldo profil aktif'**
  String get settingsRouteClearTxSub;

  /// No description provided for @settingsRouteDeleteProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Profil'**
  String get settingsRouteDeleteProfileTitle;

  /// No description provided for @settingsRouteDeleteProfileSub.
  ///
  /// In id, this message translates to:
  /// **'Hapus atau reset akun profil aktif dari perangkat'**
  String get settingsRouteDeleteProfileSub;

  /// No description provided for @settingsRouteAboutAppTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get settingsRouteAboutAppTitle;

  /// No description provided for @settingsRouteAboutAppSub.
  ///
  /// In id, this message translates to:
  /// **'Informasi versi, lisensi, & status rilis'**
  String get settingsRouteAboutAppSub;

  /// No description provided for @profileEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get profileEditTitle;

  /// No description provided for @profileEditSub.
  ///
  /// In id, this message translates to:
  /// **'Perbarui informasi dan identitas profil'**
  String get profileEditSub;

  /// No description provided for @profileAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Profil Baru'**
  String get profileAddTitle;

  /// No description provided for @profileAddSub.
  ///
  /// In id, this message translates to:
  /// **'Tambah akun profil baru di perangkat'**
  String get profileAddSub;

  /// No description provided for @healthFourPillars.
  ///
  /// In id, this message translates to:
  /// **'4 Pilar Rasio Keuangan'**
  String get healthFourPillars;

  /// No description provided for @healthIndexPrefix.
  ///
  /// In id, this message translates to:
  /// **'INDEKS'**
  String get healthIndexPrefix;

  /// No description provided for @healthLiquidAssets.
  ///
  /// In id, this message translates to:
  /// **'Likuiditas Rekening'**
  String get healthLiquidAssets;

  /// No description provided for @healthPocketReserves.
  ///
  /// In id, this message translates to:
  /// **'Cadangan Kantong'**
  String get healthPocketReserves;

  /// No description provided for @healthNotesActions.
  ///
  /// In id, this message translates to:
  /// **'CATATAN & TINDAKAN'**
  String get healthNotesActions;

  /// No description provided for @healthTierExcellent.
  ///
  /// In id, this message translates to:
  /// **'Prima'**
  String get healthTierExcellent;

  /// No description provided for @healthTierGood.
  ///
  /// In id, this message translates to:
  /// **'Stabil'**
  String get healthTierGood;

  /// No description provided for @healthTierCaution.
  ///
  /// In id, this message translates to:
  /// **'Waspada'**
  String get healthTierCaution;

  /// No description provided for @healthTierDeficit.
  ///
  /// In id, this message translates to:
  /// **'Kritis'**
  String get healthTierDeficit;

  /// No description provided for @healthHeadlineExcellent.
  ///
  /// In id, this message translates to:
  /// **'Keuanganmu Berada di Kondisi Prima!'**
  String get healthHeadlineExcellent;

  /// No description provided for @healthHeadlineGood.
  ///
  /// In id, this message translates to:
  /// **'Keuangan Stabil, Siap Ditingkatkan.'**
  String get healthHeadlineGood;

  /// No description provided for @healthHeadlineCaution.
  ///
  /// In id, this message translates to:
  /// **'Perlu Penyesuaian Pengeluaran.'**
  String get healthHeadlineCaution;

  /// No description provided for @healthHeadlineDeficit.
  ///
  /// In id, this message translates to:
  /// **'Arus Kas Memerlukan Evaluasi Segera.'**
  String get healthHeadlineDeficit;

  /// No description provided for @healthPillar1Title.
  ///
  /// In id, this message translates to:
  /// **'Dana Darurat (Runway)'**
  String get healthPillar1Title;

  /// No description provided for @healthPillar1DescPocket.
  ///
  /// In id, this message translates to:
  /// **'Cadangan di Kantong Darurat & saldo kas'**
  String get healthPillar1DescPocket;

  /// No description provided for @healthPillar1DescNoPocket.
  ///
  /// In id, this message translates to:
  /// **'Kemampuan bertahan jika tanpa pemasukan'**
  String get healthPillar1DescNoPocket;

  /// No description provided for @healthPillar1Value.
  ///
  /// In id, this message translates to:
  /// **'{months} Bulan'**
  String healthPillar1Value(String months);

  /// No description provided for @healthPillar1Bench.
  ///
  /// In id, this message translates to:
  /// **'Ideal: ≥ 3–6 Bulan'**
  String get healthPillar1Bench;

  /// No description provided for @healthPillar2Title.
  ///
  /// In id, this message translates to:
  /// **'Beban Tagihan Tetap'**
  String get healthPillar2Title;

  /// No description provided for @healthPillar2Desc.
  ///
  /// In id, this message translates to:
  /// **'Porsi langganan & cicilan dari pemasukan'**
  String get healthPillar2Desc;

  /// No description provided for @healthPillar2Bench.
  ///
  /// In id, this message translates to:
  /// **'Ideal: ≤ 30%'**
  String get healthPillar2Bench;

  /// No description provided for @healthPillar3Title.
  ///
  /// In id, this message translates to:
  /// **'Margin Tabungan Bersih'**
  String get healthPillar3Title;

  /// No description provided for @healthPillar3Desc.
  ///
  /// In id, this message translates to:
  /// **'Sisa arus kas yang berhasil disimpan'**
  String get healthPillar3Desc;

  /// No description provided for @healthPillar3Bench.
  ///
  /// In id, this message translates to:
  /// **'Ideal: ≥ 15–20%'**
  String get healthPillar3Bench;

  /// No description provided for @healthPillar4Title.
  ///
  /// In id, this message translates to:
  /// **'Disiplin Belanja Harian'**
  String get healthPillar4Title;

  /// No description provided for @healthPillar4Desc.
  ///
  /// In id, this message translates to:
  /// **'Kepatuhan pengeluaran terhadap batas aman'**
  String get healthPillar4Desc;

  /// No description provided for @healthPillar4Bench.
  ///
  /// In id, this message translates to:
  /// **'Target: Sangat Aman'**
  String get healthPillar4Bench;

  /// No description provided for @healthRecPillar1PocketLow.
  ///
  /// In id, this message translates to:
  /// **'Di Kantong: {current} • Rekomendasi isi {gap} menuju 3 bln ({target})'**
  String healthRecPillar1PocketLow(String current, String gap, String target);

  /// No description provided for @healthRecPillar1PocketMid.
  ///
  /// In id, this message translates to:
  /// **'Kantong Darurat ({current}) aman 3 bln! • Tambah {gap} menuju 6 bln ({target})'**
  String healthRecPillar1PocketMid(String current, String gap, String target);

  /// No description provided for @healthRecPillar1PocketFull.
  ///
  /// In id, this message translates to:
  /// **'Kantong Darurat prima ({current})! • Target 6 bln ({target}) terpenuhi penuh'**
  String healthRecPillar1PocketFull(String current, String target);

  /// No description provided for @healthRecPillar1NoPocketLow.
  ///
  /// In id, this message translates to:
  /// **'Target 3 bln: {target} • Rekomendasi buat Kantong Darurat & isi {gap}'**
  String healthRecPillar1NoPocketLow(String target, String gap);

  /// No description provided for @healthRecPillar1NoPocketOk.
  ///
  /// In id, this message translates to:
  /// **'Saldo rekening {liquid} cukup 3 bln ({target}) • Rekomendasi kunci ke Kantong Darurat agar aman'**
  String healthRecPillar1NoPocketOk(String liquid, String target);

  /// No description provided for @healthRecPillar2Ok.
  ///
  /// In id, this message translates to:
  /// **'Tagihan {bills}/bln • Batas ideal 30%: Maks {maxBills}/bln (Sangat Aman)'**
  String healthRecPillar2Ok(String bills, String maxBills);

  /// No description provided for @healthRecPillar2High.
  ///
  /// In id, this message translates to:
  /// **'Tagihan {bills}/bln lewat 30% ({maxBills}/bln) • Pangkas {excess}'**
  String healthRecPillar2High(String bills, String maxBills, String excess);

  /// No description provided for @healthRecPillar3Ok.
  ///
  /// In id, this message translates to:
  /// **'Tabungan {saved}/bln • Target 20% ({target}/bln) tercapai prima!'**
  String healthRecPillar3Ok(String saved, String target);

  /// No description provided for @healthRecPillar3Mid.
  ///
  /// In id, this message translates to:
  /// **'Tabungan {saved}/bln • Rekomendasi tambah {gap}/bln menuju 20%'**
  String healthRecPillar3Mid(String saved, String gap);

  /// No description provided for @healthRecPillar3Deficit.
  ///
  /// In id, this message translates to:
  /// **'Arus kas defisit • Rem belanja agar bisa menabung target 20% ({target}/bln)'**
  String healthRecPillar3Deficit(String target);

  /// No description provided for @healthRecPillar4Ok.
  ///
  /// In id, this message translates to:
  /// **'Batas belanja aman {daily}/hari • Sisa Safe-to-Spend: {monthly}'**
  String healthRecPillar4Ok(String daily, String monthly);

  /// No description provided for @healthRecPillar4Caution.
  ///
  /// In id, this message translates to:
  /// **'Pacing waspada • Jaga belanja maksimal {daily}/hari agar saldo tidak tergerus'**
  String healthRecPillar4Caution(String daily);

  /// No description provided for @healthRecPillar4Deficit.
  ///
  /// In id, this message translates to:
  /// **'Anggaran defisit • Tunda pengeluaran variabel dan dahulukan kebutuhan esensial'**
  String get healthRecPillar4Deficit;

  /// No description provided for @healthRecEmergency.
  ///
  /// In id, this message translates to:
  /// **'Target dana darurat 3 bulanmu {target}. Prioritaskan transfer berkala ke Kantong Darurat.'**
  String healthRecEmergency(String target);

  /// No description provided for @healthRecBills.
  ///
  /// In id, this message translates to:
  /// **'Beban tagihan rutin mencapai {bills}/bln (batas aman {maxBills}/bln). Evaluasi tagihan yang kurang bernilai guna.'**
  String healthRecBills(String bills, String maxBills);

  /// No description provided for @healthRecSavings.
  ///
  /// In id, this message translates to:
  /// **'Margin tabungan bulan ini baru {saved}. Targetkan simpanan minimal {target} (20%) di awal gajian.'**
  String healthRecSavings(String saved, String target);

  /// No description provided for @healthRecPacing.
  ///
  /// In id, this message translates to:
  /// **'Pacing belanja harian mendekati batas aman ({daily}/hari). Rem pengeluaran variabel agar alokasi tetap terjaga.'**
  String healthRecPacing(String daily);

  /// No description provided for @healthRecNoPockets.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum memiliki Kantong Tabungan. Buat kantong alokasi untuk memisahkan dana jajan dari simpanan.'**
  String get healthRecNoPockets;

  /// No description provided for @healthRecAllGood.
  ///
  /// In id, this message translates to:
  /// **'Kondisi keuanganmu luar biasa prima! Cadangan darurat dan rasio simpanan aman, lanjutkan alokasi jangka panjang.'**
  String get healthRecAllGood;

  /// No description provided for @inboxJustNow.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get inboxJustNow;

  /// No description provided for @inboxMinutesAgo.
  ///
  /// In id, this message translates to:
  /// **'{minutes} mnt lalu'**
  String inboxMinutesAgo(int minutes);

  /// No description provided for @inboxPickWallet.
  ///
  /// In id, this message translates to:
  /// **'Pilih Dompet'**
  String get inboxPickWallet;

  /// No description provided for @inboxSwipeHint.
  ///
  /// In id, this message translates to:
  /// **'Geser kanan untuk terima, kiri untuk tolak'**
  String get inboxSwipeHint;

  /// No description provided for @inboxEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Sesuaikan Transaksi'**
  String get inboxEditTitle;

  /// No description provided for @inboxEditSubWallet.
  ///
  /// In id, this message translates to:
  /// **'Rekening: {walletName}'**
  String inboxEditSubWallet(String walletName);

  /// No description provided for @inboxEditSubDefault.
  ///
  /// In id, this message translates to:
  /// **'Ubah nominal & tipe transaksi'**
  String get inboxEditSubDefault;

  /// No description provided for @inboxEditAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'NOMINAL TRANSAKSI'**
  String get inboxEditAmountLabel;

  /// No description provided for @inboxEditMerchantLabel.
  ///
  /// In id, this message translates to:
  /// **'MERCHANT / PENERIMA / CATATAN'**
  String get inboxEditMerchantLabel;

  /// No description provided for @inboxEditMerchantHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Kopi Kenangan, Transfer Budi'**
  String get inboxEditMerchantHint;

  /// No description provided for @inboxEditSaveBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get inboxEditSaveBtn;

  /// No description provided for @inboxReassignTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Dompet / Workspace'**
  String get inboxReassignTitle;

  /// No description provided for @inboxReassignSub.
  ///
  /// In id, this message translates to:
  /// **'Alihkan transaksi auto-log ini ke rekening atau akun yang benar.'**
  String get inboxReassignSub;

  /// No description provided for @inboxReassignMainAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun Utama'**
  String get inboxReassignMainAccount;

  /// No description provided for @inboxReassignSuccess.
  ///
  /// In id, this message translates to:
  /// **'Dialihkan ke {profileName} • {walletName}'**
  String inboxReassignSuccess(String profileName, String walletName);

  /// No description provided for @inboxSnackConfirmed.
  ///
  /// In id, this message translates to:
  /// **'Transaksi terkonfirmasi benar'**
  String get inboxSnackConfirmed;

  /// No description provided for @inboxSnackRejected.
  ///
  /// In id, this message translates to:
  /// **'Transaksi dibatalkan & saldo dipulihkan'**
  String get inboxSnackRejected;

  /// No description provided for @inboxSnackEdited.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil disesuaikan'**
  String get inboxSnackEdited;

  /// No description provided for @catAddBtn.
  ///
  /// In id, this message translates to:
  /// **'+ Tambah'**
  String get catAddBtn;

  /// No description provided for @catCancelBtn.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get catCancelBtn;

  /// No description provided for @catSaveBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get catSaveBtn;

  /// No description provided for @catDefaultFood.
  ///
  /// In id, this message translates to:
  /// **'Makanan & Minuman'**
  String get catDefaultFood;

  /// No description provided for @catDefaultTransport.
  ///
  /// In id, this message translates to:
  /// **'Transportasi'**
  String get catDefaultTransport;

  /// No description provided for @catDefaultShopping.
  ///
  /// In id, this message translates to:
  /// **'Belanja & Kebutuhan'**
  String get catDefaultShopping;

  /// No description provided for @catDefaultBills.
  ///
  /// In id, this message translates to:
  /// **'Tagihan & Utilitas'**
  String get catDefaultBills;

  /// No description provided for @catDefaultEntertainment.
  ///
  /// In id, this message translates to:
  /// **'Hiburan & Langganan'**
  String get catDefaultEntertainment;

  /// No description provided for @catDefaultHealth.
  ///
  /// In id, this message translates to:
  /// **'Kesehatan'**
  String get catDefaultHealth;

  /// No description provided for @catDefaultEducation.
  ///
  /// In id, this message translates to:
  /// **'Pendidikan & Kursus'**
  String get catDefaultEducation;

  /// No description provided for @healthStatusComfortable.
  ///
  /// In id, this message translates to:
  /// **'Sangat Aman'**
  String get healthStatusComfortable;

  /// No description provided for @healthStatusCaution.
  ///
  /// In id, this message translates to:
  /// **'Perlu Hati-Hati'**
  String get healthStatusCaution;

  /// No description provided for @healthStatusDeficit.
  ///
  /// In id, this message translates to:
  /// **'Defisit Tagihan'**
  String get healthStatusDeficit;

  /// No description provided for @swipeConfirmCorrect.
  ///
  /// In id, this message translates to:
  /// **'Benar'**
  String get swipeConfirmCorrect;

  /// No description provided for @swipeRejectWrong.
  ///
  /// In id, this message translates to:
  /// **'Salah'**
  String get swipeRejectWrong;

  /// No description provided for @notifStreakExceededTitle.
  ///
  /// In id, this message translates to:
  /// **'Batas Belanja Harian Terlampaui'**
  String get notifStreakExceededTitle;

  /// No description provided for @notifStreakExceededWithStreak.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran hari ini telah melampaui kuota harian. Pertahankan kendali agar streak hemat {streak} hari tidak terhenti.'**
  String notifStreakExceededWithStreak(int streak);

  /// No description provided for @notifStreakExceededBody.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran hari ini telah melampaui kuota harian Safe-to-Spend. Tahan pengeluaran sebelum siklus berganti.'**
  String get notifStreakExceededBody;

  /// No description provided for @notifStreakNearTitle.
  ///
  /// In id, this message translates to:
  /// **'Mendekati Batas Belanja Harian'**
  String get notifStreakNearTitle;

  /// No description provided for @notifStreakNearWithStreak.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran hari ini mencapai {percent}% dari kuota. Batasi belanja agar streak hemat {streak} hari tetap terjaga.'**
  String notifStreakNearWithStreak(int percent, int streak);

  /// No description provided for @notifStreakNearBody.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran hari ini telah mencapai {percent}% dari alokasi harian Safe-to-Spend.'**
  String notifStreakNearBody(int percent);

  /// No description provided for @notifBillH3Title.
  ///
  /// In id, this message translates to:
  /// **'Tagihan {title} (H-3)'**
  String notifBillH3Title(String title);

  /// No description provided for @notifBillH3Body.
  ///
  /// In id, this message translates to:
  /// **'{amount} jatuh tempo 3 hari lagi (Tgl {day}).'**
  String notifBillH3Body(String amount, int day);

  /// No description provided for @notifBillH1Title.
  ///
  /// In id, this message translates to:
  /// **'Tagihan {title} Besok'**
  String notifBillH1Title(String title);

  /// No description provided for @notifBillH1Body.
  ///
  /// In id, this message translates to:
  /// **'{amount} jatuh tempo besok. Pastikan saldo cukup.'**
  String notifBillH1Body(String amount);

  /// No description provided for @notifBillH0Title.
  ///
  /// In id, this message translates to:
  /// **'Tagihan {title} Hari Ini'**
  String notifBillH0Title(String title);

  /// No description provided for @notifBillH0Body.
  ///
  /// In id, this message translates to:
  /// **'{amount} jatuh tempo hari ini. Buka untuk tandai lunas.'**
  String notifBillH0Body(String amount);

  /// No description provided for @notifAutoDeductTitle.
  ///
  /// In id, this message translates to:
  /// **'Tagihan Berhasil Didebet: {title}'**
  String notifAutoDeductTitle(String title);

  /// No description provided for @notifAutoDeductBody.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran {amount} telah otomatis dipotong dari dompet.'**
  String notifAutoDeductBody(String amount);

  /// No description provided for @dailyPaceRemainingDays.
  ///
  /// In id, this message translates to:
  /// **'Sisa Hari Bulan Ini'**
  String get dailyPaceRemainingDays;

  /// No description provided for @dailyPaceDaysCount.
  ///
  /// In id, this message translates to:
  /// **'{days} Hari'**
  String dailyPaceDaysCount(int days);

  /// No description provided for @dailyPaceSafeLimit.
  ///
  /// In id, this message translates to:
  /// **'Batas Aman Belanja / Hari'**
  String get dailyPaceSafeLimit;

  /// No description provided for @dailyPaceTodayExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Hari Ini'**
  String get dailyPaceTodayExpense;

  /// No description provided for @dailyPaceRemainingQuota.
  ///
  /// In id, this message translates to:
  /// **'Sisa Kuota Hari Ini'**
  String get dailyPaceRemainingQuota;

  /// No description provided for @dailyPaceOverQuota.
  ///
  /// In id, this message translates to:
  /// **'Melebihi Kuota'**
  String get dailyPaceOverQuota;

  /// No description provided for @dailyPaceFooter.
  ///
  /// In id, this message translates to:
  /// **'Menjaga belanja rata-rata harian Anda di bawah angka ini akan menjamin keuangan tetap surplus hingga akhir bulan.'**
  String get dailyPaceFooter;

  /// No description provided for @stsStatusPrefix.
  ///
  /// In id, this message translates to:
  /// **'Status: {status}'**
  String stsStatusPrefix(String status);

  /// No description provided for @stsTotalAssetsCount.
  ///
  /// In id, this message translates to:
  /// **'Total Aset ({count} Akun)'**
  String stsTotalAssetsCount(int count);

  /// No description provided for @stsPerDaySuffix.
  ///
  /// In id, this message translates to:
  /// **'/ hr'**
  String get stsPerDaySuffix;

  /// No description provided for @stsAllWalletsDesc.
  ///
  /// In id, this message translates to:
  /// **'Dihitung dari seluruh rekening Anda. Uang ini aman dibelanjakan tanpa khawatir tagihan bulanan gagal bayar.'**
  String get stsAllWalletsDesc;

  /// No description provided for @stsSelectedWalletsDesc.
  ///
  /// In id, this message translates to:
  /// **'Dihitung hanya dari rekening operasional ({count} rekening). Tagihan dan saldo rekening tabungan lain tidak dicampur.'**
  String stsSelectedWalletsDesc(int count);

  /// No description provided for @stsSettingsHint.
  ///
  /// In id, this message translates to:
  /// **'Pilihan rekening operasional dapat diatur di Pengaturan > Siklus Anggaran & Safe-to-Spend.'**
  String get stsSettingsHint;

  /// No description provided for @chartLegendIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get chartLegendIn;

  /// No description provided for @chartLegendOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get chartLegendOut;

  /// No description provided for @walletDeckEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Rekening'**
  String get walletDeckEmptyTitle;

  /// No description provided for @walletDeckEmptyDesc.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rekening atau dompet digital yang terhubung.'**
  String get walletDeckEmptyDesc;

  /// No description provided for @walletDeckEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk tombol + di bawah untuk menambahkan'**
  String get walletDeckEmptyHint;

  /// No description provided for @manageLabel.
  ///
  /// In id, this message translates to:
  /// **'Kelola'**
  String get manageLabel;

  /// No description provided for @searchTxHint.
  ///
  /// In id, this message translates to:
  /// **'Cari transaksi, rekening, merchant...'**
  String get searchTxHint;

  /// No description provided for @filterTxTitle.
  ///
  /// In id, this message translates to:
  /// **'Filter Transaksi'**
  String get filterTxTitle;

  /// No description provided for @filterTxTypeHeader.
  ///
  /// In id, this message translates to:
  /// **'TIPE TRANSAKSI'**
  String get filterTxTypeHeader;

  /// No description provided for @filterChipTypePrefix.
  ///
  /// In id, this message translates to:
  /// **'Tipe: {label}'**
  String filterChipTypePrefix(String label);

  /// No description provided for @filterChipStatusPrefix.
  ///
  /// In id, this message translates to:
  /// **'Status: {label}'**
  String filterChipStatusPrefix(String label);

  /// No description provided for @walletAvailableBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Tersedia'**
  String get walletAvailableBalance;

  /// No description provided for @pocketTxFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari {wallet} • {date}'**
  String pocketTxFrom(String wallet, String date);

  /// No description provided for @pocketTxTo.
  ///
  /// In id, this message translates to:
  /// **'Ke {wallet} • {date}'**
  String pocketTxTo(String wallet, String date);

  /// No description provided for @pocketTxDepositDefault.
  ///
  /// In id, this message translates to:
  /// **'Setoran Kantong'**
  String get pocketTxDepositDefault;

  /// No description provided for @pocketTxWithdrawDefault.
  ///
  /// In id, this message translates to:
  /// **'Penarikan Kantong'**
  String get pocketTxWithdrawDefault;

  /// No description provided for @walletDetailSearchResults.
  ///
  /// In id, this message translates to:
  /// **'Hasil Pencarian ({count})'**
  String walletDetailSearchResults(int count);

  /// No description provided for @walletDetailHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get walletDetailHistoryTitle;

  /// No description provided for @walletDetailTxCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String walletDetailTxCount(int count);

  /// No description provided for @walletDetailNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi yang cocok'**
  String get walletDetailNoMatch;

  /// No description provided for @walletDetailNoMutations.
  ///
  /// In id, this message translates to:
  /// **'Belum ada mutasi transaksi'**
  String get walletDetailNoMutations;

  /// No description provided for @walletDetailOfflineBadge.
  ///
  /// In id, this message translates to:
  /// **'Offline & Terenkripsi'**
  String get walletDetailOfflineBadge;

  /// No description provided for @walletDetailPickAppTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Aplikasi'**
  String get walletDetailPickAppTitle;

  /// No description provided for @walletDetailPickAppSub.
  ///
  /// In id, this message translates to:
  /// **'Cari bank atau e-wallet di HP Anda'**
  String get walletDetailPickAppSub;

  /// No description provided for @walletDetailAdjustTitle.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian Saldo: {name}'**
  String walletDetailAdjustTitle(String name);

  /// No description provided for @walletDetailAdjustSub.
  ///
  /// In id, this message translates to:
  /// **'Ubah saldo awal & preferensi rekening'**
  String get walletDetailAdjustSub;

  /// No description provided for @walletDetailTxTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get walletDetailTxTitle;

  /// No description provided for @walletDetailTxSub.
  ///
  /// In id, this message translates to:
  /// **'Rekening: {name}'**
  String walletDetailTxSub(String name);

  /// No description provided for @historySearchCount.
  ///
  /// In id, this message translates to:
  /// **'Hasil Pencarian: {count} Transaksi'**
  String historySearchCount(int count);

  /// No description provided for @historyFilterCount.
  ///
  /// In id, this message translates to:
  /// **'Hasil Filter: {count} Transaksi'**
  String historyFilterCount(int count);

  /// No description provided for @historyDayTxCount.
  ///
  /// In id, this message translates to:
  /// **'//  {count} TRANSAKSI'**
  String historyDayTxCount(int count);

  /// No description provided for @historyEmptyDate.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Transaksi di Tanggal Ini'**
  String get historyEmptyDate;

  /// No description provided for @historyTitleCalendar.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas\nKeuangan'**
  String get historyTitleCalendar;

  /// No description provided for @historyTitleDefault.
  ///
  /// In id, this message translates to:
  /// **'Riwayat\nTransaksi'**
  String get historyTitleDefault;

  /// No description provided for @historySubCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender Aktivitas & Arus Kas'**
  String get historySubCalendar;

  /// No description provided for @historySubFiltered.
  ///
  /// In id, this message translates to:
  /// **'Total Terfilter: {amount}'**
  String historySubFiltered(String amount);

  /// No description provided for @historyTooltipCard.
  ///
  /// In id, this message translates to:
  /// **'Tampilan Kartu'**
  String get historyTooltipCard;

  /// No description provided for @historyTooltipCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender Aktivitas'**
  String get historyTooltipCalendar;

  /// No description provided for @txEditSubDefault.
  ///
  /// In id, this message translates to:
  /// **'Ubah rincian mutasi transaksi'**
  String get txEditSubDefault;

  /// No description provided for @txWalletDefault.
  ///
  /// In id, this message translates to:
  /// **'Rekening'**
  String get txWalletDefault;

  /// No description provided for @pocketMutationsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} mutasi'**
  String pocketMutationsCount(int count);

  /// No description provided for @pocketDeleteLabel.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kantong'**
  String get pocketDeleteLabel;

  /// No description provided for @pocketDepositBtn.
  ///
  /// In id, this message translates to:
  /// **'Isi Dana'**
  String get pocketDepositBtn;

  /// No description provided for @pocketWithdrawBtn.
  ///
  /// In id, this message translates to:
  /// **'Tarik Dana'**
  String get pocketWithdrawBtn;

  /// No description provided for @pocketDepositSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi Dana ke Kantong'**
  String get pocketDepositSheetTitle;

  /// No description provided for @pocketWithdrawSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Tarik Dana ke Rekening'**
  String get pocketWithdrawSheetTitle;

  /// No description provided for @pocketDepositSheetSub.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening asal untuk memindahkan dana ke {name}.'**
  String pocketDepositSheetSub(String name);

  /// No description provided for @pocketWithdrawSheetSub.
  ///
  /// In id, this message translates to:
  /// **'Pilih rekening tujuan penarikan dari {name}.'**
  String pocketWithdrawSheetSub(String name);

  /// No description provided for @pocketNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama kantong wajib diisi'**
  String get pocketNameRequired;

  /// No description provided for @pocketInsufficientBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo tidak cukup (Maks {max})'**
  String pocketInsufficientBalance(String max);

  /// No description provided for @pocketCreateNow.
  ///
  /// In id, this message translates to:
  /// **'Buat Kantong Sekarang'**
  String get pocketCreateNow;

  /// No description provided for @subsNotFoundTitle.
  ///
  /// In id, this message translates to:
  /// **'Tagihan Tidak Ditemukan'**
  String get subsNotFoundTitle;

  /// No description provided for @subsNotFoundQuery.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tagihan yang cocok dengan \"{query}\".'**
  String subsNotFoundQuery(String query);

  /// No description provided for @subsNotFoundFilter.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tagihan dalam filter ini.'**
  String get subsNotFoundFilter;

  /// No description provided for @subsHintExample.
  ///
  /// In id, this message translates to:
  /// **'cth: Netflix, Spotify, Listrik PLN, Kosan'**
  String get subsHintExample;

  /// No description provided for @subsDeleteInstallment.
  ///
  /// In id, this message translates to:
  /// **'Hapus Cicilan Ini'**
  String get subsDeleteInstallment;

  /// No description provided for @subsDeleteSub.
  ///
  /// In id, this message translates to:
  /// **'Hapus Langganan Ini'**
  String get subsDeleteSub;

  /// No description provided for @walletDeletedTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekening Dihapus'**
  String get walletDeletedTitle;

  /// No description provided for @walletSaveBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan Rekening'**
  String get walletSaveBtn;

  /// No description provided for @pocketDeletedTitle.
  ///
  /// In id, this message translates to:
  /// **'Kantong Dihapus'**
  String get pocketDeletedTitle;

  /// No description provided for @profileMenuNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Baru'**
  String get profileMenuNewTitle;

  /// No description provided for @profileMenuHealthTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Kesehatan Keuangan'**
  String get profileMenuHealthTitle;

  /// No description provided for @profileMenuHealthSub.
  ///
  /// In id, this message translates to:
  /// **'Audit komprehensif 4 pilar kesehatan keuangan'**
  String get profileMenuHealthSub;

  /// No description provided for @profileMenuShareTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Profil'**
  String get profileMenuShareTitle;

  /// No description provided for @profileMenuShareSub.
  ///
  /// In id, this message translates to:
  /// **'Bagikan kartu profil finansial'**
  String get profileMenuShareSub;

  /// No description provided for @profileCopiedTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Disalin'**
  String get profileCopiedTitle;

  /// No description provided for @profileCopiedMsg.
  ///
  /// In id, this message translates to:
  /// **'Kartu profil berhasil disalin ke clipboard!'**
  String get profileCopiedMsg;

  /// No description provided for @profileUpdatedTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Diperbarui'**
  String get profileUpdatedTitle;

  /// No description provided for @profileUpdatedMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil \"{username}\" berhasil diperbarui!'**
  String profileUpdatedMsg(String username);

  /// No description provided for @profileCreatedTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Dibuat'**
  String get profileCreatedTitle;

  /// No description provided for @profileCreatedMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil \"{username}\" berhasil dibuat!'**
  String profileCreatedMsg(String username);

  /// No description provided for @profileCreateBtn.
  ///
  /// In id, this message translates to:
  /// **'Buat Profil Baru'**
  String get profileCreateBtn;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Profil?'**
  String get profileDeleteTitle;

  /// No description provided for @profileResetTitle.
  ///
  /// In id, this message translates to:
  /// **'Reset Profil?'**
  String get profileResetTitle;

  /// No description provided for @profileDeleteMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil \"{username}\" akan dihapus. Anda dapat beralih ke profil lain yang masih tersimpan.'**
  String profileDeleteMsg(String username);

  /// No description provided for @profileResetMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil \"{username}\" adalah satu-satunya profil. Profil akan direset ke pengaturan default.'**
  String profileResetMsg(String username);

  /// No description provided for @profileDeletedTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Dihapus'**
  String get profileDeletedTitle;

  /// No description provided for @profileResetDoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Direset'**
  String get profileResetDoneTitle;

  /// No description provided for @profileDeletedMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil \"{username}\" berhasil dihapus.'**
  String profileDeletedMsg(String username);

  /// No description provided for @profileResetDoneMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil direset.'**
  String get profileResetDoneMsg;

  /// No description provided for @profileCardRealBalance.
  ///
  /// In id, this message translates to:
  /// **'SALDO RIIL'**
  String get profileCardRealBalance;

  /// No description provided for @profileCardBills.
  ///
  /// In id, this message translates to:
  /// **'TAGIHAN'**
  String get profileCardBills;

  /// No description provided for @profileCardSafe.
  ///
  /// In id, this message translates to:
  /// **'SISA AMAN'**
  String get profileCardSafe;

  /// No description provided for @avatarTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto Profil'**
  String get avatarTitle;

  /// No description provided for @avatarActiveSub.
  ///
  /// In id, this message translates to:
  /// **'Foto kustom aktif • Ketuk untuk ganti'**
  String get avatarActiveSub;

  /// No description provided for @avatarEmptySub.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk pilih dari galeri atau kamera'**
  String get avatarEmptySub;

  /// No description provided for @avatarErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal Mengambil Foto'**
  String get avatarErrorTitle;

  /// No description provided for @avatarPickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Sumber Foto'**
  String get avatarPickerTitle;

  /// No description provided for @avatarPickerSub.
  ///
  /// In id, this message translates to:
  /// **'Galeri perangkat atau kamera'**
  String get avatarPickerSub;

  /// No description provided for @avatarGalleryTitle.
  ///
  /// In id, this message translates to:
  /// **'Galeri Foto'**
  String get avatarGalleryTitle;

  /// No description provided for @avatarGallerySub.
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar dari galeri perangkat'**
  String get avatarGallerySub;

  /// No description provided for @avatarCameraTitle.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get avatarCameraTitle;

  /// No description provided for @avatarCameraSub.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto baru langsung dari kamera'**
  String get avatarCameraSub;

  /// No description provided for @avatarRemoveTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Foto Profil'**
  String get avatarRemoveTitle;

  /// No description provided for @avatarRemoveSub.
  ///
  /// In id, this message translates to:
  /// **'Gunakan inisial nama sebagai avatar'**
  String get avatarRemoveSub;

  /// No description provided for @settingsMonthlyTargetHeader.
  ///
  /// In id, this message translates to:
  /// **'NOMINAL TARGET BULANAN ({currency})'**
  String settingsMonthlyTargetHeader(String currency);

  /// No description provided for @settingsCyclePresetHeader.
  ///
  /// In id, this message translates to:
  /// **'PRESET TANGGAL SIKLUS'**
  String get settingsCyclePresetHeader;

  /// No description provided for @settingsCycleDayEveryMonth.
  ///
  /// In id, this message translates to:
  /// **'Tanggal {day} setiap bulan'**
  String settingsCycleDayEveryMonth(int day);

  /// No description provided for @settingsCycleCustomHeader.
  ///
  /// In id, this message translates to:
  /// **'TANGGAL KUSTOM (1–31)'**
  String get settingsCycleCustomHeader;

  /// No description provided for @settingsCycleDatePrefix.
  ///
  /// In id, this message translates to:
  /// **'Tanggal '**
  String get settingsCycleDatePrefix;

  /// No description provided for @settingsCycleApplyBtn.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get settingsCycleApplyBtn;

  /// No description provided for @settingsCycleDaysRemaining.
  ///
  /// In id, this message translates to:
  /// **'{days} hari tersisa pada siklus berjalan saat ini.'**
  String settingsCycleDaysRemaining(int days);

  /// No description provided for @settingsStsOperationalHeader.
  ///
  /// In id, this message translates to:
  /// **'REKENING DANA OPERASIONAL'**
  String get settingsStsOperationalHeader;

  /// No description provided for @settingsStsAllWallets.
  ///
  /// In id, this message translates to:
  /// **'Semua Rekening ({count})'**
  String settingsStsAllWallets(int count);

  /// No description provided for @onboardingWalletQuestion.
  ///
  /// In id, this message translates to:
  /// **'Di mana uangmu sekarang?'**
  String get onboardingWalletQuestion;

  /// No description provided for @onboardingWalletHelper.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan rekening pertamamu. Rekening lainnya bisa ditambahkan nanti.'**
  String get onboardingWalletHelper;

  /// No description provided for @onboardingWalletHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: BCA, Jago, atau Kas Dompet'**
  String get onboardingWalletHint;

  /// No description provided for @onboardingWalletTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis rekening'**
  String get onboardingWalletTypeLabel;

  /// No description provided for @onboardingWalletTypeCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get onboardingWalletTypeCash;

  /// No description provided for @onboardingWalletBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo saat ini'**
  String get onboardingWalletBalanceLabel;

  /// No description provided for @walletDeletedMsg.
  ///
  /// In id, this message translates to:
  /// **'Rekening \"{name}\" berhasil dihapus.'**
  String walletDeletedMsg(String name);

  /// No description provided for @catTimelineTapHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk kapsul untuk detail'**
  String get catTimelineTapHint;

  /// No description provided for @catTimelineTxCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String catTimelineTxCount(int count);

  /// No description provided for @catTimelineDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori'**
  String get catTimelineDelete;

  /// No description provided for @catEditAction.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get catEditAction;

  /// No description provided for @catDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori?'**
  String get catDeleteConfirmTitle;

  /// No description provided for @catDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Kategori \"{name}\" akan dihapus dari daftar pilihan.'**
  String catDeleteConfirmBody(String name);

  /// No description provided for @onboardingWalletBalanceHelper.
  ///
  /// In id, this message translates to:
  /// **'Opsional. Biarkan 0 jika ingin mulai dari nol.'**
  String get onboardingWalletBalanceHelper;

  /// No description provided for @onbTopBarReady.
  ///
  /// In id, this message translates to:
  /// **'Siap!'**
  String get onbTopBarReady;

  /// No description provided for @onbTopBarStep.
  ///
  /// In id, this message translates to:
  /// **'Langkah {step} dari {total}'**
  String onbTopBarStep(int step, int total);

  /// No description provided for @onbUsernameTakenTitle.
  ///
  /// In id, this message translates to:
  /// **'Username sudah dipakai'**
  String get onbUsernameTakenTitle;

  /// No description provided for @onbUsernameTakenMsg.
  ///
  /// In id, this message translates to:
  /// **'Pilih username lain untuk profil baru ini.'**
  String get onbUsernameTakenMsg;

  /// No description provided for @onbIncomePerDay.
  ///
  /// In id, this message translates to:
  /// **'≈ {amount} per hari'**
  String onbIncomePerDay(String amount);

  /// No description provided for @kofiPromptTitle.
  ///
  /// In id, this message translates to:
  /// **'Suka pakai fiBOnanci?'**
  String get kofiPromptTitle;

  /// No description provided for @kofiPromptBody.
  ///
  /// In id, this message translates to:
  /// **'fiBOnanci 100% gratis, offline, dan tanpa iklan. Kalau aplikasi ini membantu mengatur keuanganmu, traktir kopi untuk developer di Ko-fi yuk.'**
  String get kofiPromptBody;

  /// No description provided for @kofiPromptSupportBtn.
  ///
  /// In id, this message translates to:
  /// **'Dukung di Ko-fi'**
  String get kofiPromptSupportBtn;

  /// No description provided for @kofiPromptLaterBtn.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get kofiPromptLaterBtn;

  /// No description provided for @kofiPromptNeverBtn.
  ///
  /// In id, this message translates to:
  /// **'Jangan tampilkan lagi'**
  String get kofiPromptNeverBtn;

  /// No description provided for @kofiAboutRowTitle.
  ///
  /// In id, this message translates to:
  /// **'Dukung Developer (Ko-fi)'**
  String get kofiAboutRowTitle;

  /// No description provided for @aboutSectionUpdates.
  ///
  /// In id, this message translates to:
  /// **'STATUS & PEMBARUAN APLIKASI'**
  String get aboutSectionUpdates;

  /// No description provided for @aboutSectionSpecs.
  ///
  /// In id, this message translates to:
  /// **'TENTANG & ARSITEKTUR APLIKASI'**
  String get aboutSectionSpecs;

  /// No description provided for @aboutAutoUpdate.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan Otomatis'**
  String get aboutAutoUpdate;

  /// No description provided for @aboutConnectingGithub.
  ///
  /// In id, this message translates to:
  /// **'Menghubungkan ke GitHub Releases...'**
  String get aboutConnectingGithub;

  /// No description provided for @aboutVersionReady.
  ///
  /// In id, this message translates to:
  /// **'Versi v{version} Siap Diunduh!'**
  String aboutVersionReady(String version);

  /// No description provided for @aboutDownloadInstallBtn.
  ///
  /// In id, this message translates to:
  /// **'Unduh & Pasang Pembaruan'**
  String get aboutDownloadInstallBtn;

  /// No description provided for @aboutReleaseNotesTitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan Rilis:'**
  String get aboutReleaseNotesTitle;

  /// No description provided for @aboutUpToDate.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi Sudah Versi Terbaru (v{version})'**
  String aboutUpToDate(String version);

  /// No description provided for @aboutNotChecked.
  ///
  /// In id, this message translates to:
  /// **'Belum diperiksa ke repositori rilis'**
  String get aboutNotChecked;

  /// No description provided for @aboutCheckNowBtn.
  ///
  /// In id, this message translates to:
  /// **'Periksa Pembaruan Sekarang'**
  String get aboutCheckNowBtn;

  /// No description provided for @aboutPrivacyDesc.
  ///
  /// In id, this message translates to:
  /// **'Data keuangan Anda disimpan 100% offline di perangkat tanpa cloud atau tracking. Koneksi internet hanya digunakan secara opsional saat memeriksa pembaruan atau membuka halaman dukungan Ko-fi.'**
  String get aboutPrivacyDesc;

  /// No description provided for @aboutLicenseTitle.
  ///
  /// In id, this message translates to:
  /// **'Lisensi Perangkat Lunak'**
  String get aboutLicenseTitle;

  /// No description provided for @aboutStorageTitle.
  ///
  /// In id, this message translates to:
  /// **'Penyimpanan Database'**
  String get aboutStorageTitle;

  /// No description provided for @aboutParserTitle.
  ///
  /// In id, this message translates to:
  /// **'Parser Notifikasi Bank'**
  String get aboutParserTitle;

  /// No description provided for @aboutGithubTitle.
  ///
  /// In id, this message translates to:
  /// **'Repositori GitHub'**
  String get aboutGithubTitle;

  /// No description provided for @aboutReleasesTitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan Rilis Lengkap'**
  String get aboutReleasesTitle;

  /// No description provided for @aboutOpenBrowser.
  ///
  /// In id, this message translates to:
  /// **'Buka di Aplikasi'**
  String get aboutOpenBrowser;

  /// No description provided for @webViewErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak dapat dimuat'**
  String get webViewErrorTitle;

  /// No description provided for @webViewErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Pastikan perangkat terhubung ke internet lalu coba lagi.'**
  String get webViewErrorBody;

  /// No description provided for @webViewRetryBtn.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get webViewRetryBtn;

  /// No description provided for @onbLangTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get onbLangTitle;

  /// No description provided for @onbLangSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa yang ingin digunakan. Kamu bisa mengubahnya kapan saja di Pengaturan.'**
  String get onbLangSubtitle;

  /// No description provided for @onbLangIdTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get onbLangIdTitle;

  /// No description provided for @onbLangIdSub.
  ///
  /// In id, this message translates to:
  /// **'Antarmuka bahasa Indonesia'**
  String get onbLangIdSub;

  /// No description provided for @onbLangEnTitle.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get onbLangEnTitle;

  /// No description provided for @onbLangEnSub.
  ///
  /// In id, this message translates to:
  /// **'Antarmuka bahasa Inggris'**
  String get onbLangEnSub;

  /// No description provided for @onlineRequiredBadge.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa rilis terbaru via GitHub saat dibuka'**
  String get onlineRequiredBadge;

  /// No description provided for @aboutCheckOfflineError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memeriksa pembaruan. Coba lagi nanti.'**
  String get aboutCheckOfflineError;

  /// No description provided for @kofiRequiresInternetHint.
  ///
  /// In id, this message translates to:
  /// **'Membuka halaman Ko-fi membutuhkan koneksi internet'**
  String get kofiRequiresInternetHint;

  /// No description provided for @subModalPaymentSource.
  ///
  /// In id, this message translates to:
  /// **'SUMBER DANA PEMBAYARAN'**
  String get subModalPaymentSource;

  /// No description provided for @subModalAutoDeductTitle.
  ///
  /// In id, this message translates to:
  /// **'Auto-Deduct Saldo'**
  String get subModalAutoDeductTitle;

  /// No description provided for @subModalAutoDeductSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Potong saldo otomatis saat tgl jatuh tempo'**
  String get subModalAutoDeductSubtitle;

  /// No description provided for @subDeletedSnackTitle.
  ///
  /// In id, this message translates to:
  /// **'Tagihan Dihapus'**
  String get subDeletedSnackTitle;

  /// No description provided for @subDeletedSnackMsg.
  ///
  /// In id, this message translates to:
  /// **'Tagihan berhasil dihapus & saldo rekening dikembalikan.'**
  String get subDeletedSnackMsg;

  /// No description provided for @subDeletedSnackTag.
  ///
  /// In id, this message translates to:
  /// **'HAPUS'**
  String get subDeletedSnackTag;

  /// No description provided for @subDeleteThisBtn.
  ///
  /// In id, this message translates to:
  /// **'Hapus Langganan Ini'**
  String get subDeleteThisBtn;

  /// No description provided for @subDueDateHeader.
  ///
  /// In id, this message translates to:
  /// **'TANGGAL JATUH TEMPO'**
  String get subDueDateHeader;

  /// No description provided for @subDueDayEveryMonth.
  ///
  /// In id, this message translates to:
  /// **'Tgl {day} setiap bulan'**
  String subDueDayEveryMonth(int day);

  /// No description provided for @subInstallmentDeadlineHeader.
  ///
  /// In id, this message translates to:
  /// **'TENGGAT WAKTU CICILAN (WAJIB)'**
  String get subInstallmentDeadlineHeader;

  /// No description provided for @subInstallmentFinishDate.
  ///
  /// In id, this message translates to:
  /// **'Selesai {date}'**
  String subInstallmentFinishDate(String date);

  /// No description provided for @subInstallmentCustomBtn.
  ///
  /// In id, this message translates to:
  /// **'Custom'**
  String get subInstallmentCustomBtn;

  /// No description provided for @subTenorDurationLabel.
  ///
  /// In id, this message translates to:
  /// **'Durasi Tenor'**
  String get subTenorDurationLabel;

  /// No description provided for @subTenorMonthsShort.
  ///
  /// In id, this message translates to:
  /// **'Bln'**
  String get subTenorMonthsShort;

  /// No description provided for @subInstallmentCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'cicilan /bulan (tenor {cycles} bln)'**
  String subInstallmentCardSubtitle(int cycles);

  /// No description provided for @subSpecPaymentProgress.
  ///
  /// In id, this message translates to:
  /// **'Progress Pembayaran'**
  String get subSpecPaymentProgress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
