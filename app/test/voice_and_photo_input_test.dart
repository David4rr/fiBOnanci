import 'package:drift/native.dart';
import 'package:fibonanci_app/core/smart_input/smart_input_bridge.dart';
import 'package:fibonanci_app/core/smart_input/smart_transaction_parser.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  tearDown(() {
    SmartInputBridge.testVoiceOverride = null;
    SmartInputBridge.testPhotoOcrOverride = null;
  });

  group('IndonesianAmountParser & SmartTransactionParser Unit Tests', () {
    late AppDatabase db;
    late List<WalletEntry> wallets;
    late List<CategoryEntry> categories;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      wallets = await db.select(db.wallets).get();
      categories = await db.select(db.categories).get();
    });

    tearDown(() async {
      await db.close();
    });

    test('parses spoken Indonesian number words, shorthand, and formatted IDR', () {
      expect(
        IndonesianAmountParser.parseVoiceOrInlineAmount(
          'Beli kopi kenangan dua puluh lima ribu pakai GoPay',
        ),
        25000,
      );
      expect(
        IndonesianAmountParser.parseVoiceOrInlineAmount(
          'Isi bensin pertamax seratus lima puluh ribu',
        ),
        150000,
      );
      expect(
        IndonesianAmountParser.parseVoiceOrInlineAmount(
          'Terima gaji lima belas juta masuk ke BCA',
        ),
        15000000,
      );
      expect(
        IndonesianAmountParser.parseVoiceOrInlineAmount(
          'Dapat bonus proyek 2,5 juta',
        ),
        2500000,
      );
      expect(
        IndonesianAmountParser.parseVoiceOrInlineAmount(
          'Makan siang 45rb dari Mandiri',
        ),
        45000,
      );
    });

    test('parses multi-line receipt OCR and ignores TUNAI/KEMBALI lines', () {
      const receiptText = '''
INDOMARET CABANG SUDIRMAN
JL. JEND SUDIRMAN NO 12
ROTI TAWAR           18.500
SUSU UHT 1L          24.000
---------------------------
TOTAL BAYAR       Rp 42.500
TUNAI             Rp 50.000
KEMBALI           Rp  7.500
''';
      final draft = SmartTransactionParser.parse(
        rawText: receiptText,
        source: SmartInputSource.camera,
        wallets: wallets,
        categories: categories,
      );

      expect(draft.amount, 42500);
      expect(draft.type, 'expense');
      expect(draft.notes, 'INDOMARET CABANG SUDIRMAN');
      final cat = categories.firstWhere((c) => c.id == draft.categoryId);
      expect(cat.name, contains('Belanja'));
    });

    test('ignores date 16 and time 16:00 and accurately parses 14k total', () {
      const receiptWithDate16 = '''
CAFE KENANGAN FIBONANCI
TGL: 16/10/2026 16:00:00
KASIR: SITI
---------------------------
ES KOPI SUSU        14.000
---------------------------
TOTAL               14.000
BAYAR TUNAI         20.000
KEMBALI              6.000
TERIMA KASIH
''';
      final draft = SmartTransactionParser.parse(
        rawText: receiptWithDate16,
        source: SmartInputSource.camera,
        wallets: wallets,
        categories: categories,
      );
      expect(draft.amount, 14000);

      const receiptWith14kShorthand = '''
WARUNG KOPI LOKAL
16-10-2026
KOPI HITAM          14k
---------------------------
TOTAL: 14k
''';
      final draft2 = SmartTransactionParser.parse(
        rawText: receiptWith14kShorthand,
        source: SmartInputSource.camera,
        wallets: wallets,
        categories: categories,
      );
      expect(draft2.amount, 14000);

      const receiptMultiLineTotal = '''
BAKSO MALANG
TGL: 16 OKT 2026
TOTAL HARGA
---------------------------
14.000
''';
      final draft3 = SmartTransactionParser.parse(
        rawText: receiptMultiLineTotal,
        source: SmartInputSource.camera,
        wallets: wallets,
        categories: categories,
      );
      expect(draft3.amount, 14000);
    });

    test('parses voice expense, income, and inter-wallet transfer accurately', () {
      final expenseDraft = SmartTransactionParser.parse(
        rawText: 'Beli kopi kenangan dua puluh lima ribu pakai OVO',
        source: SmartInputSource.voice,
        wallets: wallets,
        categories: categories,
      );
      expect(expenseDraft.amount, 25000);
      expect(expenseDraft.type, 'expense');
      expect(expenseDraft.notes, 'Beli kopi kenangan');
      final ovoWallet = wallets.firstWhere((w) => w.id == expenseDraft.walletId);
      expect(ovoWallet.name.toLowerCase(), contains('ovo'));

      final incomeDraft = SmartTransactionParser.parse(
        rawText: 'Terima gaji bulanan 12 juta masuk ke BCA',
        source: SmartInputSource.voice,
        wallets: wallets,
        categories: categories,
      );
      expect(incomeDraft.amount, 12000000);
      expect(incomeDraft.type, 'income');
      final bcaWallet = wallets.firstWhere((w) => w.id == incomeDraft.walletId);
      expect(bcaWallet.name.toLowerCase(), contains('bca'));

      final transferDraft = SmartTransactionParser.parse(
        rawText: 'Transfer 500rb dari BCA ke OVO',
        source: SmartInputSource.voice,
        wallets: wallets,
        categories: categories,
      );
      expect(transferDraft.amount, 500000);
      expect(transferDraft.type, 'transfer');
      expect(transferDraft.walletId, bcaWallet.id);
      expect(transferDraft.destinationWalletId, ovoWallet.id);
    });
  });

  group('Voice & Photo Capture UI Integration Tests', () {
    testWidgets('Speed-Dial FAB Foto option auto-fills TransactionModal from OCR and saves transaction', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      final repo = DriftFinanceRepository(db);

      SmartInputBridge.testPhotoOcrOverride = (source) async =>
          'BUKTI TRANSAKSI BERHASIL\nMerchant: QRIS STARBUCKS\nSumber Dana: BCA\nTOTAL PEMBAYARAN Rp 58.000';

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // 1. Tap '+' dock button -> opens Speed-Dial FAB
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // 2. Tap 'Foto' FAB -> opens Catat Transaksi and auto-fills 58.000 & 'QRIS STARBUCKS'
      await tester.tap(find.byKey(const Key('quick_input_photo_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.text('Suara'), findsNothing);
      expect(find.text('Foto Struk'), findsNothing);
      expect(find.text('Bukti Galeri'), findsNothing);
      expect(find.text('58.000'), findsOneWidget);
      expect(find.text('QRIS STARBUCKS'), findsOneWidget);

      // 3. Save transaction and verify it persists in SQLite
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      final txs = await db.select(db.transactions).get();
      expect(txs.any((t) => t.amount == 58000 && t.notes == 'QRIS STARBUCKS'), isTrue);

      await db.close();
    });

    testWidgets('Tapping dock + button opens Speed-Dial FAB with Input Manual, Voice, and Foto options', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      final repo = DriftFinanceRepository(db);

      SmartInputBridge.testVoiceOverride = () async =>
          'Makan malam sate ayam 65rb pakai BCA';

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // Tap '+' button on floating dock -> Speed-Dial FAB pops up
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quick_input_manual_tile')), findsOneWidget);
      expect(find.byKey(const Key('quick_input_voice_tile')), findsOneWidget);
      expect(find.byKey(const Key('quick_input_photo_tile')), findsOneWidget);

      // Tap 'Voice' FAB -> opens TransactionModal and immediately runs voice capture
      await tester.tap(find.byKey(const Key('quick_input_voice_tile')));
      await tester.pumpAndSettle();
      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.text('65.000'), findsOneWidget);

      await db.close();
    });
  });
}
