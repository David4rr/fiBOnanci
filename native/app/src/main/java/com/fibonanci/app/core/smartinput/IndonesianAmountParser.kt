package com.fibonanci.app.core.smartinput

/**
 * pure kotlin parser for indonesian currency strings, shorthand ('45rb', '2,5jt'),
 * spoken indonesian number words ('dua puluh lima ribu'), and multi-line ocr receipts.
 */
object IndonesianAmountParser {
    private val ic = RegexOption.IGNORE_CASE

    private val unitWords = mapOf(
        "nol" to 0, "satu" to 1, "se" to 1, "dua" to 2, "tiga" to 3, "empat" to 4,
        "lima" to 5, "enam" to 6, "tujuh" to 7, "delapan" to 8, "sembilan" to 9,
        "sepuluh" to 10, "sebelas" to 11,
    )

    private val lineSplit = Regex("[\\r\\n]+")
    private val priorityRegex = Regex(
        "\\b(grand\\s*total|total\\s*bayar|total\\s*belanja|total\\s*pembayaran|total\\s*transaksi|total\\s*tagihan|nominal\\s*transfer|jumlah\\s*transfer|total\\s*harga|harga\\s*jual|jumlah\\s*bayar|total|netto|net|tagihan|ttl|tot)\\b",
        ic,
    )
    private val ignoreLineRegex = Regex(
        "\\b(kembali|kembalian|change|tunai|cash|diskon|hemat|voucher|ppn|tax|pajak|subtotal|sub\\s*total|no\\.?\\s*trx|no\\.?\\s*ref|npwp|telp|tanggal|tgl|date|waktu|time|jam|pukul|kasir|cashier|meja|antrian)\\b",
        ic,
    )
    private val datePatternRegex = Regex(
        "\\b(?:\\d{1,2}[/.-]\\d{1,2}[/.-]\\d{2,4}|\\d{1,2}\\s+(?:jan|feb|mar|apr|mei|jun|jul|agu|aug|sep|okt|oct|nov|des)\\b|\\d{1,2}[:.]\\d{2}(?:[:.]\\d{2})?)",
        ic,
    )
    private val rpRegex = Regex(
        "(?:Rp\\.?|IDR)\\s*([0-9]{1,3}(?:[.,][0-9]{3})+(?:[.,][0-9]{1,2})?|[0-9]{4,})",
        ic,
    )
    private val voiceShorthandRegex = Regex(
        "(\\d+(?:[.,]\\d+)?)\\s*(?:setengah\\s*)?(rb|ribu|rebu|k|jt|juta|miliar|milyar)\\b",
        ic,
    )
    private val lineDateRegex = Regex("\\b\\d{1,2}[/.-]\\d{1,2}[/.-]\\d{2,4}\\b")
    private val lineTimeRegex = Regex("\\b\\d{1,2}[:.]\\d{2}(?:[:.]\\d{2})?\\b")
    private val lineShorthandRegex = Regex(
        "\\b(\\d+(?:[.,]\\d+)?)\\s*(k|rb|ribu|rebu|jt|juta|miliar|milyar)\\b",
        ic,
    )
    private val lineAmountRegex = Regex(
        "(?:Rp\\.?|IDR)?\\s*([0-9]{1,3}(?:[.,][0-9]{3})+(?:[.,][0-9]{1,2})?|\\b[0-9]{3,9}\\b(?:\\s*(?:rupiah|perak))?|\\b[0-9]{4,9}\\b)",
        ic,
    )
    private val centsTail = Regex("^[.,]\\d{2}$")
    private val nonDigit = Regex("[^0-9]")
    private val nonLetter = Regex("[^a-z\\s]")
    private val whitespace = Regex("\\s+")

    private val colloquial = linkedMapOf(
        "seceng" to 1000.0, "goceng" to 5000.0, "ceban" to 10000.0, "goban" to 50000.0, "cepek" to 100.0,
    ).map { (k, v) -> Regex("\\b$k\\b") to v }

    /** extracts the primary transaction amount from a multi-line receipt or ocr text. */
    fun parseReceiptAmount(text: String): Double? {
        val lines = text.split(lineSplit).map { it.trim() }.filter { it.isNotEmpty() }

        var bestTotal: Double? = null
        for (i in lines.indices) {
            val line = lines[i]
            val isDate = datePatternRegex.containsMatchIn(line) && !priorityRegex.containsMatchIn(line)
            if (priorityRegex.containsMatchIn(line) && !ignoreLineRegex.containsMatchIn(line) && !isDate) {
                val sameLineAmt = extractNumericAmountFromLine(line)
                if (sameLineAmt != null && sameLineAmt >= 500) {
                    bestTotal = sameLineAmt
                } else {
                    var off = 1
                    while (off <= 3 && i + off < lines.size) {
                        val nextLine = lines[i + off]
                        if (priorityRegex.containsMatchIn(nextLine)) break
                        if (ignoreLineRegex.containsMatchIn(nextLine) || datePatternRegex.containsMatchIn(nextLine)) {
                            off++
                            continue
                        }
                        val nextLineAmt = extractNumericAmountFromLine(nextLine)
                        if (nextLineAmt != null && nextLineAmt >= 500) {
                            bestTotal = nextLineAmt
                            break
                        }
                        off++
                    }
                }
            }
        }
        if (bestTotal != null) return bestTotal

        var maxRp: Double? = null
        for (m in rpRegex.findAll(text)) {
            val lineOfMatch = lines.firstOrNull { it.contains(m.value) } ?: ""
            if (ignoreLineRegex.containsMatchIn(lineOfMatch) ||
                (datePatternRegex.containsMatchIn(lineOfMatch) && !priorityRegex.containsMatchIn(lineOfMatch))
            ) continue
            val raw = m.groups[1]?.value
            if (raw != null) {
                val v = parseFormattedIdr(raw)
                if (v >= 500 && (maxRp == null || v > maxRp)) maxRp = v
            }
        }
        return maxRp ?: parseVoiceOrInlineAmount(text)
    }

    /** extracts an amount from a natural spoken sentence or inline text. */
    fun parseVoiceOrInlineAmount(text: String): Double? {
        val normalized = text.lowercase()
        val shMatch = voiceShorthandRegex.find(normalized)
        if (shMatch != null) {
            val base = shMatch.groupValues[1].replace(',', '.').toDoubleOrNull()
            val unit = shMatch.groupValues[2].lowercase()
            if (base != null) {
                val mult = multiplierFor(unit)
                val hasHalf = shMatch.value.contains("setengah")
                return base * mult + (if (hasHalf) 0.5 * mult else 0.0)
            }
        }

        val digitAmt = extractNumericAmountFromLine(text)
        if (digitAmt != null && digitAmt > 0) return digitAmt
        return parseSpokenIndonesianWords(normalized)
    }

    private fun multiplierFor(unit: String): Double = when (unit) {
        "jt", "juta" -> 1000000.0
        "miliar", "milyar" -> 1000000000.0
        else -> 1000.0
    }

    private fun extractNumericAmountFromLine(line: String): Double? {
        val sanitized = line.replace(lineDateRegex, "").replace(lineTimeRegex, "")

        val shMatch = lineShorthandRegex.find(sanitized)
        if (shMatch != null) {
            val base = shMatch.groupValues[1].replace(',', '.').toDoubleOrNull()
            val unit = shMatch.groupValues[2].lowercase()
            if (base != null) {
                val v = base * multiplierFor(unit)
                if (v >= 500) return v
            }
        }

        val matches = lineAmountRegex.findAll(sanitized).toList()
        for (m in matches.asReversed()) {
            val raw = m.groups[1]?.value ?: continue
            val v = parseFormattedIdr(raw)
            val fullM = m.value.lowercase()
            val hasPrefix = fullM.contains("rp") || fullM.contains("idr") || fullM.contains("rupiah") || fullM.contains("perak")
            if (!hasPrefix && v >= 2020 && v <= 2035 && !raw.contains('.') && !raw.contains(',')) continue
            if (v > 0) return v
        }
        return null
    }

    fun parseFormattedIdr(raw: String): Double {
        var clean = raw.trim()
        if (clean.length > 3) {
            val tail = clean.substring(clean.length - 3)
            if (centsTail.matches(tail)) clean = clean.substring(0, clean.length - 3)
        }
        clean = clean.replace(nonDigit, "")
        return clean.toDoubleOrNull() ?: 0.0
    }

    private fun parseSpokenIndonesianWords(text: String): Double? {
        for ((regex, value) in colloquial) {
            if (regex.containsMatchIn(text)) return value
        }
        val tokens = text.replace(nonLetter, " ").split(whitespace).filter { it.isNotEmpty() }
        var total = 0.0
        var currentGroup = 0.0
        var currentNumber = 0.0
        var matchedAny = false

        for (w in tokens) {
            val unit = unitWords[w]
            if (unit != null) {
                currentNumber += unit
                matchedAny = true
            } else if (w == "belas") {
                currentNumber = (if (currentNumber == 0.0) 1.0 else currentNumber) + 10
                matchedAny = true
            } else if (w == "puluh") {
                currentGroup += (if (currentNumber == 0.0) 1.0 else currentNumber) * 10
                currentNumber = 0.0
                matchedAny = true
            } else if (w == "seratus") {
                currentGroup += 100
                matchedAny = true
            } else if (w == "ratus") {
                currentGroup += (if (currentNumber == 0.0) 1.0 else currentNumber) * 100
                currentNumber = 0.0
                matchedAny = true
            } else if (w == "setengah") {
                currentNumber += 0.5
                matchedAny = true
            } else if (w == "seribu" || w == "sejuta") {
                total += if (w == "seribu") 1000 else 1000000
                currentGroup = 0.0
                currentNumber = 0.0
                matchedAny = true
            } else if (w == "ribu" || w == "rebu" || w == "juta" || w == "miliar" || w == "milyar") {
                val mult = currentGroup + currentNumber
                val factor = if (w == "ribu" || w == "rebu") 1000.0 else if (w == "juta") 1000000.0 else 1000000000.0
                total += (if (mult == 0.0) 1.0 else mult) * factor
                currentGroup = 0.0
                currentNumber = 0.0
                matchedAny = true
            }
        }

        total += currentGroup + currentNumber
        return if (matchedAny && total >= 100) total else null
    }
}
