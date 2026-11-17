package com.fibonanci.app.core.smartinput

import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.WalletEntry

/**
 * deterministic on-device nlp & ocr parser converting voice transcripts or
 * receipt/proof ocr text into a pre-filled [SmartTransactionDraft].
 */
object SmartTransactionParser {
    private val lineSplit = Regex("[\\r\\n]+")

    fun parse(
        rawText: String,
        source: SmartInputSource,
        wallets: List<WalletEntry>,
        categories: List<CategoryEntry>,
        preferredWalletId: String? = null,
    ): SmartTransactionDraft {
        val cleaned = rawText.trim()
        if (cleaned.isEmpty()) return SmartTransactionDraft(rawText = rawText, source = source)

        val amount = if (source == SmartInputSource.voice) {
            IndonesianAmountParser.parseVoiceOrInlineAmount(cleaned)
        } else {
            IndonesianAmountParser.parseReceiptAmount(cleaned)
        }
        val type = SmartInputRules.detectTransactionType(cleaned)
        val walletPair = matchWallets(cleaned, type, wallets, preferredWalletId)
        val categoryId = if (type == "transfer") {
            "11111111-1111-4111-8111-111111111111"
        } else {
            matchCategory(cleaned, type, categories)
        }
        val matchedWallet = wallets.firstOrNull { it.id == walletPair.first }
        val notes = SmartInputRules.extractCleanNotes(cleaned, source, type, matchedWallet?.name)

        return SmartTransactionDraft(
            amount = amount,
            type = type,
            walletId = walletPair.first,
            destinationWalletId = walletPair.second,
            categoryId = categoryId,
            notes = notes,
            rawText = cleaned,
            source = source,
        )
    }

    private fun matchWallets(
        text: String,
        type: String,
        wallets: List<WalletEntry>,
        preferredWalletId: String?,
    ): Pair<String?, String?> {
        if (wallets.isEmpty()) return null to null
        val low = text.lowercase()

        if (type == "transfer") {
            val hints = SmartInputRules.matchTransferWallets(low)
            if (hints.first != null && hints.second != null) {
                val fromW = findWalletByHint(hints.first!!, wallets)
                val toW = findWalletByHint(hints.second!!, wallets, excludeId = fromW?.id)
                val srcId = fromW?.id ?: preferredWalletId ?: wallets.first().id
                val dstId = toW?.id ?: wallets.firstOrNull { it.id != srcId }?.id
                return srcId to dstId
            }
        }

        val matched = findWalletByHint(low, wallets)
        val primaryId = matched?.id
            ?: if (preferredWalletId != null && wallets.any { it.id == preferredWalletId }) preferredWalletId else wallets.first().id
        val secondaryId = if (type == "transfer") wallets.firstOrNull { it.id != primaryId }?.id else null
        return primaryId to secondaryId
    }

    private fun findWalletByHint(text: String, wallets: List<WalletEntry>, excludeId: String? = null): WalletEntry? {
        val low = text.lowercase()
        for (w in wallets) {
            if (excludeId != null && w.id == excludeId) continue
            val wName = w.name.lowercase()
            if (low.contains(wName)) return w
            for ((key, aliases) in SmartInputRules.walletAliases) {
                if (wName.contains(key) && aliases.any { low.contains(it) }) return w
            }
        }
        return null
    }

    private fun matchCategory(text: String, type: String, categories: List<CategoryEntry>): String? {
        val matching = categories.filter { it.type == type }
        if (matching.isEmpty()) return null
        val low = text.lowercase()
        val firstLine = low.split(lineSplit).first()
        var bestCat: CategoryEntry? = null
        var bestScore = 0
        for (c in matching) {
            val cLow = c.name.lowercase()
            var score = 0
            for ((key, keywords) in SmartInputRules.categoryRules) {
                if (cLow.contains(key)) {
                    for (kw in keywords) {
                        if (firstLine.contains(kw)) score += 3
                        if (low.contains(kw)) score += 1
                    }
                }
            }
            if (score > bestScore) {
                bestScore = score
                bestCat = c
            }
        }
        return (bestCat ?: matching.first()).id
    }
}
