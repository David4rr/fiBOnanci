import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized resolver for icons and colors of Indonesian & global brands/services.
class BrandAssetResolver {
  const BrandAssetResolver._();

  static IconData resolveIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('netflix') ||
        lower.contains('disney') ||
        lower.contains('prime') ||
        lower.contains('tv') ||
        lower.contains('hbo') ||
        lower.contains('youtube') ||
        lower.contains('cinema') ||
        lower.contains('vidio') ||
        lower.contains('iqiyi') ||
        lower.contains('wetv') ||
        lower.contains('viu') ||
        lower.contains('film')) {
      return Icons.tv_rounded;
    }
    if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('music') ||
        lower.contains('lagu') ||
        lower.contains('audio') ||
        lower.contains('joox') ||
        lower.contains('tidal') ||
        lower.contains('deezer') ||
        lower.contains('resso') ||
        lower.contains('soundcloud')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('indihome') ||
        lower.contains('biznet') ||
        lower.contains('first media') ||
        lower.contains('firstmedia') ||
        lower.contains('myrepublic') ||
        lower.contains('telkomsel') ||
        lower.contains('indosat') ||
        lower.contains('xl') ||
        lower.contains('smartfren') ||
        lower.contains('tri') ||
        lower.contains('pulsa') ||
        lower.contains('kuota') ||
        lower.contains('fiber')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('pln') ||
        lower.contains('listrik') ||
        lower.contains('token')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('pdam') || lower.contains('air')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('kost') ||
        lower.contains('kos') ||
        lower.contains('sewa') ||
        lower.contains('kontrakan') ||
        lower.contains('apartemen') ||
        lower.contains('rumah') ||
        lower.contains('ipl') ||
        lower.contains('kpr') ||
        lower.contains('cicilan')) {
      return Icons.home_work_rounded;
    }
    if (lower.contains('icloud') ||
        lower.contains('google') ||
        lower.contains('drive') ||
        lower.contains('dropbox') ||
        lower.contains('storage') ||
        lower.contains('notion') ||
        lower.contains('figma') ||
        lower.contains('adobe') ||
        lower.contains('canva') ||
        lower.contains('office') ||
        lower.contains('microsoft') ||
        lower.contains('cursor') ||
        lower.contains('chatgpt') ||
        lower.contains('openai') ||
        lower.contains('claude') ||
        lower.contains('github') ||
        lower.contains('cloud')) {
      return Icons.cloud_outlined;
    }
    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('f45') ||
        lower.contains('celebrity') ||
        lower.contains('gold') ||
        lower.contains('member') ||
        lower.contains('club')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('bpjs') ||
        lower.contains('asuransi') ||
        lower.contains('pajak') ||
        lower.contains('pbb')) {
      return Icons.health_and_safety_outlined;
    }
    return Icons.receipt_long_rounded;
  }

  static Color resolveColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('spotify') || lower.contains('music')) {
      return AppColors.neoMint;
    }
    if (lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('cloud')) {
      return AppColors.neoCyan;
    }
    if (lower.contains('pln') || lower.contains('listrik')) {
      return const Color(0xFFFFD166);
    }
    if (lower.contains('kost') || lower.contains('sewa')) {
      return AppColors.neoChartreuse;
    }
    return AppColors.neoCoral;
  }
}
