import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'modernist_card_painter.dart';
const kWalletColors = [
  Color(0xFF9EACF0), // periwinkle
  Color(0xFFF3F76E), // acid lemon
  Color(0xFFFF5252), // hot coral
  Color(0xFFE5E3DC), // bone warm grey
  Color(0xFF7CB88D), // emerald sage
  Color(0xFF1E1418), // obsidian crimson
  Color(0xFFE0D8C6), // oatmeal sand
  Color(0xFF56626A), // slate charcoal
];

Color getWalletColor(int index, [String? colorHex]) {
  if (colorHex != null && colorHex != '#10B981' && colorHex != '#10b981') {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}
  }
  final themes = ModernistCardTheme.values;
  final theme = themes[index.abs() % themes.length];
  final config = ModernistCardConfig.forTheme(theme);
  return config.backgroundColor.computeLuminance() < 0.35
      ? config.primaryGraphicColor
      : config.backgroundColor;
}


/// Resolves a ModernistCardTheme deterministically for a wallet based on its name and index.
ModernistCardTheme resolveWalletTheme(WalletEntry wallet, int index) {
  final lower = wallet.name.toLowerCase();

  // 1. Blue banks (BCA, blu, CIMB, Permata) -> Periwinkle fiber (concentric modernist ovals)
  if (lower.contains('bca') || lower.contains('blu') || lower.contains('cimb') || lower.contains('permata')) {
    return ModernistCardTheme.fiberInternet;
  }

  // 2. Yellow / Gold banks (Mandiri, Livin, BSI, Krom) -> Acid Neon Lemon (sunburst)
  if (lower.contains('mandiri') || lower.contains('livin') || lower.contains('bsi') || lower.contains('krom')) {
    return ModernistCardTheme.utilitiesLemon;
  }

  // 3. Tangerine / Coral modern banks (Jago, Aladin, Neobank) -> Hot Coral (dynamic arcs)
  if (lower.contains('jago') || lower.contains('neo') || lower.contains('aladin')) {
    return ModernistCardTheme.fitnessLifestyle;
  }

  // 4. SeaBank / ShopeePay / Terracotta -> Bone Warm Grey with Terracotta Disks
  if (lower.contains('seabank') || lower.contains('sea') || lower.contains('shopee')) {
    return ModernistCardTheme.aiCloudProductivity;
  }

  // 5. Green E-Wallets / Banks (GoPay, LinkAja, Hibank) -> Emerald Sage (soundwave hatching)
  if (lower.contains('gopay') || lower.contains('gojek') || lower.contains('linkaja')) {
    return ModernistCardTheme.audioEmerald;
  }

  // 6. Purple / Dark tech (OVO, DANA, Jenius) -> Dark Obsidian Crimson
  if (lower.contains('ovo') || lower.contains('dana') || lower.contains('jenius')) {
    return ModernistCardTheme.streamingCinematic;
  }

  // 7. Cash / Kas Tunai -> Oatmeal Sand (geometric waves)
  if (wallet.type == 'cash' || lower.contains('kas') || lower.contains('tunai')) {
    return ModernistCardTheme.recurringSmartBill;
  }

  // 8. Slate / Charcoal banks (BRI, BNI, Danamon) -> Slate Charcoal
  if (lower.contains('bri') || lower.contains('bni') || lower.contains('danamon')) {
    return ModernistCardTheme.housingLiving;
  }

  // Fallback: cycle through the 8 themes deterministically by index / seed
  final themes = ModernistCardTheme.values;
  final seed = wallet.id.hashCode ^ index;
  return themes[seed.abs() % themes.length];
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

  const WalletCard({
    super.key,
    required this.wallet,
    required this.index,
    required this.fmt,
    required this.cardH,
    this.isLifted = false,
    this.showBottomLayout = false,
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

  Widget _buildChip(Color textColor) {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: textColor.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 18,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.5),
              border: Border.all(
                color: textColor.withValues(alpha: 0.22),
                width: 0.6,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 14,
            color: textColor.withValues(alpha: 0.22),
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
    final theme = resolveWalletTheme(wallet, index);
    final config = ModernistCardConfig.forTheme(theme);
    final badgeText = resolveWalletNetworkBadge(wallet, theme);
    final accountNumberDisplay = _formatAccountNumber(wallet);
    final isDark = config.backgroundColor.computeLuminance() < 0.35;

    // ── Top layout: compact top-pinned header row for peeking stack cards ──
    final topLayout = Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wallet.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: config.textColor,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SALDO TERSEDIA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: config.textColor.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNetworkBadge(badgeText, config),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    fmt.format(wallet.balance),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: config.textColor,
                      letterSpacing: -0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // ── Bottom layout: full physical ATM card view matching SubscriptionCard ──
    final bottomLayout = Padding(
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
          ),

          // Middle: Tactile ATM EMV Smart Chip
          Row(
            children: [
              _buildChip(config.textColor),
            ],
          ),
          // Bottom Row: Large Amount (Left) & Masked Number with Contactless Icon (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
          ),
        ],
      ),
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
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
          width: 0.8,
        ),
        boxShadow: isLifted
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
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

          // Diagonal specular gloss sheen highlight
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: const Alignment(0.6, 0.8),
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.10 : 0.16),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
          ),

          // Card Foreground Content (Top layout or Bottom layout)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: showBottomLayout
                  ? SizedBox.expand(
                      key: const ValueKey('bottom_layout'),
                      child: bottomLayout,
                    )
                  : SizedBox.expand(
                      key: const ValueKey('top_layout'),
                      child: topLayout,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
