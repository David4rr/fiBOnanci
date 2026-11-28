import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import 'settings_style.dart';

class SettingsLanguageSelector extends StatelessWidget {
  const SettingsLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';
        return GestureDetector(
          key: const Key('settings_language_toggle'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            setAppLocale(Locale(isEnglish ? 'id' : 'en'));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.settingsLanguageLabel, style: SettingsStyle.title),
                ),
                Text(
                  l10n.settingsLanguageName,
                  style: SettingsStyle.value.copyWith(
                    color: AppColors.textAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.canvasBorder),
                  ),
                  child: Text(
                    isEnglish ? 'EN' : 'ID',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
