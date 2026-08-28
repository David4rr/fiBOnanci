class ParsedNotificationResult {
  final double amount;
  final String type; // 'expense', 'income', 'transfer'
  final String counterparty;
  final String source;
  final String? externalRef;

  const ParsedNotificationResult({
    required this.amount,
    required this.type,
    required this.counterparty,
    this.source = 'notification_auto',
    this.externalRef,
  });

  @override
  String toString() {
    return 'ParsedNotificationResult(amount: $amount, type: $type, counterparty: $counterparty, ref: $externalRef)';
  }
}
