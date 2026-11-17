package com.fibonanci.app.core.notification

import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toLocalDateTime
import java.math.BigDecimal
import java.security.MessageDigest

// orchestrates on-device push notification parsing with blacklist filtering,
// bank-specific rules, semantic classification, and sha-256 deduplication windows
object NotificationParser {
    fun parse(
        packageName: String,
        title: String,
        body: String,
        timestamp: Long? = null,
    ): ParsedNotificationResult? {
        val combinedText = "$title $body".trim()

        // stage 1: security & marketing hard-drop
        if (NotificationBlacklist.isBlacklisted(combinedText)) return null

        val sanitizedBody = NotificationTextSanitizer.stripBalance(body)
        val pkg = packageName.lowercase()

        // stage 2a: specific provider parser, stage 2b: universal semantic fallback
        val result = BankNotificationParsers.parseProvider(pkg, title, sanitizedBody)
            ?: SemanticNotificationClassifier.classify(
                title = title,
                body = sanitizedBody,
                parseIdr = BankNotificationParsers::parseIdr,
            )
            ?: return null

        // stage 3: deduplication fingerprint computation
        val timeBucket = (timestamp ?: nowMillis()).toLocalDateTime().minute
        val rawHash = "$packageName|${dartDoubleString(result.amount)}|${result.counterparty}|$timeBucket"
        val digest = MessageDigest.getInstance("SHA-256").digest(rawHash.toByteArray(Charsets.UTF_8))
        val refHash = digest.joinToString("") { "%02x".format(it) }.substring(0, 16)

        return ParsedNotificationResult(
            amount = result.amount,
            type = result.type,
            counterparty = result.counterparty,
            source = result.source,
            externalRef = refHash,
        )
    }

    // matches dart's double.toString() for the values the parsers produce, so refs stay identical
    private fun dartDoubleString(value: Double): String {
        if (value.isNaN() || value.isInfinite()) return value.toString()
        if (value == Math.floor(value) && Math.abs(value) < 1e21) return BigDecimal(value).toPlainString() + ".0"
        if (Math.abs(value) >= 1e-6 && Math.abs(value) < 1e21) return BigDecimal(value.toString()).toPlainString()
        return value.toString()
    }
}
