import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'modernist_card_theme.dart';
import 'wallet_card_atm_components.dart';

class WalletCardRows {
  static Widget buildNetworkBadge(String text, ModernistCardConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: config.textColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: config.backgroundColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  static Widget buildHeaderRow(String walletName, String badgeText, ModernistCardConfig config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            walletName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: config.textColor,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        buildNetworkBadge(badgeText, config),
      ],
    );
  }

  static Widget buildPeekBalanceRow(double balance, NumberFormat fmt, ModernistCardConfig config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'SALDO TERSEDIA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: config.textColor.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            fmt.format(balance),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: config.textColor,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  static Widget buildBottomRow({
    required double balance,
    required NumberFormat fmt,
    required String accountNumberDisplay,
    required ModernistCardConfig config,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  fmt.format(balance),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: config.textColor,
                    letterSpacing: -0.8,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Saldo Tersedia',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: config.textColor.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            WalletCardAtmComponents.buildContactlessIcon(config.textColor),
            const SizedBox(height: 5),
            Text(
              accountNumberDisplay,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: config.textColor.withValues(alpha: 0.75),
                letterSpacing: accountNumberDisplay == '-' ? 0.0 : 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
