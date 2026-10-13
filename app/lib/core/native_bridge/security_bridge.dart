import 'package:flutter/services.dart';

class SecuritySettingsData {
  final bool biometricLockEnabled;
  final bool privacyScreenEnabled;
  final bool isDeviceSecure;

  const SecuritySettingsData({
    this.biometricLockEnabled = false,
    this.privacyScreenEnabled = false,
    this.isDeviceSecure = false,
  });
}

class SecurityBridge {
  static const _channel = MethodChannel('com.fibonanci.app/notification_service');

  static bool _memoryBiometricEnabled = false;
  static bool _memoryPrivacyScreenEnabled = false;

  static Future<String> getDatabaseEncryptionKey() async {
    try {
      final key = await _channel.invokeMethod<String>('getDatabaseEncryptionKey');
      if (key != null && key.isNotEmpty) {
        return key;
      }
    } catch (_) {}
    return 'f1b0n4nc1_l0c4l_v4ult_256b1t_f4llb4ck_k3y_98a7b6c5d4e3f2a1b0c9d8';
  }

  static Future<SecuritySettingsData> getSecuritySettings() async {
    try {
      final map = await _channel.invokeMethod<Map>('getSecuritySettings');
      if (map != null) {
        _memoryBiometricEnabled = map['biometricLockEnabled'] == true;
        _memoryPrivacyScreenEnabled = map['privacyScreenEnabled'] == true;
        return SecuritySettingsData(
          biometricLockEnabled: _memoryBiometricEnabled,
          privacyScreenEnabled: _memoryPrivacyScreenEnabled,
          isDeviceSecure: map['isDeviceSecure'] == true,
        );
      }
    } catch (_) {}
    return SecuritySettingsData(
      biometricLockEnabled: _memoryBiometricEnabled,
      privacyScreenEnabled: _memoryPrivacyScreenEnabled,
      isDeviceSecure: false,
    );
  }

  static Future<void> setBiometricLockEnabled(bool enabled) async {
    _memoryBiometricEnabled = enabled;
    try {
      await _channel.invokeMethod('setBiometricLockEnabled', {'enabled': enabled});
    } catch (_) {}
  }

  static Future<void> setPrivacyScreenEnabled(bool enabled) async {
    _memoryPrivacyScreenEnabled = enabled;
    try {
      await _channel.invokeMethod('setPrivacyScreenEnabled', {'enabled': enabled});
    } catch (_) {}
  }

  static Future<bool> authenticateBiometric({
    String reason = 'Verifikasi identitas untuk membuka fiBOnanci',
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>(
        'authenticateBiometric',
        {'reason': reason},
      );
      return ok ?? false;
    } catch (_) {
      return true;
    }
  }
}
