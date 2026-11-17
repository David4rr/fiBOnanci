package com.fibonanci.app.core.smartinput

enum class SmartInputSource {
    voice,
    camera,
    gallery,
}

/** structured draft extracted on-device from voice speech-to-text or photo ocr. */
data class SmartTransactionDraft(
    val amount: Double? = null,
    val type: String = "expense", // 'expense' | 'income' | 'transfer'
    val walletId: String? = null,
    val destinationWalletId: String? = null,
    val categoryId: String? = null,
    val notes: String? = null,
    val rawText: String,
    val source: SmartInputSource,
) {
    val hasMeaningfulData: Boolean
        get() = (amount != null && amount > 0) || (notes != null && notes.trim().isNotEmpty())
}
