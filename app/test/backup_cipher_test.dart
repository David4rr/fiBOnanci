import 'package:fibonanci_app/core/security/backup_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupCipher AES-256 Vault Tests', () {
    final sampleData = {
      'profile': {'id': 'p1', 'username': 'Budi', 'currency': 'IDR'},
      'wallets': [
        {'id': 'w1', 'name': 'BCA', 'balance': 15000000.0},
        {'id': 'w2', 'name': 'Mandiri', 'balance': 5000000.0},
      ],
      'transactions': [
        {'id': 't1', 'amount': 50000.0, 'notes': 'Kopi Janji Jiwa'},
      ],
    };

    test('Encrypts payload and decrypts with correct password', () {
      const password = 'RahasiaSuperAman123!';
      final encrypted = BackupCipher.encrypt(sampleData, password);

      expect(encrypted['format'], 'fibonanci_vault_v1');
      expect(encrypted['encrypted'], isTrue);
      expect(encrypted['ciphertext'], isNotEmpty);
      expect(encrypted['mac'], isNotEmpty);

      // Decrypt
      final decrypted = BackupCipher.decrypt(encrypted, password);
      expect(decrypted['profile']['username'], 'Budi');
      expect((decrypted['wallets'] as List).length, 2);
      expect((decrypted['transactions'] as List).first['notes'], 'Kopi Janji Jiwa');
    });

    test('Throws InvalidBackupPasswordException when password is wrong', () {
      const password = 'Benar123';
      const wrongPassword = 'Salah456';
      final encrypted = BackupCipher.encrypt(sampleData, password);

      expect(
        () => BackupCipher.decrypt(encrypted, wrongPassword),
        throwsA(isA<InvalidBackupPasswordException>()),
      );
    });

    test('Throws InvalidBackupPasswordException when MAC is tampered', () {
      const password = 'Benar123';
      final encrypted = BackupCipher.encrypt(sampleData, password);
      final tampered = Map<String, dynamic>.from(encrypted);
      tampered['mac'] = 'deadbeefdeadbeef';

      expect(
        () => BackupCipher.decrypt(tampered, password),
        throwsA(isA<InvalidBackupPasswordException>()),
      );
    });

    test('Passes through unencrypted payloads directly', () {
      final plain = {'wallets': []};
      final result = BackupCipher.decrypt(plain, 'anyPassword');
      expect(result, plain);
    });
  });
}
