import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'smart_transaction_draft.dart';

/// Platform bridge for 100% on-device offline Voice Speech-to-Text and
/// Photo Receipt/Transfer Proof OCR via Android SpeechRecognizer & Google ML Kit.
class SmartInputBridge {
  static const MethodChannel _channel = MethodChannel('com.fibonanci.app/smart_input');
  static final ImagePicker _picker = ImagePicker();

  /// Injectable overrides for deterministic widget & integration testing.
  static Future<String?> Function()? testVoiceOverride;
  static Future<String?> Function(SmartInputSource source)? testPhotoOcrOverride;

  static void Function(Map<String, dynamic> event)? _speechListener;
  static bool _handlerRegistered = false;

  static void _ensureHandler() {
    if (_handlerRegistered) return;
    _handlerRegistered = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSpeechEvent' && call.arguments is Map) {
        final map = Map<String, dynamic>.from(call.arguments as Map);
        _speechListener?.call(map);
      }
    });
  }

  static Future<String> startHeadlessListening({
    required void Function(Map<String, dynamic> event) onEvent,
    String locale = 'id-ID',
  }) async {
    _ensureHandler();
    _speechListener = onEvent;
    try {
      final status = await _channel.invokeMethod<String>(
        'startListening',
        {'locale': locale},
      );
      return status ?? 'UNAVAILABLE';
    } on PlatformException {
      return 'UNAVAILABLE';
    } on MissingPluginException {
      return 'UNAVAILABLE';
    }
  }

  static Future<void> stopHeadlessListening() async {
    try {
      await _channel.invokeMethod<void>('stopListening');
    } catch (_) {}
  }

  static Future<void> cancelHeadlessListening() async {
    _speechListener = null;
    try {
      await _channel.invokeMethod<void>('cancelListening');
    } catch (_) {}
  }

  /// Captures a photo via Camera or selects from Gallery, then runs on-device ML Kit OCR.
  /// Returns `(ocrText, canceled)` where `canceled` is true if the user dismissed the picker.
  static Future<({String? ocrText, bool canceled})> capturePhotoAndExtractText({
    required bool fromCamera,
  }) async {
    final source = fromCamera ? SmartInputSource.camera : SmartInputSource.gallery;
    if (testPhotoOcrOverride != null) {
      final text = await testPhotoOcrOverride!(source);
      return (ocrText: text, canceled: text == null);
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) {
        return (ocrText: null, canceled: true);
      }

      final recognizedText = await _channel.invokeMethod<String>(
        'recognizeImageText',
        {'path': image.path},
      );
      final trimmed = recognizedText?.trim();
      return (
        ocrText: (trimmed != null && trimmed.isNotEmpty) ? trimmed : null,
        canceled: false,
      );
    } on PlatformException {
      return (ocrText: null, canceled: false);
    } on MissingPluginException {
      return (ocrText: null, canceled: false);
    }
  }
}
