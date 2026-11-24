import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/update/changelog_formatter.dart';
import '../../theme/app_colors.dart';

class UserFriendlyChangelogView extends StatelessWidget {
  final String? releaseNotes;
  final bool isCompact;

  const UserFriendlyChangelogView({
    super.key,
    this.releaseNotes,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ChangelogFormatter.parse(releaseNotes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: categories.map((cat) => _buildCategory(cat)).toList(),
    );
  }

  Widget _buildCategory(ChangelogCategory cat) {
    final (badgeColor, icon) = switch (cat.type) {
      ChangelogType.feature => (AppColors.neoChartreuse, Icons.auto_awesome_rounded),
      ChangelogType.improvement => (AppColors.neoCyan, Icons.bolt_rounded),
      ChangelogType.fix => (AppColors.neoCoral, Icons.check_circle_outline_rounded),
      ChangelogType.other => (AppColors.textMuted, Icons.notes_rounded),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: badgeColor),
                const SizedBox(width: 4),
                Text(
                  cat.type.title.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...cat.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: badgeColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isCompact ? 12 : 12.5,
                          height: 1.4,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
