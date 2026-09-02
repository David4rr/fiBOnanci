import 'package:fibonanci_app/core/notification_parser/notification_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bank & E-Wallet Notification Parser Suite', () {
    // 1. BCA
    test('BCA QRIS Payment parses amount and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA mobile',
        body: 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 35000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'Kopi Kenangan');
    });

    test('BCA m-Transfer Out parses amount and recipient', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA mobile',
        body: 'Transfer keluar Rp 500.000 ke Budi Santoso berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 500000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'Budi Santoso');
    });

    // 2. blu by BCA Digital
    test('blu by BCA Digital QRIS parses amount and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'com.bcadigital.blu',
        title: 'blu',
        body: 'Pembayaran QRIS sebesar Rp 45.000 di Kopi Kenangan telah berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 45000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'Kopi Kenangan');
    });

    test('blu by BCA Digital Transfer In parses amount and sender', () {
      final res = NotificationParser.parse(
        packageName: 'com.bcadigital.blu',
        title: 'blu',
        body: 'Kamu menerima transfer sebesar Rp 250.000 dari SITI NURHALIZA.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 250000.0);
      expect(res.type, 'income');
      expect(res.counterparty, 'SITI NURHALIZA');
    });

    // 3. Livin' by Mandiri
    test('Livin Mandiri QR parses IDR and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankmandiri.livin',
        title: 'Livin by Mandiri',
        body: "Transaksi Livin' QR sebesar IDR 75.000 di HokBen Paskal berhasil.",
      );
      expect(res, isNotNull);
      expect(res!.amount, 75000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'HokBen Paskal');
    });

    // 4. Bank Jago
    test('Bank Jago payment parses amount and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankjago.app',
        title: 'Jago',
        body: 'Kamu telah membayar Rp 68.000 ke FamilyMart menggunakan Kantong Jajan.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 68000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'FamilyMart');
    });

    // 5. SeaBank
    test('SeaBank transfer parses amount and counterparty', () {
      final res = NotificationParser.parse(
        packageName: 'com.seabank.id',
        title: 'SeaBank',
        body: 'Berhasil transfer Rp 150.000 ke DANA Siti Aminah.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 150000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'DANA Siti Aminah');
    });

    test('SeaBank transfer masuk parses amount and account from real notification', () {
      final res = NotificationParser.parse(
        packageName: 'com.seabank.id',
        title: 'Transfer Masuk',
        body: 'Kamu menerima transfer saldo senilai Rp40.000 ke rekening 7776. Ref. number 20260828BMRIIDJA01000227869030.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 40000.0);
      expect(res.type, 'income');
      expect(res.counterparty, 'Transfer Masuk (Rek. 7776)');
    });

    test('SeaBank Dana Masuk from ShopeePay parses income and sender', () {
      final res = NotificationParser.parse(
        packageName: 'com.seabank.id',
        title: 'Dana Masuk ke Rekeningmu',
        body: 'Kamu menerima dana sebesar Rp10.000 dari ShopeePay DAVID ARROZAQI pada 28 Agu 2026 20:43 WIB.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 10000.0);
      expect(res.type, 'income');
      expect(res.counterparty, 'ShopeePay DAVID ARROZAQI');
    });

    test('SeaBank Pembayaran Virtual Account ShopeePay parses expense and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'com.seabank.id',
        title: 'Pembayaran Berhasil',
        body: 'Kamu telah melakukan transfer virtual account sebesar Rp10.000 kepada ShopeePay pada 28 Agu 2026 20:42 WIB',
      );
      expect(res, isNotNull);
      expect(res!.amount, 10000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'ShopeePay');
    });

    // 6. OVO
    test('OVO payment parses amount and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'ovo.id',
        title: 'OVO',
        body: 'Berhasil bayar Rp 52.000 di Janji Jiwa.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 52000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'Janji Jiwa');
    });

    // 7. GoPay
    test('GoPay payment parses amount and merchant', () {
      final res = NotificationParser.parse(
        packageName: 'com.gojek.app',
        title: 'GoPay',
        body: 'Pembayaran Rp 48.000 ke Solaria berhasil!',
      );
      expect(res, isNotNull);
      expect(res!.amount, 48000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'Solaria');
    });

    // 8. ShopeePay
    test('ShopeePay isi saldo top up parses income and amount from real notification', () {
      final res = NotificationParser.parse(
        packageName: 'com.shopee.id',
        title: 'Isi Saldo Berhasil',
        body: 'Pengisian saldo sebesar Rp.10.000 telah ditambahkan ke ShopeePay-mu. Saldo saat ini sebesar Rp.19.259',
      );
      expect(res, isNotNull);
      expect(res!.amount, 10000.0);
      expect(res.type, 'income');
      expect(res.counterparty, 'Isi Saldo ShopeePay');
    });

    // 8. Negative Security & Marketing Blacklist
    test('OTP alert is strictly rejected and returns null', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA',
        body: 'JANGAN BERIKAN KODE OTP 492019 ke siapapun termasuk pihak BCA.',
      );
      expect(res, isNull);
    });

    test('DANA verification code is rejected', () {
      final res = NotificationParser.parse(
        packageName: 'id.dana',
        title: 'DANA',
        body: 'KODE VERIFIKASI DANA Anda: 839102. Waspada penipuan!',
      );
      expect(res, isNull);
    });

    test('Marketing promo cashback is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.gojek.app',
        title: 'GoPay Promo',
        body: 'Dapatkan cashback 50% hingga Rp 20.000 untuk jajan hari ini!',
      );
      expect(res, isNull);
    });

    test('PIN update security alert is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankmandiri.livin',
        title: 'Livin Alert',
        body: "PIN Livin' Anda berhasil diubah pada 28/08/2026.",
      );
      expect(res, isNull);
    });

    test('Ad notification with food menu starting price is discarded and not parsed as expense', () {
      final res = NotificationParser.parse(
        packageName: 'com.grabtaxi.passenger',
        title: 'GrabFood',
        body: 'Laper? Pesan menu favoritmu sekarang mulai Rp 25.000!',
      );
      expect(res, isNull);
    });

    test('Ad notification with bank investment offer is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA Info',
        body: 'Investasi Reksa Dana mulai dari Rp 10.000 di Welma sekarang juga!',
      );
      expect(res, isNull);
    });

    test('Ad notification with PayLater limit offer is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.shopee.id',
        title: 'ShopeePay',
        body: 'Butuh dana cepat? SPinjam siap bantu s.d Rp 15.000.000 dengan cicilan ringan!',
      );
      expect(res, isNull);
    });

    test('Ad notification with loan offer is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankmandiri.livin',
        title: 'Livin Mandiri',
        body: 'Ajukan pinjaman serbaguna dengan limit s.d Rp 100.000.000 bunga ringan.',
      );
      expect(res, isNull);
    });

    test('Ad notification with referral bonus is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.jago.app',
        title: 'Bank Jago',
        body: 'Ajak teman buka akun Jago dan dapatkan bonus saldo Rp 50.000.',
      );
      expect(res, isNull);
    });

    test('Ad notification with flash sale is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.shopee.id',
        title: 'Shopee',
        body: 'Flash Sale kilat! Dapatkan barang impian serba Rp 1.000 hari ini.',
      );
      expect(res, isNull);
    });

    test('Ad notification with deals and minimum spend is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'id.dana',
        title: 'DANA Deals',
        body: 'Hemat hingga Rp 15.000 belanja di minimarket favoritmu.',
      );
      expect(res, isNull);
    });

    test('Ad notification with deposit bonus is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.seabank.id',
        title: 'SeaBank',
        body: 'Buka deposito dapat bunga hingga 6% p.a. mulai Rp 1.000.000!',
      );
      expect(res, isNull);
    });

    test('Ad notification with lottery/giveaway is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'Info BCA',
        body: 'Ikuti undian Gebyar BCA berhadiah total Rp 1.000.000.000!',
      );
      expect(res, isNull);
    });

    test('Ad notification with loan and low interest rate is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA',
        body: 'Dapatkan pinjaman hingga Rp 50.000.000 dengan bunga rendah.',
      );
      expect(res, isNull);
    });

    test('Ad notification with free shipping and min spend is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.shopee.id',
        title: 'Shopee',
        body: 'Gratis ongkir min. belanja Rp 30.000 di merchant pilihan.',
      );
      expect(res, isNull);
    });

    test('Ad notification with discount and exclusive deal is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.gojek.app',
        title: 'GoPay Deals',
        body: 'Nikmati penawaran eksklusif diskon s.d Rp 50.000 hari ini!',
      );
      expect(res, isNull);
    });

    test('Ad notification with account upgrade limit is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'ovo.id',
        title: 'OVO Premier',
        body: 'Upgrade ke akun Premium untuk limit hingga Rp 20.000.000!',
      );
      expect(res, isNull);
    });

    test('Ad notification with coupon is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'id.dana',
        title: 'DANA',
        body: 'Kupon belanja Rp 50.000 menantimu di aplikasi!',
      );
      expect(res, isNull);
    });

    test('Ad notification with snack CTA is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.grabtaxi.passenger',
        title: 'GrabFood',
        body: 'Yuk jajan martabak cuma Rp 20.000 lewat GrabFood!',
      );
      expect(res, isNull);
    });

    test('Ad notification with food order CTA is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.gojek.app',
        title: 'GoFood',
        body: 'Pesan GoFood sekarang hemat s.d Rp 35.000!',
      );
      expect(res, isNull);
    });

    test('Informational balance inquiry is not parsed as expense', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'Info Saldo',
        body: 'Saldo rekening Anda saat ini adalah Rp 1.500.000.',
      );
      expect(res, isNull);
    });

    test('Informational maintenance alert is discarded', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankmandiri.livin',
        title: 'Pengumuman',
        body: 'Pemeliharaan sistem terjadwal pada 15/09/2026 pukul 01:00 - 05:00 WIB.',
      );
      expect(res, isNull);
    });

    test('Universal classifier handles arbitrary incoming transfer from e-wallet', () {
      final res = NotificationParser.parse(
        packageName: 'com.seabank.id',
        title: 'Transfer Masuk BI-FAST',
        body: 'Anda menerima transfer sebesar Rp 75.000 dari OVO KAS.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 75000.0);
      expect(res.type, 'income');
      expect(res.counterparty, 'OVO KAS');
    });

    test('Universal classifier handles arbitrary outgoing transfer to another bank', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankmandiri.livin',
        title: 'Transfer Berhasil',
        body: 'Transfer sebesar Rp 120.000 ke Rekening BCA 0129381 berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 120000.0);
      expect(res.type, 'expense');
      expect(res.counterparty, 'Rekening BCA 0129381');
    });

    test('Add funds notification in English parses as income with amount', () {
      final res = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA mobile',
        body: 'Add funds of Rp 250.000 to your account was successful.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 250000.0);
      expect(res.type, 'income');
    });

    test('Top up notification with amount parses as income', () {
      final res = NotificationParser.parse(
        packageName: 'com.gojek.app',
        title: 'GoPay',
        body: 'Top up GoPay Rp 100.000 dari BCA berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 100000.0);
      expect(res.type, 'income');
    });

    test('Tambah dana notification parses as income', () {
      final res = NotificationParser.parse(
        packageName: 'id.dana',
        title: 'DANA',
        body: 'Tambah dana sebesar Rp 50.000 ke saldo DANA berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 50000.0);
      expect(res.type, 'income');
    });

    test('Isi saldo notification parses as income', () {
      final res = NotificationParser.parse(
        packageName: 'ovo.id',
        title: 'OVO',
        body: 'Isi saldo Rp 75.000 berhasil dilakukan.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 75000.0);
      expect(res.type, 'income');
    });

    test('Universal classifier handles electricity bill payment correctly', () {
      final res = NotificationParser.parse(
        packageName: 'com.pln.mobile',
        title: 'Pembayaran Tagihan Listrik',
        body: 'Pembayaran tagihan listrik PLN sebesar Rp 175.000 berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 175000.0);
      expect(res.type, 'expense');
    });

    test('Universal classifier handles automatic debit subscription payment correctly', () {
      final res = NotificationParser.parse(
        packageName: 'com.spotify.music',
        title: 'Spotify Premium',
        body: 'Debit otomatis Spotify Premium Rp 54.990 berhasil diproses.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 54990.0);
      expect(res.type, 'expense');
    });

    test('Universal classifier handles PayLater bill payment as legitimate expense', () {
      final res = NotificationParser.parse(
        packageName: 'com.shopee.id',
        title: 'Tagihan Lunas',
        body: 'Pembayaran tagihan SPayLater sebesar Rp 250.000 berhasil diterima.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 250000.0);
      expect(res.type, 'expense');
    });

    test('Universal classifier handles cash withdrawal correctly', () {
      final res = NotificationParser.parse(
        packageName: 'com.bankmandiri.livin',
        title: 'Tarik Tunai',
        body: 'Penarikan tunai sebesar Rp 300.000 di ATM berhasil.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 300000.0);
      expect(res.type, 'expense');
    });

    test('Universal classifier handles English debited notification correctly', () {
      final res = NotificationParser.parse(
        packageName: 'com.citi.mobile',
        title: 'Transaction Alert',
        body: 'Your account was debited IDR 120.000 for payment to Starbucks.',
      );
      expect(res, isNotNull);
      expect(res!.amount, 120000.0);
      expect(res.type, 'expense');
    });
  });
}
