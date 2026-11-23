import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tactile_toast_card.dart';

export 'tactile_toast_card.dart' show AppSnackBarType, TactileToastCard;

/// Centralized tactile toast & snackbar dispatcher with Obsidian aesthetic.
class AppSnackBar {
  static void showSuccess(
    BuildContext context,
    String title, {
    String? message,
    String? tag,
    Duration duration = const Duration(milliseconds: 2400),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      title: title,
      message: message,
      tag: tag ?? 'SUKSES',
      type: AppSnackBarType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showError(
    BuildContext context,
    String title, {
    String? message,
    String? tag,
    Duration duration = const Duration(milliseconds: 2600),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      title: title,
      message: message,
      tag: tag ?? 'HAPUS',
      type: AppSnackBarType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showWarning(
    BuildContext context,
    String title, {
    String? message,
    String? tag,
    Duration duration = const Duration(milliseconds: 2600),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      title: title,
      message: message,
      tag: tag ?? 'PERHATIAN',
      type: AppSnackBarType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    BuildContext context,
    String title, {
    String? message,
    String? tag,
    Duration duration = const Duration(milliseconds: 2200),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      title: title,
      message: message,
      tag: tag ?? 'INFO',
      type: AppSnackBarType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    String? message,
    String? tag,
    IconData? icon,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(milliseconds: 2400),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    showWithMessenger(
      messenger,
      title: title,
      message: message,
      tag: tag,
      icon: icon,
      type: type,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showWithMessenger(
    ScaffoldMessengerState messenger, {
    required String title,
    String? message,
    String? tag,
    IconData? icon,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(milliseconds: 2400),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    HapticFeedback.lightImpact();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: EdgeInsets.zero,
        duration: duration,
        content: TactileToastCard(
          title: title,
          message: message,
          tag: tag,
          icon: icon,
          type: type,
          onAction: onAction,
          actionLabel: actionLabel,
        ),
      ),
    );
  }
}
