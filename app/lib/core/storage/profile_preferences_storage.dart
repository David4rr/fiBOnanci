import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Lightweight persistent storage for profile-specific preferences such as
/// Safe-to-Spend operational wallet IDs and monthly budget cycle reset days.
class ProfilePreferencesStorage {
  static final Map<String, Set<String>?> _stsWallets = {};
  static final Map<String, int> _cycleDays = {};
  static bool? _onboardingCompleted;
  static String _themeMode = 'system';
  static bool _isLoaded = false;
  static File? _customStorageFile;

  @visibleForTesting
  static void setStorageFile(File? file) {
    _customStorageFile = file;
    _isLoaded = false;
    _stsWallets.clear();
    _cycleDays.clear();
    _onboardingCompleted = null;
    _themeMode = 'system';
  }

  @visibleForTesting
  static void resetForTest() {
    _customStorageFile = null;
    _isLoaded = false;
    _stsWallets.clear();
    _cycleDays.clear();
    _onboardingCompleted = null;
    _themeMode = 'system';
  }

  static Future<File?> _resolveFile() async {
    if (_customStorageFile != null) return _customStorageFile;
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(p.join(dir.path, 'profile_preferences.json'));
    } catch (_) {
      return null;
    }
  }

  static Future<void> load() async {
    if (_isLoaded && _customStorageFile == null) return;
    try {
      final file = await _resolveFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(content);
          if (data['cycle_days'] is Map) {
            _cycleDays.clear();
            (data['cycle_days'] as Map).forEach((k, v) {
              if (v is int) _cycleDays[k.toString()] = v;
            });
          }
          if (data['safe_to_spend_wallets'] is Map) {
            _stsWallets.clear();
            (data['safe_to_spend_wallets'] as Map).forEach((k, v) {
              if (v is List) {
                _stsWallets[k.toString()] = v.map((e) => e.toString()).toSet();
              } else if (v == null) {
                _stsWallets[k.toString()] = null;
              }
            });
          }
          if (data['onboarding_completed'] is bool) {
            _onboardingCompleted = data['onboarding_completed'] as bool;
          }
          if (data['theme_mode'] is String) {
            _themeMode = data['theme_mode'] as String;
          }
        }
      }
      _isLoaded = true;
    } catch (_) {}
  }

  static Future<void> _saveToDisk() async {
    try {
      final file = await _resolveFile();
      if (file == null) return;
      final Map<String, dynamic> data = {
        'cycle_days': _cycleDays,
        'safe_to_spend_wallets': _stsWallets.map((k, v) => MapEntry(k, v?.toList())),
        'onboarding_completed': _onboardingCompleted ?? (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')),
        'theme_mode': _themeMode,
      };
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {}
  }

  static String getThemeMode() => _themeMode;

  static Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _saveToDisk();
  }

  static bool isOnboardingCompleted() {
    if (_onboardingCompleted != null) return _onboardingCompleted!;
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return true;
    return false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    _onboardingCompleted = value;
    await _saveToDisk();
  }

  static Set<String>? getSafeToSpendWallets(String profileId) {
    return _stsWallets[profileId];
  }

  static Future<void> setSafeToSpendWallets(String profileId, Set<String>? wallets) async {
    _stsWallets[profileId] = wallets;
    await _saveToDisk();
  }

  static int getBudgetCycleDay(String profileId) {
    return _cycleDays[profileId] ?? 1;
  }

  static Future<void> setBudgetCycleDay(String profileId, int day) async {
    _cycleDays[profileId] = day;
    await _saveToDisk();
  }

  static Future<void> removeProfile(String profileId) async {
    _stsWallets.remove(profileId);
    _cycleDays.remove(profileId);
    await _saveToDisk();
  }

  static Map<String, Set<String>?> getAllSafeToSpendWallets() => Map.unmodifiable(_stsWallets);
  static Map<String, int> getAllBudgetCycleDays() => Map.unmodifiable(_cycleDays);
}
