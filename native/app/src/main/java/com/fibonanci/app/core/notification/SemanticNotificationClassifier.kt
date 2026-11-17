package com.fibonanci.app.core.notification

// fallback semantic classifier handling arbitrary indonesian financial notifications
object SemanticNotificationClassifier {
    private val explicitAmount = Regex(
        """(?:Rp\.?|IDR)\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]{2})?|[0-9]+)|(?:sebesar|senilai|amount|nominal)\s+(?:Rp\.?|IDR)?\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]{2})?|[0-9]+)""",
        RegexOption.IGNORE_CASE,
    )
    private val fallbackAmount = Regex("""([0-9]{1,3}(?:[.,][0-9]{3})+)""")
    private val senderRegex = Regex(
        """(?:dari|pengirim|from)\s+([^.,\n]+?)(?:\s+(?:pada|sebesar|senilai|ke\s+rekening|ke\s+kantong|ke\s+saldo|ke\s+tabungan|berhasil|telah|sukses)|$|\.)""",
        RegexOption.IGNORE_CASE,
    )
    private val recipientRegex = Regex(
        """(?:ke|kepada|di|to)\s+([^.,\n]+?)(?:\s+(?:sebesar|senilai|pada|menggunakan|dari\s+kantong|dari\s+rekening|berhasil|telah|sukses)|$|\.)""",
        RegexOption.IGNORE_CASE,
    )

    private val expenseActionWords = listOf(
        "pembayaran", "bayar", "membayar", "dibayar", "debit", "debited", "terdebit", "terpotong", "tagihan",
        "tarik tunai", "transfer keluar", "mengirim", "berhasil kirim", "baru aja kirim", "kirim ke",
        "berhasil transfer", "uang keluar", "kirim uang",
    )
    private val incomeWords = listOf(
        "masuk", "menerima", "kredit", "credit",
    )
    private val incomeWordsAfterReceived = listOf(
        "cr ", "cr.", "cr:", "setoran", "setor tunai",
    )
    private val incomeWordsAfterDeposit = listOf(
        "top up", "top-up", "topup", "isi saldo", "pengisian saldo", "tambah saldo", "tambah dana",
        "penambahan saldo", "saldo bertambah", "add funds", "add fund", "added funds", "funds added",
        "fund added", "added to", "ditambahkan ke", "ditambahkan", "terima uang", "terima dana",
        "terima transfer", "incoming", "pemasukan", "refund", "pengembalian",
    )
    private val incomeOverrideWords = listOf(
        "menerima", "masuk", "refund", "top up", "isi saldo", "tambah dana", "add funds",
    )
    private val expenseWords = listOf(
        "keluar", "bayar", "membayar", "pembayaran", "dibayar", "payment", "paid", "debit", "debited",
        "terdebit", "terpotong", "pemotongan", "potong saldo", "saldo terpotong", "saldo berkurang",
        "db ", "db.", "db:", "dr ", "dr.", "dr:", "transfer ke", "transfer keluar", "transfer kepada",
        "transfer sebesar", "kirim uang", "kirim dana", "baru aja kirim", "kirim rp", "kirim idr", "kirim ke",
        "mengirim", "dikirim", "terkirim", "berhasil kirim", "berhasil transfer", "transfer berhasil",
        "uang keluar", "dana keluar", "sent to", "send to", "transferred to", "transferred", "transaction",
        "qris", "pembelian", "purchase", "purchased", "belanja di", "tarik tunai", "penarikan", "withdrawal",
        "withdrawn", "tagihan", "bill", "autodebet", "auto debit", "biaya admin", "admin fee", "pengeluaran",
        "outgoing",
    )

    fun classify(
        title: String,
        body: String,
        parseIdr: (String) -> Double,
    ): ParsedNotificationResult? {
        val fullText = NotificationTextSanitizer.stripBalance("$title $body")

        var amount = 0.0
        for (m in explicitAmount.findAll(fullText)) {
            val raw = m.groups[1]?.value ?: m.groups[2]?.value
            if (raw != null) {
                val parsed = parseIdr(raw)
                if (parsed > 0) {
                    amount = parsed
                    break
                }
            }
        }
        if (amount <= 0) {
            val fallbackMatch = fallbackAmount.find(fullText)
            if (fallbackMatch != null) amount = parseIdr(fallbackMatch.groupValues[1])
        }
        if (amount <= 0) return null
        val lowText = fullText.lowercase()

        val hasExpenseAction = expenseActionWords.any { lowText.contains(it) }
        val isIncome = (
            incomeWords.any { lowText.contains(it) } ||
                (!hasExpenseAction && (lowText.contains("diterima") || lowText.contains("received"))) ||
                incomeWordsAfterReceived.any { lowText.contains(it) } ||
                (lowText.contains("deposit") && !lowText.contains("deposito")) ||
                incomeWordsAfterDeposit.any { lowText.contains(it) }
            ) && (!hasExpenseAction || incomeOverrideWords.any { lowText.contains(it) })

        val isExpense = expenseWords.any { lowText.contains(it) }

        if (isIncome) {
            val sMatch = senderRegex.find(fullText)
            var sender = sMatch?.groupValues?.get(1)?.trim() ?: ""
            if (sender.isEmpty()) {
                sender = if (lowText.contains("top up") || lowText.contains("topup") || lowText.contains("top-up")) {
                    "Top Up Saldo"
                } else if (lowText.contains("isi saldo") || lowText.contains("pengisian saldo")) {
                    "Isi Saldo"
                } else if (lowText.contains("add funds") || lowText.contains("add fund") || lowText.contains("tambah dana")) {
                    "Add Funds"
                } else {
                    if (title.isNotEmpty()) title.trim() else "Transfer Masuk"
                }
            }
            return ParsedNotificationResult(amount = amount, type = "income", counterparty = sender)
        } else if (isExpense) {
            val rMatch = recipientRegex.find(fullText)
            val recipient = rMatch?.groupValues?.get(1)?.trim()
                ?: if (title.isNotEmpty()) title.trim() else "Pengeluaran Transaksi"
            return ParsedNotificationResult(amount = amount, type = "expense", counterparty = recipient)
        }
        return null
    }
}
