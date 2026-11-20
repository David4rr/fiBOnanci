import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../native_bridge/notification_bridge.dart';

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseNotes;
  final String? apkUrl;
  final String htmlUrl;
  final DateTime? publishedAt;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseNotes,
    this.apkUrl,
    required this.htmlUrl,
    this.publishedAt,
  });
}

class AppUpdateService {
  static const String currentVersion = '1.0.4';
  static const String repoOwner = 'David4rr';
  static const String repoName = 'fiBOnanci';
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  static bool isNewerVersion(String latest, String current) {
    try {
      final cleanLatest = latest.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanCurrent = current.replaceAll(RegExp(r'[^0-9.]'), '');
      final latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = latestParts.length > currentParts.length ? latestParts.length : currentParts.length;
      for (var i = 0; i < maxLen; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<AppUpdateInfo?> checkForUpdate({
    HttpClient? client,
    String? targetAbi,
  }) async {
    if (kIsWeb) return null;
    if (Platform.environment.containsKey('FLUTTER_TEST') && client == null) {
      return null;
    }

    final httpClient = client ?? HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 5);

    try {
      final request = await httpClient.getUrl(Uri.parse(apiUrl));
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      request.headers.set('User-Agent', 'fiBOnanci-App');

      final response = await request.close().timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(body);

      final tagName = (json['tag_name'] as String? ?? '').replaceAll('v', '').trim();
      final htmlUrl = json['html_url'] as String? ?? 'https://github.com/$repoOwner/$repoName/releases';
      final releaseNotes = json['body'] as String? ?? 'Pembaruan stabilitas dan peningkatan performa.';
      final publishedAtStr = json['published_at'] as String?;
      final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      String? apkUrl;
      final assets = json['assets'] as List<dynamic>?;
      if (assets != null) {
        final resolvedAbi = targetAbi ?? (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST') ? null : await NotificationBridge.getDeviceAbi());
        final abi = (resolvedAbi ?? '').toLowerCase().trim();
        String? abiMatch;
        String? universalMatch;
        String? fallbackMatch;

        for (final asset in assets) {
          if (asset is Map<String, dynamic>) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            final downloadUrl = asset['browser_download_url'] as String?;
            if (name.endsWith('.apk') && downloadUrl != null) {
              if (abi.isNotEmpty && name.contains(abi)) {
                abiMatch = downloadUrl;
              } else if (name.contains('universal')) {
                universalMatch = downloadUrl;
              } else {
                fallbackMatch ??= downloadUrl;
              }
            }
          }
        }
        apkUrl = abiMatch ?? universalMatch ?? fallbackMatch;
      }

      final hasUpdate = isNewerVersion(tagName, currentVersion);

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: tagName.isNotEmpty ? tagName : currentVersion,
        hasUpdate: hasUpdate,
        releaseNotes: releaseNotes,
        apkUrl: apkUrl ?? htmlUrl,
        htmlUrl: htmlUrl,
        publishedAt: publishedAt,
      );
    } catch (_) {
      return null;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
