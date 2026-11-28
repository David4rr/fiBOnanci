import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../l10n/app_localizations_id.dart';
import '../storage/profile_preferences_storage.dart';

Locale parseAppLocale(String? code) =>
    code == 'en' ? const Locale('en') : const Locale('id');

final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
  parseAppLocale(ProfilePreferencesStorage.getLocaleCode()),
);

void setAppLocale(Locale locale) {
  final code = locale.languageCode == 'en' ? 'en' : 'id';
  localeNotifier.value = Locale(code);
  ProfilePreferencesStorage.setLocaleCode(code);
}

class AppL10n {
  static AppLocalizations get current =>
      localeNotifier.value.languageCode == 'en'
          ? AppLocalizationsEn()
          : AppLocalizationsId();

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context) ?? current;
  }
}
