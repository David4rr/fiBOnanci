import 'package:flutter/material.dart';

abstract class AppPalette {
  Color get canvasBg;
  Color get canvasCardSurface;
  Color get canvasInputSearch;
  Color get canvasBorder;
  Color get canvasBorderSubtle;
  Color get carbonBlack;

  Color get neoChartreuse;
  Color get neoMint;
  Color get neoCoral;
  Color get neoCyan;
  Color get neoPurple;

  Color get textPrimary;
  Color get textMuted;
  Color get textSubtle;
  Color get textDarkPrimary;
  Color get textDarkSecondary;
  Color get textIncome;
  Color get textAccent;
  Color get cardIconBadgeBg;

  Color get surfaceSubtle;
  Color get borderSubtle;
  Color get dividerSubtle;
  Color get pureWhite;

  Color get statusComfortable;
  Color get statusCaution;
  Color get statusDeficit;
}

class DarkAppPalette implements AppPalette {
  const DarkAppPalette();

  @override
  Color get canvasBg => const Color(0xFF0C0D11);
  @override
  Color get canvasCardSurface => const Color(0xFF17181F);
  @override
  Color get canvasInputSearch => const Color(0xFF1C1E26);
  @override
  Color get canvasBorder => const Color(0xFF2A2C38);
  @override
  Color get canvasBorderSubtle => const Color(0xFF1F2230);
  @override
  Color get carbonBlack => const Color(0xFF0C0A00);

  @override
  Color get neoChartreuse => const Color(0xFFD4F442);
  @override
  Color get neoMint => const Color(0xFF7DF24E);
  @override
  Color get neoCoral => const Color(0xFFFF7052);
  @override
  Color get neoCyan => const Color(0xFF26D9D9);
  @override
  Color get neoPurple => const Color(0xFFA855F7);

  @override
  Color get textPrimary => const Color(0xFFFFFFFF);
  @override
  Color get textMuted => const Color(0xFFA6ABB9);
  @override
  Color get textSubtle => const Color(0xFF7A8094);
  @override
  Color get textDarkPrimary => const Color(0xFF0A0B0E);
  @override
  Color get textDarkSecondary => const Color(0xFF2C303E);
  @override
  Color get textIncome => const Color(0xFF7DF24E);
  @override
  Color get textAccent => const Color(0xFFD4F442);
  @override
  Color get cardIconBadgeBg => const Color(0x1F000000);

  @override
  Color get surfaceSubtle => const Color(0x0AFFFFFF);
  @override
  Color get borderSubtle => const Color(0x14FFFFFF);
  @override
  Color get dividerSubtle => const Color(0x0FFFFFFF);
  @override
  Color get pureWhite => const Color(0xFFFFFFFF);

  @override
  Color get statusComfortable => neoChartreuse;
  @override
  Color get statusCaution => const Color(0xFFF59E0B);
  @override
  Color get statusDeficit => const Color(0xFFEF4444);
}

class LightAppPalette implements AppPalette {
  const LightAppPalette();

  @override
  Color get canvasBg => const Color(0xFF1E1714);
  @override
  Color get canvasCardSurface => const Color(0xFF2B211B);
  @override
  Color get canvasInputSearch => const Color(0xFF382C24);
  @override
  Color get canvasBorder => const Color(0xFF45362C);
  @override
  Color get canvasBorderSubtle => const Color(0xFF352A22);
  @override
  Color get carbonBlack => const Color(0xFF120E0C);

  @override
  Color get neoChartreuse => const Color(0xFFD4F442);
  @override
  Color get neoMint => const Color(0xFF7DF24E);
  @override
  Color get neoCoral => const Color(0xFFFF7052);
  @override
  Color get neoCyan => const Color(0xFF26D9D9);
  @override
  Color get neoPurple => const Color(0xFFA855F7);

  @override
  Color get textPrimary => const Color(0xFFFAF5EE);
  @override
  Color get textMuted => const Color(0xFFBFB1A3);
  @override
  Color get textSubtle => const Color(0xFF8C7E71);
  @override
  Color get textDarkPrimary => const Color(0xFF0A0B0E);
  @override
  Color get textDarkSecondary => const Color(0xFF2C303E);
  @override
  Color get textIncome => const Color(0xFF7DF24E);
  @override
  Color get textAccent => const Color(0xFFD4F442);
  @override
  Color get cardIconBadgeBg => const Color(0x28000000);

  @override
  Color get surfaceSubtle => const Color(0x14FFFFFF);
  @override
  Color get borderSubtle => const Color(0x24FFFFFF);
  @override
  Color get dividerSubtle => const Color(0x1AFFFFFF);
  @override
  Color get pureWhite => const Color(0xFFFFFFFF);

  @override
  Color get statusComfortable => const Color(0xFFD4F442);
  @override
  Color get statusCaution => const Color(0xFFF59E0B);
  @override
  Color get statusDeficit => const Color(0xFFEF4444);
}
