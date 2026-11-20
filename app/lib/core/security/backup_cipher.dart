import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class InvalidBackupPasswordException implements Exception {
  final String message;
  const InvalidBackupPasswordException([this.message = 'Kata sandi cadangan salah atau berkas rusak.']);
  @override
  String toString() => message;
}

class BackupCipher {
  static Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = rnd.nextInt(256);
    }
    return bytes;
  }

  static Uint8List _deriveKey(String password, Uint8List salt, String context) {
    final raw = utf8.encode('$password:$context');
    final combined = Uint8List(salt.length + raw.length);
    combined.setRange(0, salt.length, salt);
    combined.setRange(salt.length, combined.length, raw);
    return Uint8List.fromList(sha256.convert(combined).bytes);
  }

  static Map<String, dynamic> encrypt(Map<String, dynamic> payload, String password) {
    final salt = _randomBytes(16);
    final ivBytes = _randomBytes(16);

    final encKey = _deriveKey(password, salt, 'enc');
    final macKey = _deriveKey(password, salt, 'mac');

    final key = enc.Key(encKey);
    final iv = enc.IV(ivBytes);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

    final plainText = jsonEncode(payload);
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final hmac = Hmac(sha256, macKey);
    final macData = Uint8List(ivBytes.length + encrypted.bytes.length);
    macData.setRange(0, ivBytes.length, ivBytes);
    macData.setRange(ivBytes.length, macData.length, encrypted.bytes);
    final mac = hmac.convert(macData).toString();

    return {
      'format': 'fibonanci_vault_v1',
      'encrypted': true,
      'algorithm': 'AES-256-CBC-HMAC-SHA256',
      'salt': base64Encode(salt),
      'iv': base64Encode(ivBytes),
      'ciphertext': encrypted.base64,
      'mac': mac,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static bool isEncryptedPayload(Map<String, dynamic> data) {
    return data['encrypted'] == true && data['format'] == 'fibonanci_vault_v1';
  }

  static Map<String, dynamic> decrypt(Map<String, dynamic> envelope, String password) {
    if (!isEncryptedPayload(envelope)) return envelope;

    final salt = base64Decode(envelope['salt'] as String);
    final ivBytes = base64Decode(envelope['iv'] as String);
    final cipherStr = envelope['ciphertext'] as String;
    final expectedMac = envelope['mac'] as String;

    final macKey = _deriveKey(password, salt, 'mac');
    final cipherBytes = base64Decode(cipherStr);

    final hmac = Hmac(sha256, macKey);
    final macData = Uint8List(ivBytes.length + cipherBytes.length);
    macData.setRange(0, ivBytes.length, ivBytes);
    macData.setRange(ivBytes.length, macData.length, cipherBytes);
    final computedMac = hmac.convert(macData).toString();

    if (computedMac != expectedMac) {
      throw const InvalidBackupPasswordException('Kata sandi salah atau berkas cadangan telah dimanipulasi.');
    }

    final encKey = _deriveKey(password, salt, 'enc');
    final key = enc.Key(encKey);
    final iv = enc.IV(ivBytes);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

    final decrypted = encrypter.decrypt64(cipherStr, iv: iv);
    final decoded = jsonDecode(decrypted);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const InvalidBackupPasswordException('Format payload hasil dekripsi tidak valid.');
  }
}
