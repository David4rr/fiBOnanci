import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class InAppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime timestamp;
  final bool isRead;
  final String? payload;

  const InAppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.category = 'bill',
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'payload': payload,
  };

  factory InAppNotificationItem.fromJson(Map<String, dynamic> json) => InAppNotificationItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    category: json['category'] as String? ?? 'bill',
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    isRead: json['isRead'] as bool? ?? false,
    payload: json['payload'] as String?,
  );

  InAppNotificationItem copyWith({bool? isRead}) => InAppNotificationItem(
    id: id,
    title: title,
    body: body,
    category: category,
    timestamp: timestamp,
    isRead: isRead ?? this.isRead,
    payload: payload,
  );
}

class InAppNotificationStorage {
  static final List<InAppNotificationItem> _items = [];
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  static bool _isLoaded = false;
  static File? _customStorageFile;

  static List<InAppNotificationItem> get notifications => List.unmodifiable(_items);

  @visibleForTesting
  static void setStorageFile(File? file) {
    _customStorageFile = file;
    _isLoaded = false;
  }

  @visibleForTesting
  static void resetForTest() {
    _items.clear();
    unreadCountNotifier.value = 0;
    _isLoaded = false;
    _customStorageFile = null;
  }

  static Future<File?> _resolveFile() async {
    if (_customStorageFile != null) return _customStorageFile;
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(p.join(dir.path, 'in_app_notifications.json'));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveToDisk() async {
    try {
      final file = await _resolveFile();
      if (file == null) return;
      final raw = jsonEncode(_items.map((i) => i.toJson()).toList());
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        file.writeAsStringSync(raw, flush: true);
        return;
      }
      await file.writeAsString(raw, flush: true);
    } catch (_) {}
  }

  static Future<void> init() async {
    if (_isLoaded && _customStorageFile == null) return;
    try {
      final file = await _resolveFile();
      if (file != null && await file.exists()) {
        final content = Platform.environment.containsKey('FLUTTER_TEST')
            ? file.readAsStringSync()
            : await file.readAsString();
        if (content.trim().isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(content);
          _items.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _items.add(InAppNotificationItem.fromJson(item));
            } else if (item is Map) {
              _items.add(InAppNotificationItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
          _recalcUnread();
        }
      }
      _isLoaded = true;
    } catch (_) {}
  }

  static void _recalcUnread() {
    unreadCountNotifier.value = _items.where((i) => !i.isRead).length;
  }

  static Future<void> addNotification({
    required String title,
    required String body,
    String category = 'bill',
    String? payload,
    DateTime? timestamp,
  }) async {
    final item = InAppNotificationItem(
      id: '${DateTime.now().microsecondsSinceEpoch}_${title.hashCode.abs() % 10000}',
      title: title,
      body: body,
      category: category,
      timestamp: timestamp ?? DateTime.now(),
      isRead: false,
      payload: payload,
    );
    _items.insert(0, item);
    if (_items.length > 50) {
      _items.removeRange(50, _items.length);
    }
    _recalcUnread();
    await _saveToDisk();
  }

  static Future<void> markAsRead(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1 && !_items[idx].isRead) {
      _items[idx] = _items[idx].copyWith(isRead: true);
      _recalcUnread();
      await _saveToDisk();
    }
  }

  static Future<void> markAllAsRead() async {
    for (int i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    }
    _recalcUnread();
    await _saveToDisk();
  }

  static Future<void> deleteNotification(String id) async {
    _items.removeWhere((i) => i.id == id);
    _recalcUnread();
    await _saveToDisk();
  }

  static Future<void> clearAll() async {
    _items.clear();
    _recalcUnread();
    await _saveToDisk();
  }
}
