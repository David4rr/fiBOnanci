import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'profile_settings_tab.dart';

class SettingsThemeSelector extends StatelessWidget {
  static final GlobalKey _buttonKey = GlobalKey();

  const SettingsThemeSelector({super.key});

  IconData _iconForMode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
      };

  String _labelForMode(ThemeMode mode, AppLocalizations l10n) => switch (mode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };

  ThemeMode _nextMode(ThemeMode current) => switch (current) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };

  Offset? _resolveOrigin() {
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(box.size.center(Offset.zero));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentMode, _) {
        final l10n = AppL10n.of(context);
        final icon = _iconForMode(currentMode);
        final label = _labelForMode(currentMode, l10n);
        final next = _nextMode(currentMode);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            HapticFeedback.lightImpact();
            final origin = _resolveOrigin() ?? details.globalPosition;
            setAppThemeMode(next, origin: origin);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.settingsThemeLabel, style: SettingsStyle.title),
                ),
                Text(
                  label,
                  style: SettingsStyle.value.copyWith(
                    color: currentMode == ThemeMode.system ? AppColors.textMuted : AppColors.textAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  key: _buttonKey,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceSubtle,
                    border: Border.all(color: AppColors.canvasBorder, width: 1.2),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween<double>(begin: -0.15, end: 0.0).animate(anim),
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: Icon(
                        icon,
                        key: const Key('theme_cycle_toggle_btn'),
                        color: AppColors.textAccent,
                        size: 18,
                      ),
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
