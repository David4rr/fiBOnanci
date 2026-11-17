package com.fibonanci.app.core.notification

data class ParsedNotificationResult(
    val amount: Double,
    val type: String, // 'expense', 'income', 'transfer'
    val counterparty: String,
    val source: String = "notification_auto",
    val externalRef: String? = null,
) {
    override fun toString(): String =
        "ParsedNotificationResult(amount: $amount, type: $type, counterparty: $counterparty, ref: $externalRef)"
}
