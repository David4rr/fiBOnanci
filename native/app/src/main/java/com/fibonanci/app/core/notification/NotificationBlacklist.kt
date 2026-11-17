package com.fibonanci.app.core.notification

// hard-drop regex blacklist for security tokens, marketing promotions, and ad pricing
object NotificationBlacklist {
    val securityAndMarketing = Regex(
        """\b(""" +
            // security & auth tokens
            """otp|kode\s+otp|kode\s+verifikasi|verification\s+code|passcode|rahasia|password|kata\s+sandi|token|pin|cvv|cvc|""" +
            """jangan\s+berikan|jangan\s+kasih|do\s+not\s+share|jaga\s+kerahasiaan|waspada\s+penipuan|ubah\s+pin|ganti\s+pin|reset\s+password|""" +
            // marketing, promos, discounts & rewards
            """promo|promosi|promotion|diskon|discount|cashback|voucher|kupon|coupon|""" +
            """hadiah|reward|rewards|menangkan|klaim|claim|bonus|""" +
            """special\s+offer|penawaran|exclusive\s+deal|hot\s+deal|best\s+deal|""" +
            """flash\s+sale|mega\s+sale|cuci\s+gudang|big\s+sale|super\s+sale|gajian\s+sale|payday\s+sale|""" +
            """gebyar|undian|giveaway|lucky\s+draw|spin\s*&\s*win|games\s+berhadiah|""" +
            // referral & invite
            """ajak\s+teman|undang\s+teman|referral|referal|kode\s+referral|invite\s+friend|invite\s+friends|""" +
            // loans, credit, paylater advertising & investment promos
            """ajukan\s+pinjaman|pinjaman\s+online|pinjol|dana\s+cepat|butuh\s+dana|plafon\s+s\.d|plafon\s+hingga|limit\s+hingga|limit\s+s\.d|""" +
            """limit\s+paylater|limit\s+spaylater|limit\s+gopaylater|aktifkan\s+spaylater|aktifkan\s+paylater|aktifkan\s+gopaylater|limit\s+kredit|limit\s+belanja|limit\s+pinjaman|dana\s+cicil|cicilan\s+0%|cicilan\s+ringan|""" +
            """bunga\s+mulai|bunga\s+rendah|bunga\s+ringan|bunga\s+spesial|bunga\s+hingga|bunga\s+deposito|buka\s+deposito|buka\s+tabungan|investasi\s+mulai|""" +
            // call-to-action & advertising pricing
            """mulai\s+dari|starting\s+from|start\s+from|serba\s+rp|cuma\s+rp|hanya\s+rp|cukup\s+bayar|mulai\s+rp|mulai\s+harga|""" +
            """hemat\s+hingga|hemat\s+s\.d|hemat\s+s/d|diskon\s+hingga|cashback\s+hingga|cashback\s+s\.d|""" +
            """gratis\s+ongkir|free\s+ongkir|bebas\s+ongkir|free\s+shipping|""" +
            """yuk\s+jajan|pesan\s+sekarang|order\s+sekarang|beli\s+sekarang|belanja\s+sekarang|checkout\s+sekarang|check\s+out\s+sekarang|""" +
            """buruan|jangan\s+lewatkan|don.t\s+miss|spesial\s+untukmu|khusus\s+untukmu|rekomendasi\s+untukmu|""" +
            """iklan|advertisement|sponsored|sponsor""" +
            """)\b""",
        RegexOption.IGNORE_CASE,
    )

    val adPricingAndCondition = Regex(
        """(?:""" +
            """\b(?:hingga|s\.d|s\/d|up\s+to|maksimal|max\.?|plafon|limit)\s+(?:sebesar\s+)?(?:rp\.?|idr)?\s*[0-9]""" +
            """|\b(?:min\.|min|minimal|minimum)\s+(?:belanja|transaksi|pembelian|order|orderan)?\s*(?:rp\.?|idr)?\s*[0-9]""" +
            """|\b(?:mulai\s+dari|mulai|starting\s+from|start\s+from|serba|cuma|hanya|cukup\s+bayar)\s+(?:rp\.?|idr)\b""" +
            """)""",
        RegexOption.IGNORE_CASE,
    )

    fun isBlacklisted(text: String): Boolean =
        securityAndMarketing.containsMatchIn(text) || adPricingAndCondition.containsMatchIn(text)
}
