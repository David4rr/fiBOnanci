import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class SettingsStyle {
  static TextStyle get title => GoogleFonts.plusJakartaSans(
        fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      );
  static TextStyle get sub => GoogleFonts.plusJakartaSans(
        fontSize: 11.5, fontWeight: FontWeight.w400, color: AppColors.textMuted,
      );
  static TextStyle get value => GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  static TextStyle get accent => GoogleFonts.plusJakartaSans(
        fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textAccent,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static Widget sectionHeader(String text, {Color? color}) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5, fontWeight: FontWeight.w700,
          color: color ?? AppColors.textSubtle,
          letterSpacing: 1.0,
        ),
      );

  static Widget hairline([double vertical = 0]) => SizedBox(height: vertical);

  static Widget segmentedTrack({required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
        child: Row(children: children),
      );

  static Widget switchRow({
    required Key switchKey,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: SettingsStyle.title),
            Transform.scale(
              scale: 0.85,
              alignment: Alignment.centerRight,
              child: Switch.adaptive(
                key: switchKey,
                value: value,
                activeTrackColor: AppColors.neoChartreuse,
                activeThumbColor: AppColors.pureWhite,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );

  static Widget menuRow({
    Key? key,
    required String title,
    required String valueText,
    required VoidCallback onTap,
    Color? titleColor,
    Color? valueColor,
    Widget? trailingAction,
  }) =>
      GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(child: Text(title, style: SettingsStyle.title.copyWith(color: titleColor))),
              if (trailingAction != null) ...[trailingAction, const SizedBox(width: 10)],
              Text(valueText, style: value.copyWith(color: valueColor)),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: valueColor ?? AppColors.textSubtle,
              ),
            ],
          ),
        ),
      );

  static Widget optionRow({
    Key? key,
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SettingsStyle.title.copyWith(
                        color: selected ? AppColors.textWhite : AppColors.textMuted,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: sub)],
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_rounded, size: 18, color: AppColors.textAccent),
            ],
          ),
        ),
      );

  static Widget flatChip({
    Key? key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.canvasCardSurface : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.canvasBorder : Colors.transparent, width: 0.8),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.textWhite : AppColors.textMuted,
            ),
          ),
        ),
      );
}
