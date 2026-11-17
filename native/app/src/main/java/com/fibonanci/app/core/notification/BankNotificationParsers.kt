package com.fibonanci.app.core.notification

// specialized parsers for indonesian digital banks and e-wallets
object BankNotificationParsers {
    // normalizes idr currency string to double
    fun parseIdr(rawAmount: String): Double = NotificationTextSanitizer.parseIdr(rawAmount)

    private fun rx(pattern: String) = Regex(pattern, RegexOption.IGNORE_CASE)

    private fun result(amount: String, type: String, counterparty: String) =
        ParsedNotificationResult(amount = parseIdr(amount), type = type, counterparty = counterparty.trim())

    fun parseProvider(pkg: String, title: String, body: String): ParsedNotificationResult? {
        if (pkg.contains("seabank") ||
            pkg.contains("bke") ||
            pkg.contains("digitalbank") ||
            pkg.contains("sea.bank") ||
            title.lowercase().contains("seabank")
        ) {
            return parseSeaBank(title, body)
        }
        if (pkg.contains("bcadigital") || pkg.contains("blu")) return parseBlu(title, body)
        if (pkg.contains("bca")) return parseBca(title, body)
        if (pkg.contains("mandiri")) return parseMandiri(title, body)
        if (pkg.contains("jago") || title.lowercase().contains("jago")) return parseJago(title, body)
        if (pkg.contains("ovo")) return parseOvo(title, body)
        if (pkg.contains("gojek") || pkg.contains("gopay")) return parseGoPay(title, body)
        if (pkg.contains("dana")) return parseDana(title, body)
        if (pkg.contains("shopee")) return parseShopeePay(title, body)
        if (pkg.contains("brimo") || pkg.contains("bri")) return parseBrimo(title, body)
        if (pkg.contains("wondr") || pkg.contains("bni")) return parseWondr(title, body)
        return null
    }

    private fun parseSeaBank(title: String, body: String): ParsedNotificationResult? =
        matchSeaBankPatterns(body) ?: matchSeaBankPatterns("$title $body")

    private val seaQris = rx("""(?:Pembayaran\s+QRIS|Pembayaran|Bayar\s+QRIS)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)(?:\s+berhasil|\s+pada|$|\.)""")
    private val seaDm = rx("""(?:Kamu|Anda)\s+menerima\s+(?:dana|transfer)(?:\s+sebesar)?\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\s+pada|$|\.)""")
    private val seaIn = rx("""(?:Kamu|Anda)\s+menerima\s+transfer\s+(?:saldo\s+)?senilai\s+(?:Rp\.?|IDR)\s*([0-9.,]+)(?:\s+ke\s+rekening\s+([0-9]+))?""")
    private val seaVa = rx("""(?:Kamu|Anda)\s+(?:telah|berhasil)\s+(?:melakukan\s+transfer|transfer|mengirim(?:\s+dana|\s+uang)?|membayar)\s+(?:virtual\s+account\s+)?(?:saldo\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:kepada|ke)\s+(.+?)(?:\s+telah\s+berhasil|\s+berhasil|\s+pada|$|\.)""")
    private val seaOut = rx("""(?:Berhasil\s+transfer|Transfer\s+berhasil|Transfer\s+keluar|Transfer)\s+(?:saldo\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada)\s+([^.]+?)(?:\s+telah\s+berhasil|\s+berhasil|\s+pada|$|\.)""")
    private val seaInTransfer = rx("""(?:Transfer\s+masuk|Dana\s+masuk|Uang\s+masuk)\s+(?:saldo\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+?)(?:\s+ke\s+rekening|\s+telah|\s+pada|$|\.)""")
    private val seaTopup = rx("""(?:Berhasil\s+top\s+up|Kamu\s+telah\s+melakukan\s+top\s+up|Top\s+up\s+berhasil)\s+(?:saldo\s+)?(.+?)\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)""")

    private fun matchSeaBankPatterns(text: String): ParsedNotificationResult? {
        seaQris.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        seaDm.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        seaIn.find(text)?.let {
            val rek = it.groups[2]?.value
            return ParsedNotificationResult(
                amount = parseIdr(it.groupValues[1]),
                type = "income",
                counterparty = if (rek != null) "Transfer Masuk (Rek. $rek)" else "Transfer Masuk SeaBank",
            )
        }
        seaVa.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        seaOut.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        seaInTransfer.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        seaTopup.find(text)?.let {
            return ParsedNotificationResult(amount = parseIdr(it.groupValues[2]), type = "expense", counterparty = "Top Up ${it.groupValues[1].trim()}")
        }
        return null
    }

    private val bcaQr = rx("""(?:Pembayaran\s+(?:QRIS|QR)|Transaksi\s+(?:QRIS|QR)|Bayar\s+QRIS)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)(?:\s+berhasil|\s+pada|$|\.)""")
    private val bcaQr2 = rx("""(?:Pembayaran\s+(?:QRIS|QR)|Transaksi\s+(?:QRIS|QR)|Bayar\s+QRIS)\s+(?:di|ke)\s+([^.]+?)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)""")
    private val bcaOut = rx("""(?:m-Transfer|Transfer|Trf)\s+(?:keluar\s+|berhasil[:\s]+)?(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada)\s+([^.]+?)(?:\s+berhasil|\s+pada|$|\.)""")
    private val bcaOut2 = rx("""(?:m-Transfer[:\s]*.*?(?:BERHASIL\s+)?Trf\s+ke|Transfer\s+(?:berhasil\s+)?ke|Kirim\s+uang\s+ke)\s+(?:rekening\s+)?(?:[0-9]+\s+)?([^.]+?)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)""")
    private val bcaIn = rx("""(?:m-Transfer|Transfer|Dana|Uang)\s+masuk\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)""")
    private val bcaIn2 = rx("""(?:m-Transfer|Transfer|Dana|Uang)\s+masuk\s+dari\s+([^.]+?)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)""")
    private val bcaDebit = rx("""(?:Debit\s+rekening|Transaksi\s+debit|Terdebit)\s+.*?(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+)""")

    private fun parseBca(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        bcaQr.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        bcaQr2.find(text)?.let { return result(it.groupValues[2], "expense", it.groupValues[1]) }
        bcaOut.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        bcaOut2.find(text)?.let { return result(it.groupValues[2], "expense", it.groupValues[1]) }
        bcaIn.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        bcaIn2.find(text)?.let { return result(it.groupValues[2], "income", it.groupValues[1]) }
        bcaDebit.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        return null
    }

    private val bluQr = rx("""(?:Pembayaran\s+QRIS|Pembayaran)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)\s+(?:telah\s+berhasil|berhasil)""")
    private val bluOut = rx("""Transfer\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada)\s+([^.]+?)\s+(?:telah\s+berhasil|berhasil)""")
    private val bluIn = rx("""(?:Kamu\s+menerima\s+transfer|Transfer\s+masuk|Dana\s+masuk)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)""")

    private fun parseBlu(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        bluQr.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        bluOut.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        bluIn.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        return null
    }

    private val mandiriQr = rx("""Transaksi\s+(?:Livin'\s+)?(?:QRIS|QR)\s+(?:sebesar\s+)?(?:IDR|Rp\.?)\s*([0-9.,]+)\s+(?:di|ke)\s+(.+?)\s+berhasil""")
    private val mandiriDebit = rx("""(?:Debit\s+rekening\s+\*+[0-9]+|Transfer(?:\s+keluar)?)\s+(?:berhasil!?\s+)?(?:sebesar\s+)?(?:IDR|Rp\.?)\s*([0-9.,]+)\s+(?:ke|kepada)\s+(.+?)(?:\s+berhasil|$|\.)""")
    private val mandiriIn = rx("""(?:Kredit\s+rekening\s+\*+[0-9]+|Transfer\s+masuk|Uang\s+masuk|Dana\s+masuk)\s+(?:sebesar\s+)?(?:IDR|Rp\.?)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\s+berhasil|$|\.)""")

    private fun parseMandiri(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        mandiriQr.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        mandiriDebit.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        mandiriIn.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        return null
    }

    private val brimoOut = rx("""Debit\s+(?:Tabungan\s+BRI|Rekening).*?(?:Sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|di)\s+(.+?)(?:\.|$|\s+pada|\s+berhasil)""")
    private val brimoIn = rx("""Kredit\s+(?:Tabungan\s+BRI|Rekening).*?(?:Sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\.|$|\s+pada|\s+berhasil)""")

    private fun parseBrimo(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        brimoOut.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        brimoIn.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        return null
    }

    private val wondrQr = rx("""Transaksi\s+(?:wondr\s+)?QRIS\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+(.+?)\s+berhasil""")

    private fun parseWondr(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        wondrQr.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        return null
    }

    private fun parseJago(title: String, body: String): ParsedNotificationResult? =
        matchJagoPatterns(body) ?: matchJagoPatterns("$title $body")

    private val jagoPay = rx("""(?:Kamu|Anda)\s+(?:telah|berhasil)\s+(?:membayar|mengirim(?:\s+uang|\s+dana)?|transfer)\s+(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada|di)\s+(.+?)(?:\s+menggunakan|\s+dari\s+kantong|\s+berhasil|\s+pada|$|\.)""")
    private val jagoOut = rx("""(?:Berhasil\s+(?:kirim|transfer|bayar)|Kiriman\s+uang|Transfer\s+keluar|Uang\s+keluar)\s+(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada|di)\s+(.+?)(?:\s+dari\s+kantong|\s+berhasil|\s+pada|$|\.)""")
    private val jagoIn = rx("""(?:Kantong\s+[^.]*?\s+menerima|(?:Kamu|Anda)\s+(?:telah\s+)?menerima|Ada\s+uang\s+masuk|Uang\s+masuk|Dana\s+masuk|Transfer\s+masuk)\s+(?:transfer\s+|dana\s+|uang\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke\s+kantong\s+.+?\s+)?dari\s+(.+?)(?:\s+ke\s+kantong|\s+pada|$|\.)""")
    private val jagoInEn = rx("""(?:You(?:'ve|\s+have)?\s+received|Pocket\s+.*?\s+received|.+?\s+Pocket\s+received)\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+from\s+(.+?)(?:\s+to\s+|\s+in\s+|$|\.)""")

    private fun matchJagoPatterns(text: String): ParsedNotificationResult? {
        jagoPay.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        jagoOut.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        jagoIn.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        jagoInEn.find(text)?.let { return result(it.groupValues[1], "income", it.groupValues[2]) }
        return null
    }

    private val goPayPay = rx("""Pembayaran\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|di)\s+(.+?)\s+berhasil""")
    private val goPayTx = rx("""Kamu\s+telah\s+transfer\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|!)""")

    private fun parseGoPay(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        goPayPay.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        goPayTx.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        return null
    }

    private val ovoPay = rx("""Berhasil\s+bayar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+(.+?)(?:\.|$|!)""")

    private fun parseOvo(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        ovoPay.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        return null
    }

    private val danaPay = rx("""Pembayaran\s+berhasil!?\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|di)\s+(.+?)(?:\.|$|!)""")
    private val danaTx = rx("""Kirim\s+uang\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil""")

    private fun parseDana(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        danaPay.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        danaTx.find(text)?.let { return result(it.groupValues[1], "expense", it.groupValues[2]) }
        return null
    }

    private val shopeeTopup = rx("""(?:pengisian\s+saldo|isi\s+saldo)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)""")
    private val shopeePay = rx("""(?:Pembayaran\s+ShopeePay|Pembayaran)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke\s+([^.]+?)\s+)?berhasil""")

    private fun parseShopeePay(title: String, body: String): ParsedNotificationResult? {
        val text = "$title $body"
        shopeeTopup.find(text)?.let {
            return ParsedNotificationResult(amount = parseIdr(it.groupValues[1]), type = "income", counterparty = "Isi Saldo ShopeePay")
        }
        shopeePay.find(text)?.let {
            return ParsedNotificationResult(
                amount = parseIdr(it.groupValues[1]),
                type = "expense",
                counterparty = it.groups[2]?.value?.trim() ?: "ShopeePay Merchant",
            )
        }
        return null
    }
}
