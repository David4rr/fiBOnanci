package com.fibonanci.app.core.smartinput

/**
 * centralized indonesian nlp vocabulary, regex classifiers, and note cleaners
 * for voice speech-to-text and smart text input.
 */
object SmartInputRules {
    private val ic = RegexOption.IGNORE_CASE

    val walletAliases: Map<String, List<String>> = linkedMapOf(
        "bca" to listOf("bca", "mybca", "klikbca", "tahapan"),
        "blu" to listOf("blu", "bca digital"),
        "mandiri" to listOf("mandiri", "livin"),
        "bri" to listOf("bri", "brimo"),
        "bni" to listOf("bni", "wondr"),
        "jago" to listOf("jago", "bank jago"),
        "seabank" to listOf("seabank", "sea bank"),
        "gopay" to listOf("gopay", "go pay", "gojek"),
        "ovo" to listOf("ovo"),
        "dana" to listOf("dana"),
        "shopeepay" to listOf("shopeepay", "shopee pay"),
    )

    val categoryRules: Map<String, List<String>> = linkedMapOf(
        "makanan" to listOf("makan", "minum", "kopi", "coffee", "cafe", "resto", "warung", "nasi", "ayam", "bakso", "mie", "gofood", "grabfood", "shopeefood", "starbucks", "kenangan", "fore", "roti", "snack", "sarapan", "dinner", "lunch"),
        "transportasi" to listOf("bensin", "pertamina", "pertamax", "pertalite", "shell", "parkir", "tol", "gojek", "goride", "gocar", "grab", "uber", "kereta", "krl", "mrt", "lrt", "busway", "transjakarta", "tiket", "taksi"),
        "belanja" to listOf("belanja", "indomaret", "alfamart", "alfamidi", "superindo", "hypermart", "tokopedia", "shopee", "lazada", "tiktok", "baju", "sepatu", "sabun", "minimarket", "supermarket", "mall"),
        "tagihan" to listOf("listrik", "pln", "pdam", "air", "wifi", "indihome", "biznet", "pulsa", "paket data", "telkomsel", "xl", "indosat", "bpjs", "pajak", "tagihan", "cicilan", "kredit"),
        "hiburan" to listOf("netflix", "spotify", "youtube", "bioskop", "xxi", "cgv", "game", "steam", "playstation", "konser", "liburan", "hotel", "hiburan"),
        "kesehatan" to listOf("obat", "apotek", "kimia farma", "k24", "rs", "rumah sakit", "dokter", "klinik", "halodoc", "vitamin", "medis", "lab"),
        "pendidikan" to listOf("buku", "gramedia", "kursus", "udemy", "coursera", "sekolah", "kuliah", "ukt", "spp", "seminar"),
        "gaji" to listOf("gaji", "gajian", "salary", "payroll", "upah", "thr", "tunjangan", "pendapatan", "pemasukan", "penghasilan", "honor", "pesangon"),
        "bonus" to listOf("bonus", "freelance", "proyek", "project", "komisi", "insentif", "hadiah", "reward", "tips", "jualan", "dagang", "laba", "untung", "profit", "omset", "omzet", "cashback", "refund"),
        "investasi" to listOf("dividen", "bunga", "investasi", "reksadana", "saham", "bibit", "ajaib", "deposito", "emas", "crypto", "kripto"),
    )

    private val transferFromTo = Regex("\\b(transfer|pindah|kirim|tarik|isi\\s*saldo|top\\s*up|topup)\\b.*\\bdari\\b.*\\bke\\b")
    private val transferToFrom = Regex("\\b(transfer|pindah|kirim|tarik|isi\\s*saldo|top\\s*up|topup)\\b.*\\bke\\b.*\\bdari\\b")
    private val topUpVia = Regex("\\b(?:top\\s*up|topup|isi\\s*(?:saldo)?)\\b\\s+[a-z0-9]+\\s+(?:dari|pakai|lewat|via)\\s+[a-z0-9]+")

    private val expenseActions = listOf(
        "beli", "membeli", "bayar", "membayar", "belanja", "habis", "ongkir",
        "jajan", "makan", "minum", "langganan", "cicilan", "sewa", "checkout",
        "tarik tunai", "sedekah", "donasi", "zakat",
    ).map { Regex("\\b$it\\b") }

    private val incomeKw = listOf(
        "gaji", "gajian", "salary", "payroll", "upah", "honor", "tunjangan", "thr",
        "pesangon", "pemasukan", "pendapatan", "penghasilan", "omset", "omzet",
        "mendapat", "mendapatkan", "dapat", "dapet", "menerima", "terima",
        "diterima", "uang masuk", "dana masuk", "saldo masuk", "transferan masuk",
        "transfer masuk", "masuk ke", "masuk di", "masuk rekening", "ditransfer",
        "bonus", "insentif", "komisi", "tips", "freelance", "proyek", "side job",
        "jualan", "penjualan", "laba", "untung", "profit", "dividen", "bunga bank",
        "bunga deposito", "imbal hasil", "hadiah", "reward", "menang", "giveaway",
        "doorprize", "cashback", "refund", "reimburse", "reimbursement", "klaim",
        "cair", "pencairan", "dikasih", "kiriman",
    ).map { Regex("\\b$it\\b") }

    fun detectTransactionType(text: String): String {
        val low = text.lowercase()
        val hasIncomingNotice = low.contains("terima transfer") ||
            low.contains("dapat transfer") ||
            low.contains("dapet transfer") ||
            low.contains("transferan masuk") ||
            low.contains("ada transfer")

        val isTransfer = !hasIncomingNotice &&
            (low.contains("transfer antar") ||
                low.contains("pindah dana") ||
                low.contains("pindah saldo") ||
                transferFromTo.containsMatchIn(low) ||
                transferToFrom.containsMatchIn(low) ||
                topUpVia.containsMatchIn(low))
        if (isTransfer) return "transfer"

        val hasExpenseVerb = expenseActions.any { it.containsMatchIn(low) }
        val hasIncomeKw = incomeKw.any { it.containsMatchIn(low) }

        if (hasIncomeKw && !hasExpenseVerb) return "income"
        if (hasIncomeKw && hasExpenseVerb) {
            if (low.contains("cashback") || low.contains("refund") || low.contains("reimburse")) {
                return if (low.startsWith("beli") || low.startsWith("bayar")) "expense" else "income"
            }
            val firstInc = incomeKw.mapNotNull { it.find(low)?.range?.first }.minOrNull()
            val firstExp = expenseActions.mapNotNull { it.find(low)?.range?.first }.minOrNull()
            if (firstInc != null && firstExp != null) {
                return if (firstInc < firstExp) "income" else "expense"
            }
        }

        return if (hasIncomeKw) "income" else "expense"
    }

    private val fromToWallets = Regex("\\bdari\\s+([a-z0-9\\s]+?)\\s+ke\\s+([a-z0-9\\s]+)")
    private val toFromWallets = Regex("\\bke\\s+([a-z0-9\\s]+?)\\s+dari\\s+([a-z0-9\\s]+)")
    private val topUpWallets = Regex("\\b(?:top\\s*up|topup|isi\\s*(?:saldo)?)\\s+([a-z0-9\\s]+?)\\s+(?:dari|pakai|lewat|via)\\s+([a-z0-9\\s]+)")

    /** returns (source hint, destination hint). */
    fun matchTransferWallets(low: String): Pair<String?, String?> {
        fromToWallets.find(low)?.let { return it.groupValues[1] to it.groupValues[2] }
        toFromWallets.find(low)?.let { return it.groupValues[2] to it.groupValues[1] }
        topUpWallets.find(low)?.let { return it.groupValues[2] to it.groupValues[1] }
        return null to null
    }

    private val voiceRpAmount = Regex("(?:Rp\\.?|IDR)\\s*[0-9.,]+", ic)
    private val voiceNumber = Regex("\\b\\d+(?:[.,]\\d+)?\\s*(?:rb|ribu|rebu|k|jt|juta|miliar|milyar|rupiah|perak)?\\b", ic)
    private val voiceNumberWords = Regex("\\b(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|miliar|milyar|setengah|rupiah|perak|seceng|goceng|ceban|goban|cepek)\\b", ic)
    private val voiceWalletPhrase = Regex("\\b(?:pakai|via|dari|ke|di|pada|masuk\\s+(?:ke|di)|menggunakan|lewat|dengan)\\s+(?:rekening(?:\\s+[a-zA-Z0-9]+)?|dompet(?:\\s+[a-zA-Z0-9]+)?|bank(?:\\s+[a-zA-Z0-9]+)?|bca|mybca|klikbca|mandiri|livin|bri|brimo|bni|wondr|jago|seabank|gopay|ovo|dana|shopeepay|blu)\\b", ic)
    private val voiceAmountTail = Regex("\\b(?:sebesar|senilai)\\b.*$", ic)
    private val voiceCommandHead = Regex("^\\s*(?:tolong\\s+)?(?:catat|masukkan|input)\\s+", ic)
    private val whitespace = Regex("\\s+")
    private val letters = Regex("[a-zA-Z]+")
    private val lineSplit = Regex("[\\r\\n]+")
    private val labeledLine = Regex("^(?:merchant|penerima|tujuan|toko|outlet)\\s*[:\\-]\\s*(.+)$", ic)
    private val skipHeader = Regex(
        "^(struk|bukti|transaksi|berhasil|sukses|tanggal|waktu|no\\.|npwp|jl\\.|jalan|telp|welcome|terima\\s*kasih|kasir|copy|receipt|\\d+)",
        ic,
    )
    private val groupedAmount = Regex("\\d{3}[.,]\\d{3}")

    private val fillerWords = setOf(
        "saya", "aku", "mendapat", "mendapatkan", "dapat", "dapet", "terima",
        "menerima", "uang", "dana", "saldo", "masuk", "keluar", "pengeluaran",
        "pemasukan", "catat", "ada", "di", "ke", "dari", "pada",
    )

    fun extractCleanNotes(
        text: String,
        source: SmartInputSource,
        type: String,
        matchedWalletName: String?,
    ): String? {
        if (source == SmartInputSource.voice) {
            val note = text
                .replace(voiceRpAmount, "")
                .replace(voiceNumber, "")
                .replace(voiceNumberWords, "")
                .replace(voiceWalletPhrase, "")
                .replace(voiceAmountTail, "")
                .replace(voiceCommandHead, "")
                .replace(whitespace, " ")
                .trim()

            val words = letters.findAll(note).map { it.value.lowercase() }.toList()
            val isPureFiller = words.isEmpty() || words.all { it in fillerWords }

            if (isPureFiller) {
                return when (type) {
                    "income" -> if (matchedWalletName != null) "Pemasukan $matchedWalletName" else "Pemasukan"
                    "transfer" -> "Transfer"
                    else -> "Pengeluaran"
                }
            }
            return note.substring(0, 1).uppercase() + note.substring(1)
        }

        val lines = text.split(lineSplit).map { it.trim() }.filter { it.length >= 3 }
        for (l in lines) {
            val m = labeledLine.find(l)
            if (m != null && m.groupValues[1].trim().isNotEmpty()) return m.groupValues[1].trim()
        }
        for (l in lines) {
            if (!skipHeader.containsMatchIn(l) && !l.contains("Rp") && !groupedAmount.containsMatchIn(l)) {
                return if (l.length > 42) l.substring(0, 42).trim() else l
            }
        }
        return lines.firstOrNull()?.let { if (it.length > 42) it.substring(0, 42) else it }
    }
}
