import '../../data/database/app_database.dart';
import 'indonesian_amount_parser.dart';
import 'smart_input_rules.dart';
import 'smart_transaction_draft.dart';

export 'indonesian_amount_parser.dart';
export 'smart_input_rules.dart';
export 'smart_transaction_draft.dart';

/// Deterministic on-device NLP & OCR parser converting Voice transcripts or
/// Receipt/Proof OCR text into a pre-filled [SmartTransactionDraft].
class SmartTransactionParser {
  static SmartTransactionDraft parse({
    required String rawText,
    required SmartInputSource source,
    required List<WalletEntry> wallets,
    required List<CategoryEntry> categories,
    String? preferredWalletId,
  }) {
    final cleaned = rawText.trim();
    if (cleaned.isEmpty) return SmartTransactionDraft(rawText: rawText, source: source);

    final amount = source == SmartInputSource.voice
        ? IndonesianAmountParser.parseVoiceOrInlineAmount(cleaned)
        : IndonesianAmountParser.parseReceiptAmount(cleaned);
    final type = SmartInputRules.detectTransactionType(cleaned);
    final walletPair = _matchWallets(cleaned, type, wallets, preferredWalletId);
    final categoryId = type == 'transfer'
        ? '11111111-1111-4111-8111-111111111111'
        : _matchCategory(cleaned, type, categories);
    final matchedWallet = wallets.where((w) => w.id == walletPair.$1).firstOrNull;
    final notes = SmartInputRules.extractCleanNotes(cleaned, source, type, matchedWallet?.name);

    return SmartTransactionDraft(
      amount: amount,
      type: type,
      walletId: walletPair.$1,
      destinationWalletId: walletPair.$2,
      categoryId: categoryId,
      notes: notes,
      rawText: cleaned,
      source: source,
    );
  }

  static (String?, String?) _matchWallets(
    String text,
    String type,
    List<WalletEntry> wallets,
    String? preferredWalletId,
  ) {
    if (wallets.isEmpty) return (null, null);
    final low = text.toLowerCase();

    if (type == 'transfer') {
      final hints = SmartInputRules.matchTransferWallets(low);
      if (hints.$1 != null && hints.$2 != null) {
        final fromW = _findWalletByHint(hints.$1!, wallets);
        final toW = _findWalletByHint(hints.$2!, wallets, excludeId: fromW?.id);
        final srcId = fromW?.id ?? preferredWalletId ?? wallets.first.id;
        final dstId = toW?.id ?? wallets.where((w) => w.id != srcId).map((w) => w.id).firstOrNull;
        return (srcId, dstId);
      }
    }

    final matched = _findWalletByHint(low, wallets);
    final primaryId = matched?.id ??
        (preferredWalletId != null && wallets.any((w) => w.id == preferredWalletId)
            ? preferredWalletId
            : wallets.first.id);
    final secondaryId = type == 'transfer'
        ? wallets.where((w) => w.id != primaryId).map((w) => w.id).firstOrNull
        : null;
    return (primaryId, secondaryId);
  }

  static WalletEntry? _findWalletByHint(String text, List<WalletEntry> wallets, {String? excludeId}) {
    final low = text.toLowerCase();
    for (final w in wallets) {
      if (excludeId != null && w.id == excludeId) continue;
      final wName = w.name.toLowerCase();
      if (low.contains(wName)) return w;
      for (final entry in SmartInputRules.walletAliases.entries) {
        if (wName.contains(entry.key) && entry.value.any((a) => low.contains(a))) return w;
      }
    }
    return null;
  }

  static String? _matchCategory(String text, String type, List<CategoryEntry> categories) {
    final matching = categories.where((c) => c.type == type).toList();
    if (matching.isEmpty) return null;
    final low = text.toLowerCase();
    final firstLine = low.split(RegExp(r'[\r\n]+')).first;
    CategoryEntry? bestCat;
    int bestScore = 0;
    for (final c in matching) {
      final cLow = c.name.toLowerCase();
      int score = 0;
      for (final entry in SmartInputRules.categoryRules.entries) {
        if (cLow.contains(entry.key)) {
          for (final kw in entry.value) {
            if (firstLine.contains(kw)) score += 3;
            if (low.contains(kw)) score += 1;
          }
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestCat = c;
      }
    }
    return (bestCat ?? matching.first).id;
  }
}
