import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import 'contactless_painter.dart';

class WalletCardAtmComponents {
  static String formatAccountNumber(WalletEntry wallet) {
    final num = wallet.accountNumber?.trim();
    if (num == null || num.isEmpty) {
      return '-';
    }
    return num;
  }

  static Widget buildChip(Color textColor, bool isDark) {
    final chipBaseColor = isDark
        ? const Color(0xFFD4AF37).withValues(alpha: 0.22)
        : textColor.withValues(alpha: 0.12);
    final chipBorderColor = isDark
        ? const Color(0xFFFFDF73).withValues(alpha: 0.45)
        : textColor.withValues(alpha: 0.32);
    final circuitColor = isDark
        ? const Color(0xFFFFDF73).withValues(alpha: 0.35)
        : textColor.withValues(alpha: 0.24);

    return Container(
      width: 36,
      height: 27,
      decoration: BoxDecoration(
        color: chipBaseColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: chipBorderColor,
          width: 0.9,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 22,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: circuitColor,
                width: 0.7,
              ),
            ),
          ),
          Container(width: 0.8, height: 16, color: circuitColor),
          Container(width: 22, height: 0.8, color: circuitColor),
        ],
      ),
    );
  }

  static Widget buildContactlessIcon(Color color) {
    return CustomPaint(
      size: const Size(16, 12),
      painter: ContactlessPainter(color: color.withValues(alpha: 0.85)),
    );
  }
}
