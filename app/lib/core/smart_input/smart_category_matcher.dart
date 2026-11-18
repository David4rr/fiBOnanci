import '../../data/database/app_database.dart';
import 'category_keywords.dart';

/// Centralized deterministic Indonesian category matching engine for
/// auto-logged push notifications, voice transcripts, and receipt/proof OCR.
class SmartCategoryMatcher {
  static CategoryEntry? matchCategory({
    required List<CategoryEntry> categories,
    required String type,
    required String text,
    String? title,
    String? counterparty,
  }) {
    final matching = categories.where((c) => c.type == type && !c.isDeleted).toList();
    if (matching.isEmpty) return null;
    if (matching.length == 1) return matching.first;

    final lowText = text.toLowerCase();
    final lowTitle = (title ?? '').toLowerCase();
    final lowCounterparty = (counterparty ?? '').toLowerCase();

    final lines = lowText.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).toList();
    final headerLines = lines.take(2).join(' ');
    final headerContext = '$lowCounterparty $lowTitle $headerLines';
    final fullContext = '$lowCounterparty $lowTitle $lowText';

    CategoryEntry? bestCat;
    int bestScore = 0;

    for (final c in matching) {
      final cName = c.name.toLowerCase();
      final cIcon = c.iconName.toLowerCase();
      int score = 0;

      // 1. Direct Category Name Match (+12 exact, +6 per word)
      if (fullContext.contains(cName)) {
        score += 12;
      } else {
        final words = cName.split(RegExp(r'[\s&/,\-]+')).where((w) => w.length >= 4);
        for (final w in words) {
          if (headerContext.contains(w)) {
            score += 8;
          } else if (fullContext.contains(w)) {
            score += 5;
          }
        }
      }

      // 2. Category Rule Keywords (+5 header, +2 body)
      for (final entry in CategoryKeywords.categoryRules.entries) {
        final clusterKey = entry.key;
        if (cName.contains(clusterKey) || cIcon == clusterKey) {
          for (final kw in entry.value) {
            if (headerContext.contains(kw)) {
              score += 5;
            } else if (fullContext.contains(kw)) {
              score += 2;
            }
          }
        }
      }

      // 3. Category Icon Specific Keywords (+6 header, +3 body)
      final iconKws = CategoryKeywords.iconKeywords[cIcon];
      if (iconKws != null) {
        for (final kw in iconKws) {
          if (headerContext.contains(kw)) {
            score += 6;
          } else if (fullContext.contains(kw)) {
            score += 3;
          }
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestCat = c;
      }
    }

    return bestScore > 0 ? bestCat : matching.first;
  }
}
