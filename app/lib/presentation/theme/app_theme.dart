import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/storage/profile_preferences_storage.dart';
import 'app_colors.dart';

ThemeMode parseAppThemeMode(String? raw) => switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
  parseAppThemeMode(ProfilePreferencesStorage.getThemeMode()),
);

typedef ThemeSwitchHandler = Future<void> Function(ThemeMode mode, {Offset? origin});
ThemeSwitchHandler? _revealHandler;

void registerThemeSwitchHandler(ThemeSwitchHandler? handler) {
  _revealHandler = handler;
}

void setAppThemeMode(ThemeMode mode, {Offset? origin}) {
  if (_revealHandler != null && origin != null) {
    _revealHandler!(mode, origin: origin);
    return;
  }
  themeModeNotifier.value = mode;
  ProfilePreferencesStorage.setThemeMode(mode.name);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0D11),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.neoChartreuse,
          surface: const Color(0xFF17181F),
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF17181F),
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF2A2C38), width: 1.0),
          ),
          insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          elevation: 4,
        ),
      );

  static ThemeData get lightTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1714),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.neoChartreuse,
          surface: const Color(0xFF2B211B),
          onSurface: const Color(0xFFFAF5EE),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2B211B),
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFFAF5EE),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF45362C), width: 1.0),
          ),
          insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          elevation: 4,
        ),
      );
}
