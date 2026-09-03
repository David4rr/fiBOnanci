import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'bank_notification_parsers.dart';
import 'notification_blacklist.dart';
import 'parsed_notification.dart';
import 'semantic_notification_classifier.dart';

export 'parsed_notification.dart';

/// Orchestrates zero-latency on-device push notification parsing with
/// blacklist filtering, bank-specific rules, semantic classification,
/// and SHA-256 deduplication windows.
class NotificationParser {
  /// Main entry point: Parses incoming push notification on-device
  static ParsedNotificationResult? parse({
    required String packageName,
    required String title,
    required String body,
    DateTime? timestamp,
  }) {
    final combinedText = '$title $body'.trim();

    // Stage 1: Security & Marketing Hard-Drop
    if (NotificationBlacklist.isBlacklisted(combinedText)) {
      return null;
    }

    final pkg = packageName.toLowerCase();

    // Stage 2A: Specific Provider Parser
    ParsedNotificationResult? result = BankNotificationParsers.parseProvider(pkg, title, body);

    // Stage 2B: Universal Semantic Fallback Classifier
    result ??= SemanticNotificationClassifier.classify(
      title: title,
      body: body,
      parseIdr: BankNotificationParsers.parseIdr,
    );

    if (result == null) return null;

    // Stage 3: Deduplication Fingerprint computation
    final timeBucket = (timestamp ?? DateTime.now()).minute;
    final rawHash = '$packageName|${result.amount}|${result.counterparty}|$timeBucket';
    final refHash = sha256.convert(utf8.encode(rawHash)).toString().substring(0, 16);

    return ParsedNotificationResult(
      amount: result.amount,
      type: result.type,
      counterparty: result.counterparty,
      source: result.source,
      externalRef: refHash,
    );
  }
}
