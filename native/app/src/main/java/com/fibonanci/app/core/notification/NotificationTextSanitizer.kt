package com.fibonanci.app.core.notification

// normalizes notification text, strips balance clauses to prevent amount confusion,
// and extracts balance snapshots across all indonesian banks and e-wallets
object NotificationTextSanitizer {
    private val balanceClause = Regex(
        """(?:sisa\s+saldo|saldo\s+akhir|saldo\s+saat\s+ini|saldo\s+anda|saldo\s+tersedia|saldo\s+rekening)\s*[:=]?\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*[0-9.,]+""",
        RegexOption.IGNORE_CASE,
    )
    private val saldoColon = Regex(
        """(?<!pengisian\s)(?<!isi\s)(?<!tambah\s)\bsaldo\s*[:=]\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*[0-9.,]+""",
        RegexOption.IGNORE_CASE,
    )
    private val saldoAmount = Regex(
        """(?<!pengisian\s)(?<!isi\s)(?<!tambah\s)\bsaldo\s+(?:Rp\.?|IDR)\s*[0-9.,]+""",
        RegexOption.IGNORE_CASE,
    )
    private val balanceExtract = Regex(
        """(?:sisa\s+saldo|saldo\s+akhir|saldo\s+saat\s+ini|saldo\s+anda|saldo\s+tersedia|saldo\s+rekening)\s*[:=]?\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*([0-9.,]+)|(?<!pengisian\s)(?<!isi\s)(?<!tambah\s)\bsaldo\s*[:=]\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*([0-9.,]+)""",
        RegexOption.IGNORE_CASE,
    )
    private val twoDigits = Regex("""^\d{2}$""")
    private val separators = Regex("""[.,]""")

    // removes balance snapshot clauses so they are never parsed as the transaction amount
    fun stripBalance(text: String): String {
        var s = text.replace(balanceClause, "")
        s = s.replace(saldoColon, "")
        s = s.replace(saldoAmount, "")
        return s.trim()
    }

    // extracts the balance snapshot from the notification text if present
    fun extractBalance(text: String): Double? {
        val m = balanceExtract.find(text) ?: return null
        val raw = m.groups[1]?.value ?: m.groups[2]?.value ?: return null
        val v = parseIdr(raw)
        return if (v > 0) v else null
    }

    // normalizes idr currency string to double, stripping decimal cents (,00 or .00)
    fun parseIdr(rawAmount: String): Double {
        var cleaned = rawAmount.replace(" ", "")
        if (cleaned.length > 3) {
            val sepIdx = cleaned.length - 3
            val sepChar = cleaned[sepIdx]
            val tail = cleaned.substring(sepIdx + 1)
            if ((sepChar == ',' || sepChar == '.') && twoDigits.matches(tail)) {
                cleaned = cleaned.substring(0, sepIdx)
            }
        }
        cleaned = cleaned.replace(separators, "")
        return cleaned.toDoubleOrNull() ?: 0.0
    }
}
