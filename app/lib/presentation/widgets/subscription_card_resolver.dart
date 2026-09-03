import '../../data/database/app_database.dart';
import 'modernist_card_theme.dart';

class SubscriptionCardResolver {
  static String generateMaskedNumber(SubscriptionEntry sub, WalletEntry? wallet) {
    final seed = (sub.id.hashCode).abs();
    final firstPart = (1000 + (seed % 9000)).toString();
    final lastPart = (1000 + ((seed ~/ 10) % 9000)).toString();
    return '$firstPart ...... $lastPart';
  }

  static ModernistCardTheme resolve(String title, int seed) {
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

    // 3. Utilities / Bills
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

    final themes = ModernistCardTheme.values;
    return themes[seed.abs() % themes.length];
  }
}
