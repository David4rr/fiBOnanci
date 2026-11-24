import 'dart:async';
import 'package:flutter/services.dart';

class DownloadProgressInfo {
  final String status;
  final int bytesDownloaded;
  final int totalBytes;
  final double progress;

  const DownloadProgressInfo({
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.progress,
  });

  bool get isCompleted => status == 'successful' || progress >= 1.0;
  bool get isFailed => status == 'failed';
  bool get isRunning => status == 'running' || status == 'pending';

  String get formattedDownloaded => '${(bytesDownloaded / (1024 * 1024)).toStringAsFixed(1)} MB';
  String get formattedTotal => totalBytes > 0 ? '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB' : '';
  String get percentageText => '${(progress * 100).clamp(0, 100).toInt()}%';

  factory DownloadProgressInfo.fromMap(Map<dynamic, dynamic> map) {
    final status = map['status']?.toString() ?? 'unknown';
    final downloaded = (map['bytesDownloaded'] as num?)?.toInt() ?? 0;
    final total = (map['totalBytes'] as num?)?.toInt() ?? -1;
    final prog = (map['progress'] as num?)?.toDouble() ?? 0.0;
    return DownloadProgressInfo(
      status: status,
      bytesDownloaded: downloaded,
      totalBytes: total,
      progress: prog,
    );
  }
}

class AppUpdateDownloader {
  static const _channel = MethodChannel('com.fibonanci.app/notification_service');

  static Future<int> startDownload(String url, {String? fileName}) async {
    try {
      final res = await _channel.invokeMethod<int>('downloadApk', {
        'url': url,
        'fileName': fileName ?? 'fiBOnanci-update.apk',
      });
      return res ?? -1;
    } catch (_) {
      return -1;
    }
  }

  static Future<DownloadProgressInfo?> getProgress(int downloadId) async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getDownloadProgress', {
        'downloadId': downloadId,
      });
      if (res == null) return null;
      return DownloadProgressInfo.fromMap(res);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> install(int downloadId) async {
    try {
      return (await _channel.invokeMethod<bool>('installApk', {
        'downloadId': downloadId,
      })) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Stream<DownloadProgressInfo> trackProgress(int downloadId) async* {
    var isDone = false;
    while (!isDone) {
      final p = await getProgress(downloadId);
      if (p != null) {
        yield p;
        if (p.isCompleted || p.isFailed) {
          isDone = true;
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }
}
