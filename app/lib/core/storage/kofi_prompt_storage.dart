import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persistent frequency-capping storage for the non-intrusive Ko-fi support prompt.
class KofiPromptStorage {
  static const String kofiUrl = 'https://ko-fi.com/david4rr';
  static const int minOpensBeforePrompt = 3;
  static const int snoozeDays = 14;

  static int _openCount = 0;
  static bool _dismissedPermanently = false;
  static int? _snoozedUntilMs;
  static bool _isLoaded = false;
  static File? _customFile;

  @visibleForTesting
  static void setStorageFile(File? file) {
    _customFile = file;
    _resetValues();
  }

  @visibleForTesting
  static void resetForTest() {
    _customFile = null;
    _resetValues();
  }

  static void _resetValues() {
    _isLoaded = false;
    _openCount = 0;
    _dismissedPermanently = false;
    _snoozedUntilMs = null;
  }

  static Future<File?> _resolveFile() async {
    if (_customFile != null) return _customFile;
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(p.join(dir.path, 'kofi_prompt_state.json'));
    } catch (_) {
      return null;
    }
  }

  static Future<void> load() async {
    if (_isLoaded && _customFile == null) return;
    try {
      final file = await _resolveFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(content);
          if (data['open_count'] is int) _openCount = data['open_count'] as int;
          if (data['dismissed_permanently'] is bool) {
            _dismissedPermanently = data['dismissed_permanently'] as bool;
          }
          if (data['snoozed_until_ms'] is int) {
            _snoozedUntilMs = data['snoozed_until_ms'] as int;
          }
        }
      }
      _isLoaded = true;
    } catch (_) {}
  }

  static Future<void> _save() async {
    try {
      final file = await _resolveFile();
      if (file == null) return;
      await file.writeAsString(
        jsonEncode({
          'open_count': _openCount,
          'dismissed_permanently': _dismissedPermanently,
          'snoozed_until_ms': _snoozedUntilMs,
        }),
        flush: true,
      );
    } catch (_) {}
  }

  static Future<void> recordAppOpen() async {
    await load();
    _openCount++;
    await _save();
  }

  static bool shouldShowPrompt({DateTime? now}) {
    if (_dismissedPermanently) return false;
    if (_openCount < minOpensBeforePrompt) return false;
    final currentMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
    if (_snoozedUntilMs != null && currentMs < _snoozedUntilMs!) return false;
    return true;
  }

  static Future<void> snooze({DateTime? now, int days = snoozeDays}) async {
    await load();
    final target = (now ?? DateTime.now()).add(Duration(days: days));
    _snoozedUntilMs = target.millisecondsSinceEpoch;
    await _save();
  }

  static Future<void> markSupportedOrDismissed() async {
    await load();
    _dismissedPermanently = true;
    await _save();
  }
}
