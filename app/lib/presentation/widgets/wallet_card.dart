import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'modernist_card_painter.dart';
/// Complete dynamic palette of all 20 curated themes.
/// Orders themes with maximum visual contrast (dark obsidian, vibrant neon, warm pastel, cool ice, earthy sage).
const List<ModernistCardTheme> kDynamicModernistThemes = [
  ModernistCardTheme.fiberInternet,       // 0: Periwinkle Lavender (Pastel cool) - Base
  ModernistCardTheme.utilitiesLemon,      // 1: Acid Neon Lemon (High-voltage neon) - Base
  ModernistCardTheme.streamingCinematic,  // 2: Dark Obsidian Crimson (Dark tech luxury) - Base
  ModernistCardTheme.aiCloudProductivity, // 3: Bone Warm Grey & Terracotta (Warm minimalist) - Base
  ModernistCardTheme.tokyoMidnight,       // 4: Deep Japanese Indigo & Cobalt (Deep cool luxury)
  ModernistCardTheme.fitnessLifestyle,    // 5: Hot Coral Terracotta (Vibrant warm) - Base
  ModernistCardTheme.audioEmerald,        // 6: Emerald Sage & Mint (Organic cool) - Base
  ModernistCardTheme.solarAmber,          // 7: Radiant Solar Amber (Rich gold)
  ModernistCardTheme.monochromeStark,     // 8: Swiss Stark Black & White (Architectural dark)
  ModernistCardTheme.arcticGlacier,       // 9: Frosted Ice Cyan (Clean ice pastel)
  ModernistCardTheme.copperPatina,        // 10: Burnished Industrial Copper (Warm patina)
  ModernistCardTheme.cyberNeon,           // 11: Cyberpunk Ultra Violet & Magenta (Dark neon)
  ModernistCardTheme.recurringSmartBill,  // 12: Oatmeal Sand & Waves (Earthy warm) - Base
  ModernistCardTheme.cobaltVault,         // 13: Royal Electric Cobalt (Vivid blue)
  ModernistCardTheme.matchaZen,           // 14: Japanese Matcha & Zen Pebble (Earthy green)
  ModernistCardTheme.terracottaSunset,    // 15: Burnt Terracotta Sunset (Warm dusk)
  ModernistCardTheme.lavenderDusk,        // 16: Soft Lilac Orchid & Eclipse (Soft violet)
  ModernistCardTheme.housingLiving,       // 17: Slate Charcoal (Minimalist slate) - Base
  ModernistCardTheme.blushPop,            // 18: Neo-Pastel Blush Pink (Playful pop)
  ModernistCardTheme.nordicPine,          // 19: Scandinavian Deep Pine & Mint (Deep forest)
];

/// Curated list of wallet accent colors matching the expanded dynamic themes.
final List<Color> kWalletColors = kDynamicModernistThemes.map((t) {
  final config = ModernistCardConfig.forTheme(t);
  return config.backgroundColor.computeLuminance() < 0.35
      ? config.primaryGraphicColor
      : config.backgroundColor;
}).toList();

Color getWalletColor(int index, [String? colorHex]) {
  if (colorHex != null && colorHex != '#10B981' && colorHex != '#10b981') {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}
  }
  final theme = kDynamicModernistThemes[index.abs() % kDynamicModernistThemes.length];
  final config = ModernistCardConfig.forTheme(theme);
  return config.backgroundColor.computeLuminance() < 0.35
      ? config.primaryGraphicColor
      : config.backgroundColor;
}

/// Resolves a ModernistCardTheme deterministically for a wallet based on its name and index.
/// Resolves a ModernistCardTheme dynamically with strict collision avoidance:
/// - When [allWallets] is supplied, guarantees no two cards in the collection share the same theme.
/// - When [explicitTheme] is provided, uses it directly.
/// - Fallback: index-based unique allocation cycling through all 20 curated themes.
ModernistCardTheme resolveWalletTheme(
  WalletEntry wallet,
  int index, {
  List<WalletEntry>? allWallets,
  ModernistCardTheme? explicitTheme,
}) {
  if (explicitTheme != null) return explicitTheme;

  if (allWallets != null && allWallets.isNotEmpty) {
    final walletIdx = allWallets.indexWhere((w) => w.id == wallet.id);
    final effectiveIdx = walletIdx >= 0 ? walletIdx : index;
    return kDynamicModernistThemes[effectiveIdx.abs() % kDynamicModernistThemes.length];
  }

  return kDynamicModernistThemes[index.abs() % kDynamicModernistThemes.length];
}

/// Resolves the wallet category / status badge (e.g. BANK, E-WALLET, KAS TUNAI)
/// Replaces redundant bank names or card types with clear account classification.
String resolveWalletNetworkBadge(WalletEntry wallet, ModernistCardTheme theme) {
  switch (wallet.type.toLowerCase()) {
    case 'ewallet':
      return 'E-WALLET';
    case 'cash':
      return 'KAS TUNAI';
    case 'investment':
      return 'INVESTASI';
    case 'bank':
    default:
      return 'BANK';
  }
}

/// Standalone ATM Physical Card Component.
/// Strictly matching the Swiss-editorial modernist card design in SubscriptionCard (Tagihan & Langganan).
/// showBottomLayout = false: Compact top-pinned header row for peeking stack cards.
/// showBottomLayout = true: Full physical ATM card layout with chip/contactless and bottom balance.
class WalletCard extends StatelessWidget {
  final WalletEntry wallet;
  final int index;
  final NumberFormat fmt;
  final double cardH;
  final bool isLifted;
  final bool showBottomLayout;
  final bool animate;
  final ModernistCardTheme? theme;
  final List<WalletEntry>? allWallets;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.index,
    required this.fmt,
    required this.cardH,
    this.isLifted = false,
    this.showBottomLayout = false,
    this.animate = true,
    this.theme,
    this.allWallets,
  });


  String _formatAccountNumber(WalletEntry wallet) {
    final num = wallet.accountNumber?.trim();
    if (num == null || num.isEmpty) {
      return '-';
    }
    return num;
  }

  Widget _buildNetworkBadge(String badgeText, ModernistCardConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: config.textColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        badgeText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: config.backgroundColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildChip(Color textColor, bool isDark) {
    final chipBaseColor = isDark
        ? const Color(0xFFD4AF37).withValues(alpha: 0.22)
        : textColor.withValues(alpha: 0.12);
    final chipBorderColor = isDark
        ? const Color(0xFFFFDF73).withValues(alpha: 0.45)
        : textColor.withValues(alpha: 0.32);
    final circuitColor = isDark
        ? const Color(0xFFFFDF73).withValues(alpha: 0.35)
        : textColor.withValues(alpha: 0.24);

    return Container(
      width: 36,
      height: 27,
      decoration: BoxDecoration(
        color: chipBaseColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: chipBorderColor,
          width: 0.9,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 22,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: circuitColor,
                width: 0.7,
              ),
            ),
          ),
          Container(
            width: 0.8,
            height: 16,
            color: circuitColor,
          ),
          Container(
            width: 22,
            height: 0.8,
            color: circuitColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContactlessIcon(Color color) {
    return CustomPaint(
      size: const Size(16, 12),
      painter: ContactlessPainter(color: color.withValues(alpha: 0.85)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = resolveWalletTheme(
      wallet,
      index,
      allWallets: allWallets,
      explicitTheme: theme,
    );
    final config = ModernistCardConfig.forTheme(resolvedTheme);
    final badgeText = resolveWalletNetworkBadge(wallet, resolvedTheme);
    final accountNumberDisplay = _formatAccountNumber(wallet);
    final isDark = config.backgroundColor.computeLuminance() < 0.35;
    // ── Persistent Physical ATM Card Layout (No jarring text jump or cross-fade) ──
    final headerRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            wallet.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: config.textColor,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        _buildNetworkBadge(badgeText, config),
      ],
    );

    // ── Stacked Peek Balance Row (Visible when card is collapsed in deck) ──
    final peekBalanceRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'SALDO TERSEDIA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: config.textColor.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            fmt.format(wallet.balance),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: config.textColor,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );

    final chipRow = Row(
      children: [
        _buildChip(config.textColor, isDark),
      ],
    );

    final bottomRow = Row(
      children: [
        // Amount
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  fmt.format(wallet.balance),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: config.textColor,
                    letterSpacing: -0.8,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Saldo Tersedia',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: config.textColor.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Contactless Icon & Account Number (defaults to '-' if blank)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactlessIcon(config.textColor),
            const SizedBox(height: 5),
            Text(
              accountNumberDisplay,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: config.textColor.withValues(alpha: 0.75),
                letterSpacing: accountNumberDisplay == '-' ? 0.0 : 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      height: cardH,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.14 : 0.08),
          width: 0.9,
        ),
        boxShadow: isLifted
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: config.backgroundColor.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
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
          // Background Subtle Tonal Gradient Depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    config.backgroundColor,
                    Color.alphaBlend(
                      (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.20 : 0.10),
                      config.backgroundColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Background Geometric Modernist Painter
          Positioned.fill(
            child: CustomPaint(
              painter: ModernistCardPainter(
                theme: resolvedTheme,
                primaryColor: config.primaryGraphicColor,
                secondaryColor: config.secondaryGraphicColor,
              ),
            ),
          ),

          // Diagonal specular gloss sheen highlight
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: const Alignment(0.65, 0.85),
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.12 : 0.18),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.60],
                  ),
                ),
              ),
            ),
          ),
          // Card Foreground Content (Rock-solid static header with smoothly animated card body)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Stack(
                children: [
                  // 1. Permanent Static Header Row: ALWAYS at the top, NEVER animates, NEVER ghosts
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: headerRow,
                  ),

                  // 2. Card Body: Smoothly transitions if animate=true, or renders directly without animation when unstacked
                  Positioned.fill(
                    top: 26,
                    child: () {
                      final bodyWidget = showBottomLayout
                          ? SizedBox.expand(
                              key: const ValueKey('expanded_card_body'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(flex: 3),
                                  chipRow,
                                  const Spacer(flex: 4),
                                  bottomRow,
                                ],
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('compact_card_body'),
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: peekBalanceRow,
                              ),
                            );

                      if (!animate) {
                        return bodyWidget;
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: const Cubic(0.16, 1.0, 0.3, 1.0),
                        switchOutCurve: Curves.easeOut,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: bodyWidget,
                      );
                    }(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
