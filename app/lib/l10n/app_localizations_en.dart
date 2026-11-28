// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDashboard => 'Home';

  @override
  String get navWallets => 'Wallets';

  @override
  String get navSubscriptions => 'Bills';

  @override
  String get navHistory => 'History';

  @override
  String get historyButton => 'History';

  @override
  String get profileTitle => 'User Profile';

  @override
  String get profileSubtitle => 'Identity summary & financial performance';

  @override
  String get financialReportTitle => 'Financial Report';

  @override
  String get financialReportSubtitle =>
      'Cashflow, category, & account distribution analysis';

  @override
  String get financialHealthTitle => 'Financial Health Audit';

  @override
  String get financialHealthSubtitle =>
      'Based on cashflow ratio, assets, & real bills';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Financial preferences, categories, automation, & local data';

  @override
  String get settingsGlobalHeader => 'GLOBAL SETTINGS • ALL PROFILES';

  @override
  String get settingsHideBalance => 'Mask Balance Amounts';

  @override
  String get settingsHighRefreshRate => '120Hz Display Mode (High FPS)';

  @override
  String get settingsBiometricLock => 'Biometric / App PIN Lock';

  @override
  String get settingsPrivacyScreen => 'Privacy Screen Guard (Recent Apps)';

  @override
  String get settingsThemeLabel => 'Appearance Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageLabel => 'App Language';

  @override
  String get settingsLanguageName => 'English';

  @override
  String get settingsEncryptionLabel => 'Database Encryption (SQLCipher)';

  @override
  String get settingsEncryptionActive => 'AES-256 Active';

  @override
  String get settingsCategoriesLabel => 'Transaction Categories';

  @override
  String get settingsNotifListenerLabel => 'Bank Notification Listener';

  @override
  String get settingsBankAppsLabel => 'Bank & E-Wallet Apps';

  @override
  String get settingsAboutAppLabel => 'About App & Updates';

  @override
  String settingsDataBackupHeader(String username) {
    return 'DATA & BACKUP • @$username';
  }

  @override
  String settingsDangerZoneHeader(String username) {
    return 'DANGER ZONE • @$username';
  }

  @override
  String get settingsExportCsv => 'Export Transactions (CSV / Excel)';

  @override
  String get settingsExportJson => 'Save Backup (JSON)';

  @override
  String get settingsImportJson => 'Restore Backup (Import JSON)';

  @override
  String get settingsClearTx => 'Clear Transaction History';

  @override
  String get settingsDeleteProfile => 'Delete / Reset Active Profile';

  @override
  String get reportExpenses => 'Expenses';

  @override
  String get reportIncome => 'Income';

  @override
  String get reportAllFlow => 'All Cashflow';

  @override
  String get reportWeek => 'Week';

  @override
  String get reportMonth => 'Month';

  @override
  String get reportQuarter => 'Quarter';

  @override
  String reportTransactionsCount(int count) {
    return '$count Transactions';
  }

  @override
  String get reportAssetsTitle => 'ASSETS & LIABILITIES';

  @override
  String get reportTotalNetWorth => 'Total Net Worth';

  @override
  String get reportActiveWalletBalance => 'Active Accounts Balance';

  @override
  String get reportPocketBalance => 'Savings Pockets Balance';

  @override
  String get reportCommittedBills => 'Monthly Committed Bills';

  @override
  String get reportWalletActivityTitle => 'ACTIVITY BY ACCOUNT';

  @override
  String get reportEmptyWallets => 'No active accounts yet';

  @override
  String get reportEmptyTitle => 'No transactions yet';

  @override
  String get reportEmptyDesc =>
      'Record transactions in this period to view category breakdown.';

  @override
  String dashboardSafeToSpendFiltered(int count) {
    return 'Safe to Spend ($count Accounts)';
  }

  @override
  String dashboardRealAccounts(int count) {
    return '$count Real Accounts';
  }

  @override
  String dashboardBillsThisMonth(int count) {
    return '$count Bills This Month';
  }

  @override
  String get dashboardHistoryTitle => 'Transaction History';

  @override
  String dashboardSearchResults(int count) {
    return 'Search Results ($count)';
  }

  @override
  String get dashboardViewAll => 'View All';

  @override
  String walletsMainAccounts(int count) {
    return 'Accounts ($count)';
  }

  @override
  String walletsSavingsPockets(int count) {
    return 'Savings Pockets ($count)';
  }

  @override
  String get walletsTotalRealBalance => 'TOTAL REAL BALANCE';

  @override
  String get walletsFlowIn => 'In';

  @override
  String get walletsFlowOut => 'Out';

  @override
  String get subsTitle => 'Bills & Subscriptions';

  @override
  String subsRegisteredCount(int count) {
    return '$count Registered • Sorted by due date';
  }

  @override
  String get subsEmptyTitle => 'No Recurring Bills Yet';

  @override
  String get subsEmptyDesc =>
      'Add Netflix, Spotify, or installments to track due dates cleanly.';

  @override
  String get subsEmptyHint => 'Tap + below to add';

  @override
  String get subsSearchHint => 'Search bills, subscriptions, accounts...';

  @override
  String get subsFilterTitle => 'Filter Bills';

  @override
  String get subsFilterStatusHeader => 'PAYMENT STATUS';

  @override
  String get profileMenuTitle => 'Profile Menu';

  @override
  String get profileMenuNew => 'Add new profile account';

  @override
  String get profileMenuHealth => 'Comprehensive financial audit';

  @override
  String get profileMenuReport => 'Cashflow & category summary';

  @override
  String get profileMenuSettings => 'Currency, categories, & local data';

  @override
  String get profileMenuShare => 'Share financial profile card';

  @override
  String get profileDataHeader => 'GENERAL DATA & ACCOUNT DETAILS';

  @override
  String get profileOccupation => 'Occupation';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profileBio => 'Bio / Notes';

  @override
  String get profilePrimaryCurrency => 'Primary Currency';

  @override
  String get profileIncomeTarget => 'Income Target';

  @override
  String get profileConnectedWallets => 'Connected Accounts';

  @override
  String profileConnectedWalletsVal(int count) {
    return '$count Accounts';
  }

  @override
  String get profileTotalTx => 'Total Transactions';

  @override
  String profileTotalTxVal(int count) {
    return '$count Recorded';
  }

  @override
  String get settingsAndroidOnly => 'Android Only';

  @override
  String get settingsActive => 'Active';

  @override
  String get settingsOff => 'Off';

  @override
  String settingsCategoriesCount(int count) {
    return '$count Categories';
  }

  @override
  String settingsSupportedCount(int count) {
    return '$count Supported';
  }

  @override
  String settingsProfileHeader(String username) {
    return 'PROFILE SETTINGS • @$username';
  }

  @override
  String get settingsIncomeTargetTitle => 'Monthly Income Target';

  @override
  String get settingsSetAction => 'Set';

  @override
  String get settingsCycleDayTitle => 'Budget Cycle Start Day';

  @override
  String settingsCycleDayValue(int day, int rem) {
    return 'Day $day ($rem d)';
  }

  @override
  String get settingsStsWalletsTitle => 'Safe-to-Spend Accounts';

  @override
  String settingsAllCount(int count) {
    return 'All ($count)';
  }

  @override
  String settingsActiveCount(int count) {
    return '$count Active';
  }

  @override
  String get profileSafe => 'Safe';

  @override
  String get profileDaily => 'Daily';

  @override
  String get profileScore => 'SCORE';

  @override
  String get profileAccounts => 'Accounts';

  @override
  String get profileTransactions => 'Transactions';

  @override
  String get profileRecurringBills => 'Recurring Bills';

  @override
  String get pocketsEmptyTitle => 'No Savings Pockets Yet';

  @override
  String get pocketsEmptyDesc =>
      'Separate funds for Savings, Emergency, or Goals to keep them safe from daily spending.';

  @override
  String get pocketsEmptyHint => 'Tap + below to create one';

  @override
  String get walletTrendHeadline => 'Cashflow Trend (All Accounts)';

  @override
  String get walletTrendSubtitle => '30 Days';

  @override
  String get stsTotalRealBalance => 'Total Real Balance';

  @override
  String get stsSelectedBalance => 'Selected Accounts Balance';

  @override
  String get stsPendingBills => 'Remaining Monthly Bills';

  @override
  String get stsSelectedBills => 'Selected Accounts Bills';

  @override
  String get stsMonthlySafe => 'Monthly Safe-to-Spend';

  @override
  String stsDailyAllowance(int days) {
    return 'Daily Allowance ($days d)';
  }

  @override
  String get walletScreenTitle => 'Accounts & Wallets';

  @override
  String walletConnectedSubtitle(int count) {
    return '$count connected accounts';
  }

  @override
  String get searchTransactionsHint =>
      'Search transactions, accounts, merchants...';

  @override
  String get searchFilterTitle => 'Filter Transactions';

  @override
  String get searchFilterTypeHeader => 'TRANSACTION TYPE';

  @override
  String get dashboardEmptyWalletTitle => 'No Connected Accounts Yet';

  @override
  String get dashboardEmptyWalletDesc =>
      'Add a bank account or e-wallet to start tracking cashflow and safe-to-spend allowance.';

  @override
  String get dashboardEmptyWalletHint => 'Tap + below to add one';

  @override
  String get dashboardNoMatchingTx => 'No matching transactions';

  @override
  String get dashboardNoTxToday => 'No transactions today';

  @override
  String get walletCardAvailableBalance => 'AVAILABLE BALANCE';

  @override
  String dashboardWelcome(String username) {
    return 'Hello $username, welcome back!';
  }

  @override
  String get hintCategoryName => 'New category name...';

  @override
  String get hintPocketName => 'Pocket Name (e.g. Retirement, Vacation)';

  @override
  String get hintWalletName => 'Account Name (e.g. Chase, Cash, Wise)';

  @override
  String hintInitialBalance(String symbol) {
    return 'Initial Balance ($symbol)';
  }

  @override
  String get hintAccountNumber => 'Account Number (Optional, e.g. 5410982341)';

  @override
  String get hintNotesOptional => 'Notes (Optional)';

  @override
  String get hintSubscriptionTitle => 'e.g. Netflix, Spotify, Rent, Utilities';

  @override
  String get walletDetailTitle => 'Account Details';

  @override
  String get walletDetailSubtitle => 'Info & Transactions';

  @override
  String walletBalanceAdjustTitle(String name) {
    return 'Balance Adjustment: $name';
  }

  @override
  String get walletBalanceAdjustSubtitle =>
      'Edit initial balance & preferences';

  @override
  String get walletActionEditBalance => 'Edit Balance';

  @override
  String get walletActionLogTx => 'Log Transaction';

  @override
  String cardCategoryTrend(String category) {
    return '$category trend (Mon–Sun)';
  }

  @override
  String get subRecurringMonthly => 'recurring bill /month';

  @override
  String get subRecurringYearly => 'recurring bill /year';

  @override
  String get subBadgeCycleMonthly => 'MONTHLY';

  @override
  String get subBadgeCycleYearly => 'YEARLY';

  @override
  String get subBadgePaid => 'PAID';

  @override
  String subBadgeMonthsLeft(int count) {
    return '$count mo left';
  }

  @override
  String subBadgeInstallmentCompleted(int paid, int total) {
    return 'INSTALLMENT PAID ($paid/$total)';
  }

  @override
  String subBadgeInstallmentPaid(int paid, String total) {
    return 'INSTALLMENT $paid/$total • PAID';
  }

  @override
  String get subBadgePaidThisMonth => 'PAID THIS MONTH';

  @override
  String subBadgeInstallmentPrefix(int step, String total) {
    return 'INSTALLMENT $step/$total • ';
  }

  @override
  String get subBadgeDuePrefix => 'DUE ';

  @override
  String get subBadgeToday => 'TODAY';

  @override
  String subBadgeInDays(int days) {
    return 'IN ${days}D';
  }

  @override
  String subBadgeOnDay(int day) {
    return 'DAY $day';
  }

  @override
  String get subSpecPaymentAccount => 'Payment Account';

  @override
  String get subSpecCurrentBalance => 'Current Account Balance';

  @override
  String get subSpecPaymentMethod => 'Payment Method';

  @override
  String get subSpecAutoDeduct => 'Auto-Deduct Active';

  @override
  String get subSpecPeriodStatus => 'Current Period Status';

  @override
  String get subSpecInstallmentDone => 'Installment Completed';

  @override
  String get subSpecStatusPaid => 'Paid';

  @override
  String get subSpecStatusUnpaid => 'Unpaid';

  @override
  String get subSpecInstallmentPlan => 'Installment Plan';

  @override
  String subSpecInstallmentProgress(int paid, int total) {
    return '$paid of $total months paid';
  }

  @override
  String get subSpecRemainingPrincipal => 'Remaining Principal';

  @override
  String get subSpecCompletionDate => 'Completion Date';

  @override
  String get subSpecBillingCycle => 'Billing Cycle';

  @override
  String get subSpecCycleMonthly => 'Monthly';

  @override
  String get subSpecCycleYearly => 'Yearly';

  @override
  String get subSpecDueDate => 'Due Date';

  @override
  String subSpecDueEveryDay(int day) {
    return 'Every day $day';
  }

  @override
  String get txModalTitle => 'Log Transaction';

  @override
  String get txModalSubExpense => 'Cash expense or outgoing mutation';

  @override
  String get txModalSubIncome => 'Salary income or incoming funds';

  @override
  String get txModalSubTransfer => 'Transfer across accounts & profiles';

  @override
  String get txTypeExpense => 'Expense';

  @override
  String get txTypeIncome => 'Income';

  @override
  String get txTypeTransfer => 'Transfer';

  @override
  String get txSelectCategory => 'Select Category';

  @override
  String get txSelectSourceAccount => 'Select Source Account';

  @override
  String get txSelectAccount => 'Select Account';

  @override
  String get txCancel => 'Cancel';

  @override
  String get txSave => 'Save Transaction';

  @override
  String get txErrDestEmptyTitle => 'Destination Account Empty';

  @override
  String get txErrDestEmptyMsg =>
      'Select a destination account in the target profile!';

  @override
  String get txErrSameAccountTitle => 'Same Account';

  @override
  String get txErrSameAccountMsg =>
      'Select a destination account different from the source!';

  @override
  String get addWalletTitle => 'Add New Account';

  @override
  String get addWalletSubtitle => 'Bank, E-Wallet, or Cash';

  @override
  String get pickAppTitle => 'Select App';

  @override
  String get pickAppSubtitle => 'Search bank or e-wallet on your phone';

  @override
  String get addPocketTitle => 'Create New Pocket';

  @override
  String get addPocketSubtitle =>
      'Separate savings so they are not spent on daily expenses.';

  @override
  String get addPocketTypeHeader => 'POCKET TYPE';

  @override
  String get addPocketNameLabel => 'Pocket Name';

  @override
  String get addPocketTargetLabel => 'Savings Target (Optional)';

  @override
  String get addPocketInitialLabel => 'Initial Deposit (Optional)';

  @override
  String get addPocketSourceAccount =>
      'Deduct From Account (If initial deposit set)';

  @override
  String get subModalEditInstallment => 'Edit Installment';

  @override
  String get subModalEditBill => 'Edit Recurring Bill';

  @override
  String get subModalAddInstallment => 'Add New Installment';

  @override
  String get subModalAddBill => 'Add New Bill';

  @override
  String get subModalSubInstallment => 'Installment tenor & due date plan';

  @override
  String get subModalSubBill =>
      'Subscriptions, recurring bills, or periodic bills';

  @override
  String get subModalSaveChanges => 'Save Changes';

  @override
  String get subModalSaveBill => 'Save Bill';

  @override
  String get onbWelcomeTagline =>
      'Manage personal finance with Safe-to-Spend intelligence & 100% on-device privacy.';

  @override
  String get onbCreateAccountTitle => 'Create New Account';

  @override
  String get onbCreateAccountSub => 'New user: Start fresh in 1 minute';

  @override
  String get onbRestoreTitle => 'Restore from Backup';

  @override
  String get onbRestoreSub => 'Returning user? Restore your .json backup file';

  @override
  String get onbNameQuestion => 'Hello! What is your name?';

  @override
  String get onbNameHelper => 'We use this to greet you on the home screen.';

  @override
  String get onbNameHint => 'Full name (e.g. Alex Johnson)';

  @override
  String onbUsernameQuestion(String name) {
    return 'Nice to meet you, $name.';
  }

  @override
  String get onbUsernameHelper =>
      'Choose a username for your profile. Occupation is optional.';

  @override
  String get onbUsernameHint => 'username';

  @override
  String get onbUsernameRule => 'Lowercase a–z, digits 0–9, and underscore _';

  @override
  String get onbOccupationHint => 'Occupation (e.g. Student or Designer)';

  @override
  String get onbIncomeQuestion => 'What is your monthly income?';

  @override
  String get onbIncomeHelper =>
      'Salary, allowance, or average earnings. You can change this later.';

  @override
  String get onbIncomeLabel => 'Monthly income';

  @override
  String onbCelebrationTitle(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get onbCelebrationDesc =>
      'Your vault and first account are now active.\nEverything is ready, let\'s manage your finances!';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbStartApp => 'Start App';

  @override
  String get txEditTitle => 'Edit Transaction';

  @override
  String get txEditSubtitle => 'Change category, account, or amount';

  @override
  String get txStorageAccount => 'SOURCE ACCOUNT';

  @override
  String get txDestAccount => 'Destination Account';

  @override
  String get txCategoryLabel => 'Category';

  @override
  String get txDeleteLabel => 'Delete Transaction';

  @override
  String get txSaveChanges => 'Save Changes';

  @override
  String get txDeleteDialogTitle => 'Delete Transaction?';

  @override
  String get txDeleteDialogContent =>
      'This transaction will be permanently deleted and your wallet balance will be restored.';

  @override
  String get txDeleteConfirm => 'Delete';

  @override
  String get txDeletedSnackTitle => 'Transaction Deleted';

  @override
  String get txDeletedSnackMsg =>
      'Transaction deleted & wallet balance restored!';

  @override
  String get walletEditBalanceSubtitle =>
      'Update balance to match your current real mobile banking balance.';

  @override
  String get walletUpdateBalanceBtn => 'Update Balance';

  @override
  String get walletDeleteAccountBtn => 'Delete Account';

  @override
  String get subDetailInstallmentTitle => 'Installment Details';

  @override
  String get subDetailBillTitle => 'Bill Details';

  @override
  String get subEditInstallmentBtn => 'Edit Installment';

  @override
  String get subEditBillBtn => 'Edit Bill';

  @override
  String get subDeleteBtn => 'Delete';

  @override
  String get filterAll => 'All';

  @override
  String get filterAllAccounts => 'All Accounts';

  @override
  String get filterApply => 'Apply Filter';

  @override
  String get filterAllStatus => 'All Status';

  @override
  String get filterUnpaid => 'Unpaid';

  @override
  String get filterPaid => 'Paid';

  @override
  String get notifBannerTitle => 'Notification Access Inactive';

  @override
  String get notifBannerSub => 'Tap to enable automatic bank logging';

  @override
  String get notifBannerEnable => 'Enable';

  @override
  String get smartInputSpeakHint => 'Speak your transaction...';

  @override
  String get smartInputTypeHint => 'Type transaction sentence...';

  @override
  String get smartInputContinue => 'Continue';

  @override
  String get pocketHistoryTitle => 'Mutation History';

  @override
  String get pocketHistoryEmpty => 'No mutation history yet';

  @override
  String get pocketDepositTitle => 'Deposit to Pocket';

  @override
  String get pocketWithdrawTitle => 'Withdraw to Account';

  @override
  String pocketDepositSub(String name) {
    return 'Select source account to transfer funds to $name.';
  }

  @override
  String pocketWithdrawSub(String name) {
    return 'Select destination account for withdrawal from $name.';
  }

  @override
  String get pocketSourceAccount => 'Source Account';

  @override
  String get pocketDestAccount => 'Destination Account';

  @override
  String get pocketNoActiveAccounts =>
      'No active accounts available for transaction.';

  @override
  String get pocketDepositAmount => 'Deposit Amount';

  @override
  String get pocketWithdrawAmount => 'Withdrawal Amount';

  @override
  String pocketWithdrawAll(String amount) {
    return 'Withdraw All ($amount)';
  }

  @override
  String get appPickerSearchHint => 'Search app name or package...';

  @override
  String get appPickerNotFound => 'No apps found';

  @override
  String get subPayCompletedMsg =>
      'All installments paid! This financing plan is completed.';

  @override
  String get subPayPeriodDoneMsg =>
      'This month\'s bill is paid and recorded in your ledger.';

  @override
  String subPayInstallmentBtn(int next, String total) {
    return 'Pay This Month\'s Installment ($next/$total)';
  }

  @override
  String get subPayMarkPaidBtn => 'Mark Paid This Month';

  @override
  String subPayCustomBtn(String amount) {
    return 'Pay $amount This Month';
  }

  @override
  String get subPaySuccessBtn => 'Paid Successfully!';

  @override
  String subPaySnackTitle(String title) {
    return '$title Bill Paid';
  }

  @override
  String subPaySnackMsg(String wallet) {
    return '$wallet balance deducted automatically.';
  }

  @override
  String get subTypeRoutine => 'Recurring Bill';

  @override
  String get subTypeInstallment => 'Installment / Plan';

  @override
  String get inboxTitle => 'Notification Inbox';

  @override
  String get inboxTabTransactions => 'Transactions';

  @override
  String get inboxTabReminders => 'Reminders';

  @override
  String get inboxEmptyDesc =>
      'No pending notification queue.\nAll your bank transactions are cleanly recorded!';

  @override
  String get inboxOpenNotifSettings =>
      'Open Android Notification Access Settings';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get newProfileTitle => 'Add New Profile';

  @override
  String get editProfileFullName => 'Full Name';

  @override
  String get editProfilePhone => 'Phone / WhatsApp';

  @override
  String get editProfileOccupation => 'Occupation';

  @override
  String get editProfileBio => 'Bio / Personal Notes';

  @override
  String get editProfileEmailHint => 'e.g. name@email.com';

  @override
  String get editProfileOccHint => 'e.g. Professional, Entrepreneur';

  @override
  String get editProfileBioHint => 'e.g. Building financial freedom';

  @override
  String get dailyPaceTitle => 'Daily Allowance (Daily Pace)';

  @override
  String get dailyPaceSubtitle => 'Daily spending limit & budget rhythm';

  @override
  String get promoTitle => 'Bill Discounts & Promos';

  @override
  String promoSaved(String amount) {
    return 'Saved $amount';
  }

  @override
  String get promoSubtitle => 'Have a voucher or discount this month?';

  @override
  String get promoClose => 'Close';

  @override
  String get promoUse => 'Use Promo';

  @override
  String promoNormalPrice(String amount) {
    return 'Normal Price: $amount';
  }

  @override
  String promoPayAmount(String amount) {
    return 'Pay: $amount';
  }

  @override
  String get promoInputLabel => 'Amount to Pay This Month';

  @override
  String get inboxFilterWarning => 'Alerts';

  @override
  String get inboxFilterSystem => 'System';

  @override
  String get inboxMarkAllRead => 'Mark All Read';

  @override
  String get walletBindManual => 'Not Linked (Manual Input)';

  @override
  String get walletBindOther => 'Search / Enter Custom Package...';

  @override
  String walletBindConnected(String pkg) {
    return 'Auto transaction notifications linked ($pkg)';
  }

  @override
  String get walletBindHint => 'Package Name (e.g. id.krom.bank)';

  @override
  String get walletBindTooltip => 'Choose from Installed Apps';

  @override
  String get txTransferIn => 'Incoming Transfer';

  @override
  String get txTransferOut => 'Outgoing Transfer';

  @override
  String get exportFormatHeader => 'SELECT REPORT FILE FORMAT';

  @override
  String get exportCsvTitle => 'Save CSV File (.csv)';

  @override
  String get exportCsvSub =>
      'Comma-separated format (UTF-8 BOM), compatible with all spreadsheets';

  @override
  String get exportExcelTitle => 'Save Excel File (.xls)';

  @override
  String get exportExcelSub =>
      'Microsoft Excel / Google Sheets workbook format';

  @override
  String exportSavedTo(String path) {
    return 'Successfully saved to:\n$path';
  }

  @override
  String get walletBindHeader => 'Connect App Notifications';

  @override
  String get walletBindSearchApp => 'Find App';

  @override
  String get inboxClearAll => 'Clear All';

  @override
  String get inboxClearAllTitle => 'Clear All Reminders?';

  @override
  String get inboxClearAllContent =>
      'All reminder history will be permanently deleted.';

  @override
  String get inboxRemindersEmpty => 'No reminders or bills recorded yet.';

  @override
  String get pocketTypeSavings => 'Savings';

  @override
  String get pocketTypeRetirement => 'Retirement';

  @override
  String get pocketTypeEmergency => 'Emergency Fund';

  @override
  String get pocketTypeGoal => 'Target / Goal';

  @override
  String get pocketTotalSaved => 'Total Saved in Pocket';

  @override
  String settingsDeleteProfileMultiDesc(String username) {
    return 'Profile @$username along with all its wallets, transactions, pockets, and subscriptions will be deleted from this device. You will switch to another saved profile.';
  }

  @override
  String settingsDeleteProfileSingleDesc(String username) {
    return 'Profile @$username is the only profile. Deleting this profile will reset it back to default settings.';
  }

  @override
  String settingsDeleteProfileConfirm(String username) {
    return 'Yes, Delete Profile @$username';
  }

  @override
  String settingsResetProfileConfirm(String username) {
    return 'Yes, Reset Profile @$username';
  }

  @override
  String settingsClearTxDesc(String username) {
    return 'All transaction history on profile @$username will be deleted and wallet balances reset to 0.';
  }

  @override
  String get settingsClearTxConfirm => 'Yes, Clear All Transactions';

  @override
  String get calNoSpendDay => 'No-Spend Day';

  @override
  String get calHematSafe => 'Frugal (Safe)';

  @override
  String get calOverPace => 'Over Allocation';

  @override
  String get calIncome => 'Income';

  @override
  String get calExpense => 'Expense';

  @override
  String get calDailyAllocation => 'Daily Allocation';

  @override
  String calTxOnDate(int count) {
    return 'Transactions on This Date ($count)';
  }

  @override
  String get calNoTxRecorded => 'No transaction activity recorded';

  @override
  String get settingsRouteCurrencyTitle => 'Primary Currency';

  @override
  String get settingsRouteCurrencySub =>
      'Select display currency & set IDR reference rate';

  @override
  String get settingsRouteIncomeTargetTitle => 'Monthly Income Target';

  @override
  String get settingsRouteIncomeTargetSub =>
      'Benchmark for bills & savings ratio in Health Audit';

  @override
  String get settingsRouteCycleDayTitle => 'Cycle Start Date';

  @override
  String get settingsRouteCycleDaySub =>
      'Start date for monthly budget cycle calculation';

  @override
  String get settingsRouteStsWalletsTitle => 'Safe-to-Spend Wallets';

  @override
  String get settingsRouteStsWalletsSub =>
      'Select wallets included in daily safe-to-spend';

  @override
  String get settingsRouteCategoriesTitle => 'Transaction Categories';

  @override
  String get settingsRouteCategoriesSub =>
      'Manage expense & income category list';

  @override
  String get settingsRouteBankAppsTitle => 'Bank & E-Wallet Apps';

  @override
  String get settingsRouteBankAppsSub =>
      'List of financial apps supported by auto-parser';

  @override
  String get settingsRouteExportDataTitle => 'Export Transaction Data';

  @override
  String get settingsRouteExportDataSub =>
      'Save transaction report to CSV or Excel (.xls) file';

  @override
  String get settingsRouteClearTxTitle => 'Clear Transaction History';

  @override
  String get settingsRouteClearTxSub =>
      'Delete all mutations & reset active profile balances';

  @override
  String get settingsRouteDeleteProfileTitle => 'Delete Profile';

  @override
  String get settingsRouteDeleteProfileSub =>
      'Delete or reset active profile account from device';

  @override
  String get settingsRouteAboutAppTitle => 'About App';

  @override
  String get settingsRouteAboutAppSub =>
      'Version info, licenses, & release status';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileEditSub => 'Update profile information and identity';

  @override
  String get profileAddTitle => 'Add New Profile';

  @override
  String get profileAddSub => 'Add a new profile account on this device';

  @override
  String get healthFourPillars => '4 Financial Ratio Pillars';

  @override
  String get healthIndexPrefix => 'INDEX';

  @override
  String get healthLiquidAssets => 'Account Liquidity';

  @override
  String get healthPocketReserves => 'Pocket Reserves';

  @override
  String get healthNotesActions => 'NOTES & ACTIONS';

  @override
  String get healthTierExcellent => 'Excellent';

  @override
  String get healthTierGood => 'Stable';

  @override
  String get healthTierCaution => 'Caution';

  @override
  String get healthTierDeficit => 'Critical';

  @override
  String get healthHeadlineExcellent => 'Your Finances Are in Peak Condition!';

  @override
  String get healthHeadlineGood => 'Finances Stable, Ready to Grow.';

  @override
  String get healthHeadlineCaution => 'Spending Adjustments Needed.';

  @override
  String get healthHeadlineDeficit => 'Cashflow Requires Immediate Review.';

  @override
  String get healthPillar1Title => 'Emergency Fund (Runway)';

  @override
  String get healthPillar1DescPocket =>
      'Reserves in Emergency Pocket & cash balance';

  @override
  String get healthPillar1DescNoPocket => 'Ability to survive without income';

  @override
  String healthPillar1Value(String months) {
    return '$months Months';
  }

  @override
  String get healthPillar1Bench => 'Ideal: ≥ 3–6 Months';

  @override
  String get healthPillar2Title => 'Fixed Bill Burden';

  @override
  String get healthPillar2Desc =>
      'Share of subscriptions & installments from income';

  @override
  String get healthPillar2Bench => 'Ideal: ≤ 30%';

  @override
  String get healthPillar3Title => 'Net Savings Margin';

  @override
  String get healthPillar3Desc => 'Remaining cashflow successfully saved';

  @override
  String get healthPillar3Bench => 'Ideal: ≥ 15–20%';

  @override
  String get healthPillar4Title => 'Daily Spend Discipline';

  @override
  String get healthPillar4Desc => 'Spending compliance against safe limit';

  @override
  String get healthPillar4Bench => 'Target: Very Safe';

  @override
  String healthRecPillar1PocketLow(String current, String gap, String target) {
    return 'In Pocket: $current • Recommend adding $gap toward 3 mo ($target)';
  }

  @override
  String healthRecPillar1PocketMid(String current, String gap, String target) {
    return 'Emergency Pocket ($current) covers 3 mo! • Add $gap toward 6 mo ($target)';
  }

  @override
  String healthRecPillar1PocketFull(String current, String target) {
    return 'Emergency Pocket is peak ($current)! • 6 mo target ($target) fully met';
  }

  @override
  String healthRecPillar1NoPocketLow(String target, String gap) {
    return '3 mo target: $target • Create an Emergency Pocket & add $gap';
  }

  @override
  String healthRecPillar1NoPocketOk(String liquid, String target) {
    return 'Account balance $liquid covers 3 mo ($target) • Lock into an Emergency Pocket for safety';
  }

  @override
  String healthRecPillar2Ok(String bills, String maxBills) {
    return 'Bills $bills/mo • Ideal 30% limit: Max $maxBills/mo (Very Safe)';
  }

  @override
  String healthRecPillar2High(String bills, String maxBills, String excess) {
    return 'Bills $bills/mo exceed 30% ($maxBills/mo) • Cut $excess';
  }

  @override
  String healthRecPillar3Ok(String saved, String target) {
    return 'Savings $saved/mo • 20% target ($target/mo) achieved!';
  }

  @override
  String healthRecPillar3Mid(String saved, String gap) {
    return 'Savings $saved/mo • Recommend adding $gap/mo toward 20%';
  }

  @override
  String healthRecPillar3Deficit(String target) {
    return 'Cashflow deficit • Curb spending to save 20% target ($target/mo)';
  }

  @override
  String healthRecPillar4Ok(String daily, String monthly) {
    return 'Safe spend limit $daily/day • Remaining Safe-to-Spend: $monthly';
  }

  @override
  String healthRecPillar4Caution(String daily) {
    return 'Caution pacing • Cap daily spend at $daily/day to protect balance';
  }

  @override
  String get healthRecPillar4Deficit =>
      'Budget deficit • Defer variable spending and prioritize essentials';

  @override
  String healthRecEmergency(String target) {
    return 'Your 3-month emergency fund target is $target. Prioritize regular transfers to your Emergency Pocket.';
  }

  @override
  String healthRecBills(String bills, String maxBills) {
    return 'Recurring bills reached $bills/mo (safe limit $maxBills/mo). Review low-value subscriptions.';
  }

  @override
  String healthRecSavings(String saved, String target) {
    return 'This month\'s savings margin is only $saved. Target at least $target (20%) on payday.';
  }

  @override
  String healthRecPacing(String daily) {
    return 'Daily spend pacing is near the safe limit ($daily/day). Trim variable expenses to stay on track.';
  }

  @override
  String get healthRecNoPockets =>
      'You don\'t have a Savings Pocket yet. Create one to separate daily spending from savings.';

  @override
  String get healthRecAllGood =>
      'Your finances are in peak shape! Emergency reserves and savings ratio are healthy—keep up long-term investing.';

  @override
  String get inboxJustNow => 'Just now';

  @override
  String inboxMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String get inboxPickWallet => 'Select Wallet';

  @override
  String get inboxSwipeHint => 'Swipe right to accept, left to reject';

  @override
  String get inboxEditTitle => 'Adjust Transaction';

  @override
  String inboxEditSubWallet(String walletName) {
    return 'Account: $walletName';
  }

  @override
  String get inboxEditSubDefault => 'Edit transaction amount & type';

  @override
  String get inboxEditAmountLabel => 'TRANSACTION AMOUNT';

  @override
  String get inboxEditMerchantLabel => 'MERCHANT / RECIPIENT / NOTES';

  @override
  String get inboxEditMerchantHint => 'e.g., Coffee Shop, Transfer to Alex';

  @override
  String get inboxEditSaveBtn => 'Save Changes';

  @override
  String get inboxReassignTitle => 'Select Wallet / Workspace';

  @override
  String get inboxReassignSub =>
      'Reassign this auto-logged transaction to the right account or profile.';

  @override
  String get inboxReassignMainAccount => 'Main Account';

  @override
  String inboxReassignSuccess(String profileName, String walletName) {
    return 'Reassigned to $profileName • $walletName';
  }

  @override
  String get inboxSnackConfirmed => 'Transaction confirmed';

  @override
  String get inboxSnackRejected => 'Transaction rejected & balance restored';

  @override
  String get inboxSnackEdited => 'Transaction updated';

  @override
  String get catAddBtn => '+ Add';

  @override
  String get catCancelBtn => 'Cancel';

  @override
  String get catSaveBtn => 'Save';

  @override
  String get catDefaultFood => 'Food & Beverage';

  @override
  String get catDefaultTransport => 'Transportation';

  @override
  String get catDefaultShopping => 'Shopping & Needs';

  @override
  String get catDefaultBills => 'Bills & Utilities';

  @override
  String get catDefaultEntertainment => 'Entertainment & Subs';

  @override
  String get catDefaultHealth => 'Health';

  @override
  String get catDefaultEducation => 'Education & Courses';

  @override
  String get healthStatusComfortable => 'Very Safe';

  @override
  String get healthStatusCaution => 'Use Caution';

  @override
  String get healthStatusDeficit => 'Bill Deficit';

  @override
  String get swipeConfirmCorrect => 'Correct';

  @override
  String get swipeRejectWrong => 'Wrong';

  @override
  String get notifStreakExceededTitle => 'Daily Spending Limit Exceeded';

  @override
  String notifStreakExceededWithStreak(int streak) {
    return 'Today\'s spending exceeded your daily quota. Stay in control to keep your $streak-day saving streak alive.';
  }

  @override
  String get notifStreakExceededBody =>
      'Today\'s spending exceeded your daily Safe-to-Spend quota. Hold off spending until the next cycle.';

  @override
  String get notifStreakNearTitle => 'Approaching Daily Spending Limit';

  @override
  String notifStreakNearWithStreak(int percent, int streak) {
    return 'Today\'s spending reached $percent% of your quota. Limit spending to keep your $streak-day saving streak.';
  }

  @override
  String notifStreakNearBody(int percent) {
    return 'Today\'s spending has reached $percent% of your daily Safe-to-Spend allocation.';
  }

  @override
  String notifBillH3Title(String title) {
    return 'Bill $title (D-3)';
  }

  @override
  String notifBillH3Body(String amount, int day) {
    return '$amount is due in 3 days (Day $day).';
  }

  @override
  String notifBillH1Title(String title) {
    return 'Bill $title Tomorrow';
  }

  @override
  String notifBillH1Body(String amount) {
    return '$amount is due tomorrow. Make sure your balance is sufficient.';
  }

  @override
  String notifBillH0Title(String title) {
    return 'Bill $title Today';
  }

  @override
  String notifBillH0Body(String amount) {
    return '$amount is due today. Open to mark as paid.';
  }

  @override
  String notifAutoDeductTitle(String title) {
    return 'Bill Auto-Debited: $title';
  }

  @override
  String notifAutoDeductBody(String amount) {
    return 'Payment of $amount has been automatically deducted from your wallet.';
  }

  @override
  String get dailyPaceRemainingDays => 'Remaining Days This Month';

  @override
  String dailyPaceDaysCount(int days) {
    return '$days Days';
  }

  @override
  String get dailyPaceSafeLimit => 'Safe Daily Spend Limit';

  @override
  String get dailyPaceTodayExpense => 'Today\'s Spending';

  @override
  String get dailyPaceRemainingQuota => 'Remaining Today';

  @override
  String get dailyPaceOverQuota => 'Over Quota';

  @override
  String get dailyPaceFooter =>
      'Keeping your average daily spending below this amount ensures a budget surplus through the end of the month.';

  @override
  String stsStatusPrefix(String status) {
    return 'Status: $status';
  }

  @override
  String stsTotalAssetsCount(int count) {
    return 'Total Assets ($count Accounts)';
  }

  @override
  String get stsPerDaySuffix => '/ day';

  @override
  String get stsAllWalletsDesc =>
      'Calculated from all your accounts. This amount is safe to spend without risking missed monthly bills.';

  @override
  String stsSelectedWalletsDesc(int count) {
    return 'Calculated only from operational accounts ($count accounts). Bills and other savings accounts are kept separate.';
  }

  @override
  String get stsSettingsHint =>
      'Operational accounts can be configured in Settings > Budget Cycle & Safe-to-Spend.';

  @override
  String get chartLegendIn => 'In';

  @override
  String get chartLegendOut => 'Out';

  @override
  String get walletDeckEmptyTitle => 'No Accounts Yet';

  @override
  String get walletDeckEmptyDesc =>
      'No bank accounts or digital wallets connected yet.';

  @override
  String get walletDeckEmptyHint => 'Tap the + button below to add one';

  @override
  String get manageLabel => 'Manage';

  @override
  String get searchTxHint => 'Search transactions, accounts, merchants...';

  @override
  String get filterTxTitle => 'Filter Transactions';

  @override
  String get filterTxTypeHeader => 'TRANSACTION TYPE';

  @override
  String filterChipTypePrefix(String label) {
    return 'Type: $label';
  }

  @override
  String filterChipStatusPrefix(String label) {
    return 'Status: $label';
  }

  @override
  String get walletAvailableBalance => 'Available Balance';

  @override
  String pocketTxFrom(String wallet, String date) {
    return 'From $wallet • $date';
  }

  @override
  String pocketTxTo(String wallet, String date) {
    return 'To $wallet • $date';
  }

  @override
  String get pocketTxDepositDefault => 'Pocket Deposit';

  @override
  String get pocketTxWithdrawDefault => 'Pocket Withdrawal';

  @override
  String walletDetailSearchResults(int count) {
    return 'Search Results ($count)';
  }

  @override
  String get walletDetailHistoryTitle => 'Transaction History';

  @override
  String walletDetailTxCount(int count) {
    return '$count transactions';
  }

  @override
  String get walletDetailNoMatch => 'No matching transactions';

  @override
  String get walletDetailNoMutations => 'No transactions yet';

  @override
  String get walletDetailOfflineBadge => 'Offline & Encrypted';

  @override
  String get walletDetailPickAppTitle => 'Select App';

  @override
  String get walletDetailPickAppSub => 'Find a bank or e-wallet on your phone';

  @override
  String walletDetailAdjustTitle(String name) {
    return 'Adjust Balance: $name';
  }

  @override
  String get walletDetailAdjustSub =>
      'Edit starting balance & account preferences';

  @override
  String get walletDetailTxTitle => 'Log Transaction';

  @override
  String walletDetailTxSub(String name) {
    return 'Account: $name';
  }

  @override
  String historySearchCount(int count) {
    return 'Search Results: $count Transactions';
  }

  @override
  String historyFilterCount(int count) {
    return 'Filter Results: $count Transactions';
  }

  @override
  String historyDayTxCount(int count) {
    return '//  $count TRANSACTIONS';
  }

  @override
  String get historyEmptyDate => 'No Transactions on This Date';

  @override
  String get historyTitleCalendar => 'Financial\nActivity';

  @override
  String get historyTitleDefault => 'Transaction\nHistory';

  @override
  String get historySubCalendar => 'Activity & Cashflow Calendar';

  @override
  String historySubFiltered(String amount) {
    return 'Filtered Total: $amount';
  }

  @override
  String get historyTooltipCard => 'Card View';

  @override
  String get historyTooltipCalendar => 'Activity Calendar';

  @override
  String get txEditSubDefault => 'Edit transaction details';

  @override
  String get txWalletDefault => 'Account';

  @override
  String pocketMutationsCount(int count) {
    return '$count entries';
  }

  @override
  String get pocketDeleteLabel => 'Delete Pocket';

  @override
  String get pocketDepositBtn => 'Top Up';

  @override
  String get pocketWithdrawBtn => 'Withdraw';

  @override
  String get pocketDepositSheetTitle => 'Top Up Pocket';

  @override
  String get pocketWithdrawSheetTitle => 'Withdraw to Account';

  @override
  String pocketDepositSheetSub(String name) {
    return 'Select a source account to transfer funds into $name.';
  }

  @override
  String pocketWithdrawSheetSub(String name) {
    return 'Select a destination account to withdraw from $name.';
  }

  @override
  String get pocketNameRequired => 'Pocket name is required';

  @override
  String pocketInsufficientBalance(String max) {
    return 'Insufficient balance (Max $max)';
  }

  @override
  String get pocketCreateNow => 'Create Pocket Now';

  @override
  String get subsNotFoundTitle => 'No Bills Found';

  @override
  String subsNotFoundQuery(String query) {
    return 'No bills match \"$query\".';
  }

  @override
  String get subsNotFoundFilter => 'No bills in this filter.';

  @override
  String get subsHintExample => 'e.g., Netflix, Spotify, Electricity, Rent';

  @override
  String get subsDeleteInstallment => 'Delete This Installment';

  @override
  String get subsDeleteSub => 'Delete This Subscription';

  @override
  String get walletDeletedTitle => 'Account Deleted';

  @override
  String get walletSaveBtn => 'Save Account';

  @override
  String get pocketDeletedTitle => 'Pocket Deleted';

  @override
  String get profileMenuNewTitle => 'New Profile';

  @override
  String get profileMenuHealthTitle => 'Health Finance Details';

  @override
  String get profileMenuHealthSub =>
      'Comprehensive 4-pillar financial health audit';

  @override
  String get profileMenuShareTitle => 'Share Profile';

  @override
  String get profileMenuShareSub => 'Share financial profile card';

  @override
  String get profileCopiedTitle => 'Profile Copied';

  @override
  String get profileCopiedMsg => 'Profile card copied to clipboard!';

  @override
  String get profileUpdatedTitle => 'Profile Updated';

  @override
  String profileUpdatedMsg(String username) {
    return 'Profile \"$username\" updated!';
  }

  @override
  String get profileCreatedTitle => 'Profile Created';

  @override
  String profileCreatedMsg(String username) {
    return 'Profile \"$username\" created!';
  }

  @override
  String get profileCreateBtn => 'Create New Profile';

  @override
  String get profileDeleteTitle => 'Delete Profile?';

  @override
  String get profileResetTitle => 'Reset Profile?';

  @override
  String profileDeleteMsg(String username) {
    return 'Profile \"$username\" will be deleted. You can switch to another saved profile.';
  }

  @override
  String profileResetMsg(String username) {
    return 'Profile \"$username\" is your only profile. It will be reset to default settings.';
  }

  @override
  String get profileDeletedTitle => 'Profile Deleted';

  @override
  String get profileResetDoneTitle => 'Profile Reset';

  @override
  String profileDeletedMsg(String username) {
    return 'Profile \"$username\" has been deleted.';
  }

  @override
  String get profileResetDoneMsg => 'Profile has been reset.';

  @override
  String get profileCardRealBalance => 'REAL BALANCE';

  @override
  String get profileCardBills => 'BILLS';

  @override
  String get profileCardSafe => 'SAFE LEFT';

  @override
  String get avatarTitle => 'Profile Photo';

  @override
  String get avatarActiveSub => 'Custom photo active • Tap to change';

  @override
  String get avatarEmptySub => 'Tap to choose from gallery or camera';

  @override
  String get avatarErrorTitle => 'Failed to Pick Photo';

  @override
  String get avatarPickerTitle => 'Choose Photo Source';

  @override
  String get avatarPickerSub => 'Device gallery or camera';

  @override
  String get avatarGalleryTitle => 'Photo Gallery';

  @override
  String get avatarGallerySub => 'Select an image from device gallery';

  @override
  String get avatarCameraTitle => 'Camera';

  @override
  String get avatarCameraSub => 'Take a new photo with camera';

  @override
  String get avatarRemoveTitle => 'Remove Profile Photo';

  @override
  String get avatarRemoveSub => 'Use name initials as avatar';

  @override
  String settingsMonthlyTargetHeader(String currency) {
    return 'MONTHLY TARGET AMOUNT ($currency)';
  }

  @override
  String get settingsCyclePresetHeader => 'CYCLE DATE PRESETS';

  @override
  String settingsCycleDayEveryMonth(int day) {
    return 'Day $day of every month';
  }

  @override
  String get settingsCycleCustomHeader => 'CUSTOM DATE (1–31)';

  @override
  String get settingsCycleDatePrefix => 'Day ';

  @override
  String get settingsCycleApplyBtn => 'Apply';

  @override
  String settingsCycleDaysRemaining(int days) {
    return '$days days remaining in the current cycle.';
  }

  @override
  String get settingsStsOperationalHeader => 'OPERATIONAL WALLET ACCOUNTS';

  @override
  String settingsStsAllWallets(int count) {
    return 'All Accounts ($count)';
  }

  @override
  String get onboardingWalletQuestion => 'Where is your money kept?';

  @override
  String get onboardingWalletHelper =>
      'Add your first account. You can always add more later.';

  @override
  String get onboardingWalletHint => 'e.g., BCA, Jago, or Cash Wallet';

  @override
  String get onboardingWalletTypeLabel => 'Account type';

  @override
  String get onboardingWalletTypeCash => 'Cash';

  @override
  String get onboardingWalletBalanceLabel => 'Current balance';

  @override
  String walletDeletedMsg(String name) {
    return 'Account \"$name\" has been deleted.';
  }

  @override
  String get catTimelineTapHint => 'Tap a capsule for details';

  @override
  String catTimelineTxCount(int count) {
    return '$count transactions';
  }

  @override
  String get catTimelineDelete => 'Delete Category';

  @override
  String get catEditAction => 'Edit';

  @override
  String get catDeleteConfirmTitle => 'Delete Category?';

  @override
  String catDeleteConfirmBody(String name) {
    return 'Category \"$name\" will be removed from your list.';
  }

  @override
  String get onboardingWalletBalanceHelper =>
      'Optional. Leave 0 if you want to start from zero.';

  @override
  String get onbTopBarReady => 'Ready!';

  @override
  String onbTopBarStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onbUsernameTakenTitle => 'Username already taken';

  @override
  String get onbUsernameTakenMsg =>
      'Choose another username for this new profile.';

  @override
  String onbIncomePerDay(String amount) {
    return '≈ $amount per day';
  }

  @override
  String get kofiPromptTitle => 'Enjoying fiBOnanci?';

  @override
  String get kofiPromptBody =>
      'fiBOnanci is 100% free, offline, and ad-free. If this app helps manage your money, consider buying the developer a coffee on Ko-fi.';

  @override
  String get kofiPromptSupportBtn => 'Support on Ko-fi';

  @override
  String get kofiPromptLaterBtn => 'Maybe later';

  @override
  String get kofiPromptNeverBtn => 'Don\'t show again';

  @override
  String get kofiAboutRowTitle => 'Support Developer (Ko-fi)';

  @override
  String get aboutSectionUpdates => 'APPLICATION STATUS & UPDATES';

  @override
  String get aboutSectionSpecs => 'ABOUT & APP ARCHITECTURE';

  @override
  String get aboutAutoUpdate => 'Auto Update';

  @override
  String get aboutConnectingGithub => 'Connecting to GitHub Releases...';

  @override
  String aboutVersionReady(String version) {
    return 'Version v$version Ready to Download!';
  }

  @override
  String get aboutDownloadInstallBtn => 'Download & Install Update';

  @override
  String get aboutReleaseNotesTitle => 'Release Notes:';

  @override
  String aboutUpToDate(String version) {
    return 'App Is Up to Date (v$version)';
  }

  @override
  String get aboutNotChecked => 'Not yet checked against release repository';

  @override
  String get aboutCheckNowBtn => 'Check for Updates Now';

  @override
  String get aboutPrivacyDesc =>
      'Your financial data is stored 100% offline on your device with zero cloud sync or tracking. An internet connection is only used optionally when checking for updates or opening the Ko-fi support page.';

  @override
  String get aboutLicenseTitle => 'Software License';

  @override
  String get aboutStorageTitle => 'Database Storage';

  @override
  String get aboutParserTitle => 'Bank Notification Parser';

  @override
  String get aboutGithubTitle => 'GitHub Repository';

  @override
  String get aboutReleasesTitle => 'Full Release Notes';

  @override
  String get aboutOpenBrowser => 'Open in App';

  @override
  String get webViewErrorTitle => 'Page could not be loaded';

  @override
  String get webViewErrorBody =>
      'Make sure your device is connected to the internet and try again.';

  @override
  String get webViewRetryBtn => 'Try Again';

  @override
  String get onbLangTitle => 'Choose Your Language';

  @override
  String get onbLangSubtitle =>
      'Select your preferred language. You can change this anytime in Settings.';

  @override
  String get onbLangIdTitle => 'Bahasa Indonesia';

  @override
  String get onbLangIdSub => 'Indonesian (Rupiah format)';

  @override
  String get onbLangEnTitle => 'English';

  @override
  String get onbLangEnSub => 'English interface';

  @override
  String get onlineRequiredBadge =>
      'Checks GitHub for new releases when opened';

  @override
  String get aboutCheckOfflineError =>
      'Could not check for updates. Please try again later.';

  @override
  String get kofiRequiresInternetHint =>
      'Opening the Ko-fi page requires an internet connection';

  @override
  String get subModalPaymentSource => 'PAYMENT SOURCE';

  @override
  String get subModalAutoDeductTitle => 'Auto-Deduct Balance';

  @override
  String get subModalAutoDeductSubtitle =>
      'Automatically deduct balance on due date';

  @override
  String get subDeletedSnackTitle => 'Bill Deleted';

  @override
  String get subDeletedSnackMsg => 'Bill deleted & account balance refunded.';

  @override
  String get subDeletedSnackTag => 'DELETED';

  @override
  String get subDeleteThisBtn => 'Delete This Bill';

  @override
  String get subDueDateHeader => 'DUE DATE';

  @override
  String subDueDayEveryMonth(int day) {
    return 'Day $day every month';
  }

  @override
  String get subInstallmentDeadlineHeader => 'INSTALLMENT DEADLINE (REQUIRED)';

  @override
  String subInstallmentFinishDate(String date) {
    return 'Ends $date';
  }

  @override
  String get subInstallmentCustomBtn => 'Custom';

  @override
  String get subTenorDurationLabel => 'Tenor Duration';

  @override
  String get subTenorMonthsShort => 'Mo';

  @override
  String subInstallmentCardSubtitle(int cycles) {
    return 'installment /mo ($cycles mo tenor)';
  }

  @override
  String get subSpecPaymentProgress => 'Payment Progress';
}
