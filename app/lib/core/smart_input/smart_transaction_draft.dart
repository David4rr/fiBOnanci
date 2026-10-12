enum SmartInputSource {
  voice,
  camera,
  gallery,
}

/// Structured draft extracted on-device from Voice Speech-to-Text or Photo OCR.
class SmartTransactionDraft {
  final double? amount;
  final String type; // 'expense' | 'income' | 'transfer'
  final String? walletId;
  final String? destinationWalletId;
  final String? categoryId;
  final String? notes;
  final String rawText;
  final SmartInputSource source;

  const SmartTransactionDraft({
    this.amount,
    this.type = 'expense',
    this.walletId,
    this.destinationWalletId,
    this.categoryId,
    this.notes,
    required this.rawText,
    required this.source,
  });

  bool get hasMeaningfulData =>
      (amount != null && amount! > 0) ||
      (notes != null && notes!.trim().isNotEmpty);
}
