import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'modernist_card_painter.dart';
export 'modernist_card_painter.dart' show ModernistCardTheme, ModernistCardConfig;
import '../../data/database/app_database.dart';

/// Helper data class for card styling
class _CardThemeConfig {
  final Color backgroundColor;
  final Color primaryGraphicColor;
  final Color secondaryGraphicColor;
  final Color textColor;
  final Color badgeColor;
  final String networkBadgeText;
  final _CardBadgeType badgeType;

  const _CardThemeConfig({
    required this.backgroundColor,
    required this.primaryGraphicColor,
    required this.secondaryGraphicColor,
    required this.textColor,
    required this.badgeColor,
    required this.networkBadgeText,
    required this.badgeType,
  });
}

enum _CardBadgeType { mastercard, jcb, gpay, amex, chip, diners }

/// Tactile Swiss-editorial ATM-style Subscription Card strictly matching ref1.jpg.
class SubscriptionCard extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry? wallet;
  final VoidCallback? onTap;
  final int? indexOverride;
  final bool isFocused;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.wallet,
    this.onTap,
    this.indexOverride,
    this.isFocused = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPaidThisMonth = subscription.lastPaidDate != null &&
        subscription.lastPaidDate!.year == now.year &&
        subscription.lastPaidDate!.month == now.month;

    final theme = _resolveCardTheme(subscription.title, indexOverride ?? subscription.title.hashCode);
    final config = _getThemeConfig(theme);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final maskedNumber = _generateMaskedNumber(subscription, wallet);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 215.0,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Geometric Modernist Painter
            Positioned.fill(
              child: CustomPaint(
                painter: ModernistCardPainter(
                  theme: theme,
                  primaryColor: config.primaryGraphicColor,
                  secondaryColor: config.secondaryGraphicColor,
                ),
              ),
            ),

            // Card Foreground Content
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Title / Type & Network Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: config.textColor,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              wallet?.name.toUpperCase() ?? 'KARTU OPERASIONAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: config.textColor.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildNetworkBadge(config),
                    ],
                  ),

                  // Middle: High-Contrast Tactile Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(isPaidThisMonth, subscription.dueDay, config),
                    ],
                  ),

                  // Bottom Row: Large Amount (Left) & Masked Number with Contactless Icon (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(subscription.cost),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: config.textColor,
                              letterSpacing: -0.8,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subscription.billingCycle == 'monthly' ? '/bulan' : '/tahun',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: config.textColor.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),

                      // Contactless Icon & Masked Card Number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildContactlessIcon(config.textColor),
                          const SizedBox(height: 6),
                          Text(
                            maskedNumber,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: config.textColor.withValues(alpha: 0.75),
                              letterSpacing: 1.2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid, int dueDay, _CardThemeConfig config) {
    final now = DateTime.now();
    final today = now.day;

    Color badgeBg;
    Color dotColor;
    Color textColor;
    String statusText;

    final isDarkBg = config.backgroundColor.computeLuminance() < 0.35;

    if (isPaid) {
      if (isDarkBg) {
        badgeBg = const Color(0xFF064E3B).withValues(alpha: 0.85);
        dotColor = const Color(0xFF34D399);
        textColor = const Color(0xFF34D399);
      } else {
        badgeBg = const Color(0xFF0F172A).withValues(alpha: 0.9);
        dotColor = const Color(0xFF10B981);
        textColor = const Color(0xFF10B981);
      }
      statusText = 'LUNAS BULAN INI';
    } else if (today == dueDay) {
      badgeBg = const Color(0xFFDC2626);
      dotColor = Colors.white;
      textColor = Colors.white;
      statusText = 'JATUH TEMPO HARI INI';
    } else if (today < dueDay && (dueDay - today) <= 3) {
      final diff = dueDay - today;
      badgeBg = const Color(0xFF0F172A).withValues(alpha: 0.9);
      dotColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFFBBF24);
      statusText = 'JATUH TEMPO H-$diff';
    } else {
      if (isDarkBg) {
        badgeBg = Colors.black.withValues(alpha: 0.35);
        dotColor = Colors.white.withValues(alpha: 0.8);
        textColor = Colors.white.withValues(alpha: 0.9);
      } else {
        badgeBg = const Color(0xFF0F172A).withValues(alpha: 0.85);
        dotColor = config.backgroundColor;
        textColor = Colors.white;
      }
      statusText = 'JATUH TEMPO TGL $dueDay';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPaid
              ? (isDarkBg ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.transparent)
              : Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkBadge(_CardThemeConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: config.textColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        config.networkBadgeText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: config.backgroundColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildContactlessIcon(Color color) {
    return CustomPaint(
      size: const Size(16, 12),
      painter: ContactlessPainter(color: color.withValues(alpha: 0.85)),
    );
  }

  String _generateMaskedNumber(SubscriptionEntry sub, WalletEntry? wallet) {
    final seed = (sub.id.hashCode).abs();
    final firstPart = (1000 + (seed % 9000)).toString();
    final lastPart = (1000 + ((seed ~/ 10) % 9000)).toString();
    return '$firstPart ...... $lastPart';
  }

  ModernistCardTheme _resolveCardTheme(String title, int seed) {
    final lower = title.toLowerCase();

    // 1. Streaming & Entertainment
    if (lower.contains('netflix') ||
        lower.contains('disney') ||
        lower.contains('hbo') ||
        lower.contains('vidio') ||
        lower.contains('prime') ||
        lower.contains('youtube') ||
        lower.contains('cinema') ||
        lower.contains('tv') ||
        lower.contains('iqiyi') ||
        lower.contains('wetv') ||
        lower.contains('viu') ||
        lower.contains('film')) {
      return ModernistCardTheme.streamingCinematic;
    }

    // 2. Audio & Music Streaming
    if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('joox') ||
        lower.contains('tidal') ||
        lower.contains('deezer') ||
        lower.contains('resso') ||
        lower.contains('soundcloud') ||
        lower.contains('music') ||
        lower.contains('lagu') ||
        lower.contains('audio')) {
      return ModernistCardTheme.audioEmerald;
    }

    // 3. Utilities / Bills (Listrik, Air, BPJS, Pajak)
    if (lower.contains('pln') ||
        lower.contains('listrik') ||
        lower.contains('token') ||
        lower.contains('pdam') ||
        lower.contains('air') ||
        lower.contains('bpjs') ||
        lower.contains('pajak') ||
        lower.contains('pbb') ||
        lower.contains('gas') ||
        lower.contains('utility')) {
      return ModernistCardTheme.utilitiesLemon;
    }

    // 4. Fiber Internet & Telco
    if (lower.contains('indihome') ||
        lower.contains('biznet') ||
        lower.contains('myrepublic') ||
        lower.contains('firstmedia') ||
        lower.contains('telkomsel') ||
        lower.contains('indosat') ||
        lower.contains('xl') ||
        lower.contains('smartfren') ||
        lower.contains('tri') ||
        lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('pulsa') ||
        lower.contains('kuota') ||
        lower.contains('fiber')) {
      return ModernistCardTheme.fiberInternet;
    }

    // 5. Productivity, AI & Cloud
    if (lower.contains('chatgpt') ||
        lower.contains('openai') ||
        lower.contains('claude') ||
        lower.contains('github') ||
        lower.contains('icloud') ||
        lower.contains('google') ||
        lower.contains('drive') ||
        lower.contains('dropbox') ||
        lower.contains('notion') ||
        lower.contains('figma') ||
        lower.contains('adobe') ||
        lower.contains('canva') ||
        lower.contains('office') ||
        lower.contains('microsoft') ||
        lower.contains('cursor') ||
        lower.contains('cloud') ||
        lower.contains('apple')) {
      return ModernistCardTheme.aiCloudProductivity;
    }

    // 6. Housing, Kost, Rent & Living
    if (lower.contains('kost') ||
        lower.contains('kos') ||
        lower.contains('kontrakan') ||
        lower.contains('sewa') ||
        lower.contains('apartemen') ||
        lower.contains('ipl') ||
        lower.contains('kpr') ||
        lower.contains('cicilan') ||
        lower.contains('leasing') ||
        lower.contains('rumah')) {
      return ModernistCardTheme.housingLiving;
    }

    // 7. Fitness & Lifestyle
    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('celebrity') ||
        lower.contains('gold') ||
        lower.contains('f45') ||
        lower.contains('club') ||
        lower.contains('member') ||
        lower.contains('sehat')) {
      return ModernistCardTheme.fitnessLifestyle;
    }

    // Dynamic rotation based on hash seed
    final themes = ModernistCardTheme.values;
    return themes[seed.abs() % themes.length];
  }

  _CardThemeConfig _getThemeConfig(ModernistCardTheme theme) {
    switch (theme) {
      case ModernistCardTheme.streamingCinematic:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF1E1418), // Cinematic dark obsidian crimson
          primaryGraphicColor: Color(0xFFE50914), // Netflix red arc
          secondaryGraphicColor: Color(0xFFFF5252),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFE50914),
          networkBadgeText: 'STREAMING',
          badgeType: _CardBadgeType.mastercard,
        );
      case ModernistCardTheme.audioEmerald:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF7CB88D), // Emerald sage
          primaryGraphicColor: Color(0xFF183820),
          secondaryGraphicColor: Color(0xFF67A578),
          textColor: Color(0xFF0F2615),
          badgeColor: Color(0xFF0F2615),
          networkBadgeText: 'AUDIO',
          badgeType: _CardBadgeType.jcb,
        );
      case ModernistCardTheme.utilitiesLemon:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFF3F76E), // Acid neon lemon
          primaryGraphicColor: Color(0xFFE2E658),
          secondaryGraphicColor: Color(0xFF20221A),
          textColor: Color(0xFF1A1C16),
          badgeColor: Color(0xFF1A1C16),
          networkBadgeText: 'UTILITY',
          badgeType: _CardBadgeType.chip,
        );
      case ModernistCardTheme.fiberInternet:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF9EACF0), // Periwinkle fiber
          primaryGraphicColor: Color(0xFF1E2856),
          secondaryGraphicColor: Color(0xFF8697E6),
          textColor: Color(0xFF151C3E),
          badgeColor: Color(0xFF151C3E),
          networkBadgeText: 'INTERNET',
          badgeType: _CardBadgeType.diners,
        );
      case ModernistCardTheme.aiCloudProductivity:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFE5E3DC), // Bone warm grey
          primaryGraphicColor: Color(0xFFE84E38), // Terracotta
          secondaryGraphicColor: Color(0xFFE84E38),
          textColor: Color(0xFF181A1E),
          badgeColor: Color(0xFF181A1E),
          networkBadgeText: 'PRO CLOUD',
          badgeType: _CardBadgeType.mastercard,
        );
      case ModernistCardTheme.housingLiving:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF56626A), // Slate charcoal
          primaryGraphicColor: Color(0xFF455057),
          secondaryGraphicColor: Color(0xFF75838B),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'HOUSING',
          badgeType: _CardBadgeType.amex,
        );
      case ModernistCardTheme.fitnessLifestyle:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFFF5252), // Hot coral
          primaryGraphicColor: Color(0xFFE03838),
          secondaryGraphicColor: Color(0xFFFF7A7A),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'FITNESS',
          badgeType: _CardBadgeType.mastercard,
        );
      case ModernistCardTheme.recurringSmartBill:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFE0D8C6), // Oatmeal sand
          primaryGraphicColor: Color(0xFFC7BC9E),
          secondaryGraphicColor: Color(0xFF4A4438),
          textColor: Color(0xFF2C2720),
          badgeColor: Color(0xFF2C2720),
          networkBadgeText: 'RECURRING',
          badgeType: _CardBadgeType.gpay,
        );
      case ModernistCardTheme.tokyoMidnight:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF0D1424),
          primaryGraphicColor: Color(0xFF3B82F6),
          secondaryGraphicColor: Color(0xFF60A5FA),
          textColor: Color(0xFFF1F5F9),
          badgeColor: Color(0xFF3B82F6),
          networkBadgeText: 'MIDNIGHT',
          badgeType: _CardBadgeType.mastercard,
        );
      case ModernistCardTheme.solarAmber:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFF59E0B),
          primaryGraphicColor: Color(0xFFB45309),
          secondaryGraphicColor: Color(0xFFFDE68A),
          textColor: Color(0xFF1C1304),
          badgeColor: Color(0xFF1C1304),
          networkBadgeText: 'SOLAR',
          badgeType: _CardBadgeType.chip,
        );
      case ModernistCardTheme.arcticGlacier:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFBAE6FD),
          primaryGraphicColor: Color(0xFF0369A1),
          secondaryGraphicColor: Color(0xFFE0F2FE),
          textColor: Color(0xFF0C243C),
          badgeColor: Color(0xFF0C243C),
          networkBadgeText: 'GLACIER',
          badgeType: _CardBadgeType.diners,
        );
      case ModernistCardTheme.cyberNeon:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF1E1035),
          primaryGraphicColor: Color(0xFFEC4899),
          secondaryGraphicColor: Color(0xFF06B6D4),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFEC4899),
          networkBadgeText: 'CYBER',
          badgeType: _CardBadgeType.mastercard,
        );
      case ModernistCardTheme.matchaZen:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF8A9A5B),
          primaryGraphicColor: Color(0xFF283618),
          secondaryGraphicColor: Color(0xFFDDA15E),
          textColor: Color(0xFF19220F),
          badgeColor: Color(0xFF19220F),
          networkBadgeText: 'MATCHA',
          badgeType: _CardBadgeType.jcb,
        );
      case ModernistCardTheme.terracottaSunset:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFC2410C),
          primaryGraphicColor: Color(0xFF7C2D12),
          secondaryGraphicColor: Color(0xFFFDBA74),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'TERRA',
          badgeType: _CardBadgeType.amex,
        );
      case ModernistCardTheme.monochromeStark:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF111114),
          primaryGraphicColor: Color(0xFFE4E4E7),
          secondaryGraphicColor: Color(0xFF3F3F46),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'STARK',
          badgeType: _CardBadgeType.amex,
        );
      case ModernistCardTheme.lavenderDusk:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFDDD6FE),
          primaryGraphicColor: Color(0xFF5B21B6),
          secondaryGraphicColor: Color(0xFF8B5CF6),
          textColor: Color(0xFF2E1065),
          badgeColor: Color(0xFF2E1065),
          networkBadgeText: 'LAVENDER',
          badgeType: _CardBadgeType.diners,
        );
      case ModernistCardTheme.cobaltVault:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF1D4ED8),
          primaryGraphicColor: Color(0xFF1E3A8A),
          secondaryGraphicColor: Color(0xFF93C5FD),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'COBALT',
          badgeType: _CardBadgeType.mastercard,
        );
      case ModernistCardTheme.blushPop:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFFF472B6),
          primaryGraphicColor: Color(0xFF9D174D),
          secondaryGraphicColor: Color(0xFFFBCFE8),
          textColor: Color(0xFF500724),
          badgeColor: Color(0xFF500724),
          networkBadgeText: 'BLUSH',
          badgeType: _CardBadgeType.gpay,
        );
      case ModernistCardTheme.nordicPine:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF14281D),
          primaryGraphicColor: Color(0xFF10B981),
          secondaryGraphicColor: Color(0xFF047857),
          textColor: Color(0xFFECFDF5),
          badgeColor: Color(0xFF10B981),
          networkBadgeText: 'NORDIC',
          badgeType: _CardBadgeType.jcb,
        );
      case ModernistCardTheme.copperPatina:
        return const _CardThemeConfig(
          backgroundColor: Color(0xFF9A3412),
          primaryGraphicColor: Color(0xFFB45309),
          secondaryGraphicColor: Color(0xFFFDE68A),
          textColor: Color(0xFFFFFBEB),
          badgeColor: Color(0xFFFFFBEB),
          networkBadgeText: 'COPPER',
          badgeType: _CardBadgeType.chip,
        );
    }
  }
}

