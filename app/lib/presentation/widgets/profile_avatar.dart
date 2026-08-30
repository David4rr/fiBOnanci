import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AvatarPreset {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgTint;

  const AvatarPreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgTint,
  });
}

class ProfileAvatarPresets {
  static const List<AvatarPreset> presets = [
    AvatarPreset(
      id: 'preset:avatar_1',
      label: 'Tech',
      icon: Icons.terminal_rounded,
      color: AppColors.neoMint,
      bgTint: Color(0xFF142B1F),
    ),
    AvatarPreset(
      id: 'preset:avatar_2',
      label: 'Eksekutif',
      icon: Icons.business_center_rounded,
      color: AppColors.neoCyan,
      bgTint: Color(0xFF122838),
    ),
    AvatarPreset(
      id: 'preset:avatar_3',
      label: 'Finansial',
      icon: Icons.trending_up_rounded,
      color: AppColors.neoChartreuse,
      bgTint: Color(0xFF262C10),
    ),
    AvatarPreset(
      id: 'preset:avatar_4',
      label: 'Kreatif',
      icon: Icons.palette_rounded,
      color: AppColors.neoCoral,
      bgTint: Color(0xFF331B17),
    ),
    AvatarPreset(
      id: 'preset:avatar_5',
      label: 'Zen',
      icon: Icons.spa_rounded,
      color: Color(0xFF10B981),
      bgTint: Color(0xFF0F2D20),
    ),
    AvatarPreset(
      id: 'preset:avatar_6',
      label: 'Petualang',
      icon: Icons.explore_rounded,
      color: Color(0xFFFBBF24),
      bgTint: Color(0xFF2E240D),
    ),
    AvatarPreset(
      id: 'preset:avatar_7',
      label: 'Gamer',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFFA78BFA),
      bgTint: Color(0xFF26193E),
    ),
    AvatarPreset(
      id: 'preset:avatar_8',
      label: 'Klasik',
      icon: Icons.person_rounded,
      color: AppColors.textWhite,
      bgTint: Color(0xFF1E212D),
    ),
  ];

  static AvatarPreset getById(String? id) {
    if (id == null) return presets.first;
    return presets.firstWhere(
      (p) => p.id == id,
      orElse: () => presets.first,
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String? avatarPath;
  final String name;
  final double size;
  final Border? border;
  final double iconSize;

  const ProfileAvatar({
    super.key,
    this.avatarPath,
    required this.name,
    this.size = 42,
    this.border,
    double? iconSize,
  }) : iconSize = iconSize ?? size * 0.5;

  @override
  Widget build(BuildContext context) {
    // 1. Check if avatarPath points to an existing local file
    if (avatarPath != null &&
        !avatarPath!.startsWith('preset:') &&
        avatarPath!.isNotEmpty) {
      final file = File(avatarPath!);
      if (file.existsSync()) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border ??
                Border.all(
                  color: AppColors.canvasBorder,
                  width: 1.5,
                ),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    // 2. Preset avatar
    final isPreset = avatarPath != null && avatarPath!.startsWith('preset:');
    final preset = ProfileAvatarPresets.getById(avatarPath);

    if (isPreset) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: preset.bgTint,
          border: border ??
              Border.all(
                color: preset.color.withValues(alpha: 0.5),
                width: 1.5,
              ),
        ),
        child: Center(
          child: Icon(
            preset.icon,
            color: preset.color,
            size: iconSize,
          ),
        ),
      );
    }

    // 3. Fallback: initials or default person icon
    final cleanName = name.trim();
    final initials = cleanName.isNotEmpty
        ? cleanName.substring(0, cleanName.length >= 2 ? 2 : 1).toUpperCase()
        : 'FI';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E212D),
        border: border ??
            Border.all(
              color: AppColors.canvasBorder,
              width: 1.5,
            ),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.neoChartreuse,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}
