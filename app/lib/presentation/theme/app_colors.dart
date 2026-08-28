import 'package:flutter/material.dart';

class AppColors {
  // ===========================================================================
  // CANVAS & SURFACES (Deep Obsidian Matte)
  // ===========================================================================
  static const Color canvasBg = Color(0xFF0C0D11);
  static const Color canvasCardSurface = Color(0xFF17181F);
  static const Color canvasInputSearch = Color(0xFF1C1E26);
  static const Color canvasBorder = Color(0xFF2A2C38);
  static const Color canvasBorderSubtle = Color(0xFF1F2230);

  // ===========================================================================
  // VIBRANT NEO-PASTEL PALETTE (Card & Folder Accents)
  // ===========================================================================
  static const Color neoChartreuse = Color(0xFFD4F442); // Safe-to-Spend
  static const Color neoMint = Color(0xFF7DF24E);       // Total Real Balance
  static const Color neoCoral = Color(0xFFFF7052);      // Pending Monthly Bills
  static const Color neoCyan = Color(0xFF26D9D9);       // Daily Budget Allowance
  static const Color neoPurple = Color(0xFFA855F7);     // E-Wallet / OVO

  // ===========================================================================
  // TYPOGRAPHY & CONTRAST TOKENS
  // ===========================================================================
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E92A0);
  static const Color textSubtle = Color(0xFF525666);

  static const Color textDarkPrimary = Color(0xFF0A0B0E);
  static const Color textDarkSecondary = Color(0xFF2C303E);

  static const Color cardIconBadgeBg = Color(0x1F000000); // 12% Black overlay

  // ===========================================================================
  // FINANCIAL STATUS COLORS
  // ===========================================================================
  static const Color statusComfortable = neoChartreuse;
  static const Color statusCaution = Color(0xFFF59E0B);
  static const Color statusDeficit = Color(0xFFEF4444);
}
